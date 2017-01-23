FUN PUBLIC RPSequence(in _delay, in _width, in _period, in _count, in _cycle, in _repeat){
  _delay  = QUADWORD_UNSIGNED(_delay);
  _width  = LONG_UNSIGNED(_width);
  _period = LONG_UNSIGNED(_period);
  _count  = LONG_UNSIGNED(_count);
  _cycle  = QUADWORD_UNSIGNED(_cycle);
  _repeat = LONG_UNSIGNED(_repeat);
  _times  = QUADWORD_UNSIGNED(_times); 
  return(w7x_timing_lib->makeSequence(ref(_delay),ref(_width),ref(_period),ref(_cycle),ref(_repeat),ref(_count),ref(_times)));
}
