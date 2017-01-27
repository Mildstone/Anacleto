FUN PUBLIC RPSequence(optional in _delay, optional in _width, optional in _period, in _times, optional in _cycle, optional in _repeat){
  write(*,text(present(_delay)));
  _delay  = present(_delay)  ? QUADWORD_UNSIGNED(_delay)   : *;
  _period = present(_period) ? LONG_UNSIGNED(_period)      : *;
  _width  = present(_width)  ? LONG_UNSIGNED(_width)       : *;
  _cycle  = present(_cycle)  ? QUADWORD_UNSIGNED(_cycle)   : *;
  _repeat = present(_repeat) ? LONG_UNSIGNED(_repeat)      : *;
  _count  = present(_times)  ? LONG_UNSIGNED(SIZE(_times)) : 0L;
  _times  = present(_times)  ? QUADWORD_UNSIGNED(_times)   : *;
  return(w7x_timing_lib->makeSequence(ref(_delay),ref(_width),ref(_period),ref(_cycle),ref(_repeat),ref(_count),ref(_times)));
}
