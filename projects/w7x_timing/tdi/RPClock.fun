FUN PUBLIC RPClock(optional in _delay, optional in _width, optional in _period, optional in _count, optional in _cycle, optional in _repeat){
  _delay  = present(_delay)  ? QUADWORD_UNSIGNED(_delay) : *;
  _period = present(_period) ? LONG_UNSIGNED(_period)    : *;
  _width  = present(_width)  ? LONG_UNSIGNED(_width)     : *;
  _cycle  = present(_cycle)  ? QUADWORD_UNSIGNED(_cycle) : *;
  _repeat = present(_repeat) ? LONG_UNSIGNED(_repeat)    : *;
  _count  = present(_count)  ? LONG_UNSIGNED(_count)     : *;
  return(w7x_timing_lib->makeClock(ref(_delay),ref(_width),ref(_period),ref(_cycle),ref(_repeat),ref(_count)));
}
