#############################################################################
#
# Makefile for C projects
#
# Author:  Dominik Downarowicz
# Date:    2024/09/30 (version 0.1)
#===========================================================================

## Customizable Section: adapt those variables to suit your program.
##==========================================================================

# The executable file name. Must be specified.
PROGRAM                = codebase

# C and C++ program compilers. Un-comment and specify for cross-compiling if needed. 
CC                    = gcc
#CXX                   = g++
# Un-comment the following line to compile C programs as C++ ones.
#CC                    = $(CXX)

# The extra pre-processor and compiler options; applies to both C and C++ compiling as well as LD. 
EXTRA_CFLAGS           = -fdata-sections -ffunction-sections

# The extra linker options, e.g. "-lmysqlclient -lz"
EXTRA_LDFLAGS          = 

# Specify the include dirs, e.g. "-I/usr/include/mysql -I./include -I/usr/include -I/usr/local/include".
INCLUDE                = "-I./include"

# The C Preprocessor options (notice here "CPP" does not mean "C++"; man cpp for more info.). Actually $(INCLUDE) is included. 
CPPFLAGS               = -Wall -Wextra    # helpful for writing better code (behavior-related)

# The options used in linking as well as in any direct use of ld. 
LDFLAGS                =

# The directories in which source files reside.
# If not specified, all subdirectories of the current directory will be added recursively. 
SRCDIRS               := src
SRCDIRS               += src/*

# OS specific. 
EXTRA_CFLAGS_MACOS     = 
EXTRA_LDFLAGS_MACOS    = -Wl,-search_paths_first -Wl,-dead_strip -v   # deleting unused code for Pear, for minimal exe size
LDFLAGS_MACOS          =
EXTRA_CFLAGS_LINUX     =
EXTRA_LDFLAGS_LINUX    = -Wl,--gc-sections -Wl,--strip-all            # deleting unused code for Pear, for minimal exe size
LDFLAGS_LINUX          =
EXTRA_CFLAGS_WINDOWS   =
EXTRA_LDFLAGS_WINDOWS  =
LDFLAGS_WINDOWS        =

# Actually process the OS specific flags. 
UNAME_S  := $(shell uname -s)
ifeq ($(UNAME_S), Darwin)      # if MacOS
EXTRA_CFLAGS  += $(EXTRA_CFLAGS_MACOS)
EXTRA_LDFLAGS += $(EXTRA_LDFLAGS_MACOS)
LDFLAGS       += $(LDFLAGS_MACOS)
else ifeq ($(UNAME_S), Linux)  # if Linux
EXTRA_CFLAGS  += $(EXTRA_CFLAGS_LINUX)
EXTRA_LDFLAGS += $(EXTRA_LDFLAGS_LINUX)
LDFLAGS       += $(LDFLAGS_LINUX) 
else                           # Windows, or... need to specify "MINGW" or "CYGWIN" to correctly detect. 
EXTRA_CFLAGS  += $(EXTRA_CFLAGS_WINDOWS)
EXTRA_LDFLAGS += $(EXTRA_LDFLAGS_WINDOWS)
LDFLAGS       += $(LDFLAGS_WINDOWS)
endif

#Actually $(INCLUDE) is included in $(CPPFLAGS).
CPPFLAGS      += $(INCLUDE)

## Implicit Section: change the following only when necessary.
##==========================================================================

# The source file types (headers excluded).
# .c indicates C source files, and others C++ ones.
SRCEXTS = .c .C .cc .cpp .CPP .c++ .cxx .cp

# The header file types.
HDREXTS = .h .H .hh .hpp .HPP .h++ .hxx .hp

# The pre-processor and compiler options.
# Users can override those variables from the command line.
CFLAGS  = -O3
CXXFLAGS= -O3

# The command used to delete file.
RM     = rm -f

ETAGS = etags
ETAGSFLAGS =

CTAGS = ctags
CTAGSFLAGS =

## Stable Section: usually no need to be changed. But you can add more.
##==========================================================================
ifeq ($(SRCDIRS),)
	SRCDIRS := $(shell find $(SRCDIRS) -type d)
endif
SOURCES = $(foreach d,$(SRCDIRS),$(wildcard $(addprefix $(d)/*,$(SRCEXTS))))
HEADERS = $(foreach d,$(SRCDIRS),$(wildcard $(addprefix $(d)/*,$(HDREXTS))))
SRC_CXX = $(filter-out %.c,$(SOURCES))
OBJS    = $(addsuffix .o, $(basename $(SOURCES)))
#DEPS    = $(OBJS:%.o=%.d) #replace %.d with .%.d (hide dependency files)
DEPS    = $(foreach f, $(OBJS), $(addprefix $(dir $(f))., $(patsubst %.o, %.d, $(notdir $(f)))))

## Define some useful variables.
DEP_OPT = $(shell if `$(CC) --version | grep -i "GCC" >/dev/null`; then \
                  echo "-MM"; else echo "-M"; fi )
DEPEND.d    = $(CC)  $(DEP_OPT)  $(EXTRA_CFLAGS) $(CFLAGS) $(CPPFLAGS)
COMPILE.c   = $(CC)  $(EXTRA_CFLAGS) $(CFLAGS)   $(CPPFLAGS) -c
COMPILE.cxx = $(CXX) $(EXTRA_CFLAGS) $(CXXFLAGS) $(CPPFLAGS) -c
LINK.c      = $(CC)  $(EXTRA_CFLAGS) $(CFLAGS)   $(CPPFLAGS) $(LDFLAGS)
LINK.cxx    = $(CXX) $(EXTRA_CFLAGS) $(CXXFLAGS) $(CPPFLAGS) $(LDFLAGS)

.PHONY: all objs tags ctags clean distclean help show

# Delete the default suffixes
.SUFFIXES:

all: $(PROGRAM)

# Rules for creating dependency files (.d).
#------------------------------------------

.%.d:%.c
	@echo -n $(dir $<) > $@
	@$(DEPEND.d) $< >> $@

.%.d:%.C
	@echo -n $(dir $<) > $@
	@$(DEPEND.d) $< >> $@

.%.d:%.cc
	@echo -n $(dir $<) > $@
	@$(DEPEND.d) $< >> $@

.%.d:%.cpp
	@echo -n $(dir $<) > $@
	@$(DEPEND.d) $< >> $@

.%.d:%.CPP
	@echo -n $(dir $<) > $@
	@$(DEPEND.d) $< >> $@

.%.d:%.c++
	@echo -n $(dir $<) > $@
	@$(DEPEND.d) $< >> $@

.%.d:%.cp
	@echo -n $(dir $<) > $@
	@$(DEPEND.d) $< >> $@

.%.d:%.cxx
	@echo -n $(dir $<) > $@
	@$(DEPEND.d) $< >> $@

# Rules for generating object files (.o).
#----------------------------------------
objs:$(OBJS)

%.o:%.c
	$(COMPILE.c) $< -o $@

%.o:%.C
	$(COMPILE.cxx) $< -o $@

%.o:%.cc
	$(COMPILE.cxx) $< -o $@

%.o:%.cpp
	$(COMPILE.cxx) $< -o $@

%.o:%.CPP
	$(COMPILE.cxx) $< -o $@

%.o:%.c++
	$(COMPILE.cxx) $< -o $@

%.o:%.cp
	$(COMPILE.cxx) $< -o $@

%.o:%.cxx
	$(COMPILE.cxx) $< -o $@

# Rules for generating the tags.
#-------------------------------------
tags: $(HEADERS) $(SOURCES)
	$(ETAGS) $(ETAGSFLAGS) $(HEADERS) $(SOURCES)

ctags: $(HEADERS) $(SOURCES)
	$(CTAGS) $(CTAGSFLAGS) $(HEADERS) $(SOURCES)

# Rules for generating the executable.
#-------------------------------------
$(PROGRAM):$(OBJS)
ifeq ($(SRC_CXX),)              # C program
	$(LINK.c)   $(OBJS) $(EXTRA_LDFLAGS) -o $@
	@echo Type ./$@ to execute the program.
else                            # C++ program
	$(LINK.cxx) $(OBJS) $(EXTRA_LDFLAGS) -o $@
	@echo Type ./$@ to execute the program.
endif

ifndef NODEP
ifneq ($(DEPS),)
  sinclude $(DEPS)
endif
endif

clean:
	$(RM) $(OBJS) $(PROGRAM) $(DEPS) $(PROGRAM).exe

distclean: clean
	$(RM) $(DEPS) TAGS

# Show help.
help:
	@echo 'Usage: make [TARGET]'
	@echo 'TARGETS:'
	@echo '  all       (=make) compile and link.'
	@echo '  NODEP=yes make without generating dependencies.'
	@echo '  objs      compile only (no linking).'
	@echo '  tags      create tags for Emacs editor.'
	@echo '  ctags     create ctags for VI editor.'
	@echo '  clean     clean objects and the executable file.'
	@echo '  distclean clean objects, the executable and dependencies.'
	@echo '  show      show variables (for debug use only).'
	@echo '  help      print this message.'
	@echo
# Show variables (for debug use only.)
show:
	@echo 'PROGRAM     :' $(PROGRAM)
	@echo 'SRCDIRS     :' $(SRCDIRS)
	@echo 'HEADERS     :' $(HEADERS)
	@echo 'SOURCES     :' $(SOURCES)
	@echo 'SRC_CXX     :' $(SRC_CXX)
	@echo 'OBJS        :' $(OBJS)
	@echo 'DEPS        :' $(DEPS)
	@echo 'DEPEND      :' $(DEPEND)
	@echo 'DEPEND.d    :' $(DEPEND.d)
	@echo 'COMPILE.c   :' $(COMPILE.c)
	@echo 'COMPILE.cxx :' $(COMPILE.cxx)
	@echo 'link.c      :' $(LINK.c)
	@echo 'link.cxx    :' $(LINK.cxx)

#############################################################################