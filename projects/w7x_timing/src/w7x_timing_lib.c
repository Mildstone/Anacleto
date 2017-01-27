#include <string.h>
#include <time.h>
#include "w7x_timing.h"

static struct timespec t = { 0, 100 };
#define CHECK_INPUTS \
  uint64_t delay, cycle; \
  uint32_t width, period, repeat, count; \
  if (!width_p && !period_p && !cycle_p && !repeat_p && !count_p) { \
    delay  = delay_p ? *delay_p : 60000000; \
    cycle  = 0; \
    width  = 5; \
    period = 10; \
    repeat = 0; \
    count  = 0; \
  } else { \
    delay  = delay_p  ? *delay_p  : 0; \
    repeat = repeat_p ? *repeat_p : 1; \
    if (period_p) { \
      period = *period_p; \
      width = width_p ? *width_p : period/2; \
    } else { \
      width = width_p ? *width_p : 5; \
      period = width*2; \
    } \
    repeat = repeat_p ? *repeat_p : 1; \
    count = count_p ? *count_p : 0; \
  }





struct w7x_timing *dev = NULL;

int getDev() {
    if (dev) return C_OK;
    dev = w7x_timing_get_device(0);
    if (dev) return C_OK;
    printf("ERROR: unable to get device\n");
    return C_DEV_ERROR;
}

int getStatus(int idx) {
  if (idx >= MAX_STATUS || idx < 0) {
    printf("ERROR: IDX < 0 or IDX > %lu",MAX_STATUS-1);
    return -1;
  }
  uint8_t status, i;
  if (getDev()) return -1;
  status = dev->r_status[idx];
  switch (status & STATUS_MASK) {
    case 0:
      break;
    case IDLE:
      printf("IDLE");
      break;
    case ARMED:
      printf("ARMED");
      break;
    case WAITING_DELAY:
      printf("WAITING_DELAY");
      break;
    case WAITING_SAMPLE:
      printf("WAITING_SAMPLE");
      break;
    case WAITING_LOW:
      printf("WAITING_LOW");
      break;
    case WAITING_HIGH:
      printf("WAITING_HIGH");
      break;
    case WAITING_REPEAT:
      printf("WAITING_REPEAT");
      break;
    default:
      printf("UNDEFINED(0x%02X)",status);
  }
  if (idx>0)
    printf("\n");
  else if (status&1)
    printf(" - ok\n");
  else {
    printf(" - errors:\n");
    for (i = 1 ; i < 8 ; i++)
      if (!getStatus(i))
        break;
  }
  return status;
}

int getState() {
  return getStatus(0);
}

int setParams(uint64_t delay, uint32_t width, uint32_t period, uint64_t cycle, uint32_t repeat, uint32_t count) {
  printf("DELAY: %llu, WIDTH: %u, PERIOD: %u, COUNT: %u, CYCLE: %llu, REPEAT: %u\n", delay, width, period, count, cycle, repeat);
  if (period < 2){
    printf("ERROR: PERIOD < 2\n");
    return C_PARAM_ERROR;
  }
  if(width >= period) {
    printf("ERROR: WIDTH >= PERIOD\n");
    return C_PARAM_ERROR;
  }
  if (getDev()) return C_DEV_ERROR;
  dev->w_count  = 0;
  dev->w_delay  = delay;
  dev->w_width  = width;
  dev->w_period = period;
  dev->w_cycle  = cycle;
  dev->w_repeat = repeat;
  return C_OK;
}

int makeClock(uint64_t *delay_p, uint32_t *width_p, uint32_t *period_p, uint64_t *cycle_p, uint32_t *repeat_p, uint32_t *count_p){
    printf("MAKE CLOCK: ");
    uint64_t time;
    CHECK_INPUTS
    if (cycle_p) {
      cycle = *cycle_p;
      if (cycle < period * count){
        printf("ERROR: CYCLE < PERIOD * COUNT\n");
        return C_PARAM_ERROR;
      }
    } else
      cycle = period * count;
    int i,c_status = setParams(delay, width, period, cycle, repeat, count);
    if(c_status) return c_status;
    time = 0;
    for(i = 0; i < count; i++) {
	dev->w_times[i] = time;
        time = time + period;
    }
    dev->w_count = count;
    return C_OK;
}

int makeSequence(uint64_t *delay_p, uint32_t *width_p, uint32_t *period_p, uint64_t *cycle_p, uint32_t *repeat_p, uint32_t *count_p, const uint64_t *times){
    printf("MAKE SEQUENCE: ");
    if (!times || !count_p) {
      printf("ERROR: TIMES = NULL");
      return C_PARAM_ERROR;
    }
    CHECK_INPUTS
    if (count < 1) {
      printf("ERROR: COUNT < 1\n");
      return C_PARAM_ERROR;
    }
    if (cycle_p) {
      cycle = *cycle_p;
      if (cycle < times[count-1] + period){
        printf("ERROR: CYCLE < TIMES[COUNT-1] + PERIOD\n");
        printf("       TIMES[end]: %llu\n", times[count-1]);
        return C_PARAM_ERROR;
      }
    } else
      cycle = times[count-1] + period;
    printf("TIMES: [%llu", times[0]);
    int i;
    for(i = 1; i < count; i++){
       printf(", %llu", times[i]);
       if(times[i] < times[i-1] + period) {
         printf("ERROR: TIMES[%ld] - TIMES[%ld] < PERIOD\n",i,i-1);
         return C_PARAM_ERROR;
       }
    }
    printf("],\n");
    int c_status = setParams(delay, width, period, cycle, repeat, count);
    if(c_status) return c_status;
    memcpy(dev->w_times, times, count*sizeof(uint64_t));
    dev->w_count = count;
    return C_OK;
}

int trig() {
    if (getDev()) return C_DEV_ERROR;
    dev->w_trig = 1;
    return C_OK;
}

int arm() {
    int i;
    if (getDev()) return C_DEV_ERROR;
    dev->w_init  = 0;
    dev->w_clear = 1;
    for ( i = 0 ; i < 10 ; i++)
       if (!dev->r_status[1])
         break;
       nanosleep(&t,0);
    dev->w_clear = 0;
    dev->w_init  = 1;
    return C_OK;
}

int disarm() {
    if (getDev()) return C_DEV_ERROR;
    dev->w_init = 0;
    return C_OK;
}

