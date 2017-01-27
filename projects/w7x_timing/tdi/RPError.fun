FUN PUBLIC RPError(optional in _idx) {
  _idx = present(_idx) ? _idx : 1;
  return(w7x_timing_lib->getStatus(val(_idx)));
}
