
proc generate { drv_handle } {
  set os_core_v    [string map {. _} [get_property "VERSION" [get_os]]]
  set os_core_name "[get_os]_v${os_core_v}"

  # set variables
  set drv_name [common::get_property NAME $drv_handle]

  puts " ,----------------------------------- "
  puts " |,---------------------------------- "
  puts " || "
  puts " || GENERATE: $drv_name"
  puts " || "
  puts " |`---------------------------------- "
  puts " `----------------------------------- "

}
