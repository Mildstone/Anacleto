FUN PUBLIC RPDefault(optional in _delay, optional in _width, optional in _period, optional in _times, optional in _cycle, optional in _repeat){
  _status = RPProg(_delay,_width,_period,_times,_cycle,_repeat);
  IF(NOT(AND(_status,1BU)))
    return(_status);
  w7x_timing_lib->save();
  return(1);  
}
