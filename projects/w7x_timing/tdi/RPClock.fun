FUN PUBLIC RPClock(optional in _delay, optional in _width, optional in _period, in _count, optional in _cycle, optional in _repeat){
  _delay  = present(_delay)  ? QUADWORD_UNSIGNED(_delay) : 0QU;
  _period = present(_period) ? LONG_UNSIGNED(_period)    : 20LU;
  _width  = present(_width)  ? LONG_UNSIGNED(_width)     : 0LU;
  _cycle  = present(_cycle)  ? QUADWORD_UNSIGNED(_cycle) : 0QU;
  _repeat = present(_repeat) ? LONG_UNSIGNED(_repeat)    : 1LU;
  _count  = LONG_UNSIGNED(_count);
  return(w7x_timing_lib->makeClock(ref(_delay),ref(_width),ref(_period),ref(_cycle),ref(_repeat),ref(_count)));
}
