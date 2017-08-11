
global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)



# overload import
# source -notrace $top_srcdir/fpga/write_project_tcl_import_files.tcl

proc unix_path { file } {
 return [string trim [string map {\\ /} $file]]
}

proc get_abs_path { file } {
  return [string trim [file normalize [string map {\\ /} $file]]]
}


# Get relative path to target file from current path
# First argument is a file name, second a directory name (not checked)
proc get_rel_path {file currentpath} {
  set cc [file split [file normalize $currentpath]]
  set tt [file split [file normalize $file]]
  if {![string equal [lindex $cc 0] [lindex $tt 0]]} {
      # not on *n*x then
      return -code error "$file not on same volume as $currentpath"
  }
  while {[string equal [lindex $cc 0] [lindex $tt 0]] && [llength $cc] > 0} {
      # discard matching components from the front
      set cc [lreplace $cc 0 0]
      set tt [lreplace $tt 0 0]
  }
  set prefix ""
  if {[llength $cc] == 0} {
      # just the file name, so file is lower down (or in same place)
      set prefix "."
  }
  # step up the tree
  for {set i 0} {$i < [llength $cc]} {incr i} {
      append prefix " .."
  }
  # stick it all together (the eval is to flatten the file list)
  return [eval file join $prefix $tt]
}




## ////////////////////////////////////////////////////////////////////////// ##
## /// DEBUG          /////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

proc get_funid { {ns ""} {fun ""} } {
  if {$ns eq ""}  { set ns [namespace current] }
  if {$fun eq ""} { set fun [lindex [info level 0] 0] }
  #  puts "get_fungid $ns $fun"
  set list [info commands ${ns}::*]
  set count 0
  foreach fi $list {
    set fs [lindex [split $fi ":"] end]
    #    puts "$fi $fs"
    if {[string equal $fi ::$fun] || [string equal $fi $fun] || [string equal $fs $fun]} {return $count}
    incr count
  }
  # send_msg_id AnacletoUtils-1 WARNING "function id not found"
  return "unknown"
}


proc get_msgid { {ns ""} {fun ""} } {
  if {$ns eq ""}  { set ns [namespace current] }
  if {$fun eq ""} { set fun [lindex [info level 0] 0] }
  set ns_und [string map -nocase { "::" "_" } $ns]
  set ns_msg [join [lrange [split $ns_und "_"] end-1 end] "_"]
  return ${ns_msg}-[get_funid $ns $fun]
}
