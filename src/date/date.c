#include "date/date.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

Date date_now() {
  struct timeval start;
  gettimeofday(&start, NULL);

  time_t t = time(NULL);
  struct tm tm = *localtime(&t);


  long usec = start.tv_usec;
  double milliseconds_static = usec;

  double microseconds = start.tv_usec;
  double milliseconds = microseconds * 0.001f;
  uint32_t timestamp = (uint32_t)start.tv_sec;
  uint32_t year = tm.tm_year + 1900;
  uint8_t month = tm.tm_mon + 1;
  uint8_t day = tm.tm_mday;
  uint8_t hour = tm.tm_hour;
  uint8_t minute = tm.tm_min;
  double seconds = tm.tm_sec;

  return ((Date){seconds, milliseconds, milliseconds_static, microseconds, hour, minute, day, month,
                 year, timestamp});
}

Date date_diff(Date *a, Date *b) {
  double microseconds = a->microseconds - b->microseconds;
  double milliseconds = a->milliseconds - b->milliseconds;
  double milliseconds_static = ((double)(a->milliseconds_static - b->milliseconds_static) / 1000000 + (double)(a->timestamp - b->timestamp)) * 1000.0f;
  uint32_t timestamp = a->timestamp - b->timestamp;
  uint32_t year = a->year - b->year;
  uint8_t month = a->month - b->month;
  uint8_t day = a->day - b->day;
  uint8_t hour = a->hour - b->hour;
  uint8_t minute = a->minute - b->minute;
  double seconds = milliseconds_static / 1000.0f;//a->seconds - b->seconds;

  return ((Date){seconds, milliseconds, milliseconds_static, microseconds, hour, minute, day, month,
                 year, timestamp});
}

void date_copy(Date* dest, Date* src) {
  dest->day = src->day;
  dest->hour = src->hour;
  dest->microseconds = src->microseconds;
  dest->milliseconds = src->milliseconds;
  dest->milliseconds_static = src->milliseconds_static;
  dest->minute = src->minute;
  dest->month = src->month;
  dest->seconds = src->seconds;
  dest->timestamp = src->timestamp;
}

void date_format(Date *date, char **str) {
  char *buffer = *str;
  const char *templ = "(%d) %d/%d/%d %d:%d:%d:%1.2f";
  buffer = (char *)realloc(buffer, (strlen(templ) + 256) * sizeof(char));
  sprintf(buffer, templ, date->timestamp, date->year, date->month, date->day,
          date->hour, date->minute, (int)date->seconds, date->milliseconds);

  *str = buffer;
}