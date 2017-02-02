FUN PUBLIC RPParams(){
  _delay  = 0QU;
  _period = 0LU;
  _width  = 0LU;
  _cycle  = 0QU;
  _repeat = 0LU;
  _count  = 0LU;
  w7x_timing_lib->getParams(ref(_delay),ref(_width),ref(_period),ref(_cycle),ref(_repeat),ref(_count));
  return([_delay,_width,_period,_count,_cycle,_repeat]);
}
