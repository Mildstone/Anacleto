FUN PUBLIC RPReInit(optional in _delay){
  _delay = IF_ERROR(KIND(_delay)>0, 0BU) ? QUADWORD_UNSIGNED(_delay) : *;
  return(w7x_timing_lib->reinit(ref(_delay)));
}
