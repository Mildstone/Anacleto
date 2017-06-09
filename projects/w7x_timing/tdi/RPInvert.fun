FUN PUBLIC RPInvert(IN _list){
  _byte = 0BU;
  for(_i=0;_i<size(_list);_i++) _byte = IOR(_byte,4<<_list[_i]);
  return(w7x_timing_lib->invert(val(_byte)));
}
