FUN PUBLIC RPParams(OPTIONAL OUT _times){
  _delay  = 0QU;
  _period = 0LU;
  _width  = 0LU;
  _burst  = 0QU;
  _cycle  = 0QU;
  _repeat = 0LU;
  _count  = 0LU;
  w7x_timing_lib->getParams(ref(_delay),ref(_width),ref(_burst),ref(_period),ref(_cycle),ref(_repeat),ref(_count));
  IF(PRESENT(_times)) {
    _times = ZERO(_count,0QU);
    if (SIZE(_times)>0)
      w7x_timing_lib->getTimes(val(0LU),val(SIZE(_times)),ref(_times));
  }
  return([_delay,_width,_period,_burst,_cycle,_repeat,_count]);
}
