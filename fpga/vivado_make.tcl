global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)

## lremove ?-all? list pattern
##
## Removes matching elements from a list, and returns a new list.
#proc lremove {args} {
#	if {[llength $args] < 2} {
#	   puts stderr {Wrong # args: should be "lremove ?-all? list pattern"}
#	}
#	set list [lindex $args end-1]
#	set elements [lindex $args end]
#	if [string match -all [lindex $args 0]] {
#	   foreach element $elements {
#		   set list [lsearch -all -inline -not -exact $list $element]
#	   }
#	} else {
#	   # Using lreplace to truncate the list saves having to calculate
#	   # ranges or offsets from the indexed element. The trimming is
#	   # necessary in cases where the first or last element is the
#	   # indexed element.
#	   foreach element $elements {
#		   set idx [lsearch $list $element]
#		   set list [string trim \
#			   "[lreplace $list $idx end] [lreplace $list 0 $idx]"]
#	   }
#	}
#	return $list
#}
#rename ::source ::theRealSource
#proc ::source args {
#	set new_args [list]
#	foreach el [split $args " "] {
#	  if { $el eq "-notrace" } { continue }
#	  lappend new_args $el
#	 }
#	uplevel 1 ::theRealSource $new_args
#}

source -notrace $top_srcdir/fpga/vivado_socdev_utils.tcl
source -notrace $top_srcdir/fpga/vivado_socdev_env.tcl
source -notrace $top_srcdir/fpga/vivado_socdev_makeutils.tcl
catch { namespace import ::tclapp::socdev::makeutils::* }

proc make_reload {} {
 variable top_srcdir
 source -notrace $top_srcdir/fpga/vivado_socdev_listutils.tcl
 source -notrace $top_srcdir/fpga/vivado_socdev_utils.tcl
 source -notrace $top_srcdir/fpga/vivado_socdev_env.tcl
 source -notrace $top_srcdir/fpga/vivado_socdev_makeutils.tcl
 source  $top_srcdir/fpga/write_anacleto_prj.tcl
}

catch {
  source -notrace $top_srcdir/fpga/vivado_socdev_listutils.tcl
  namespace import ::tclapp::socdev::listutils::*
}



proc make { args } {
  for {set i 0} {$i < [llength $args]} {incr i} {
    set option [string trim [lindex $args $i]]
    switch -regexp -- $option {
      "-paths"    { incr i; puts [lindex $args $i] }
      "-force"    {  }
      default {
	# is incorrect switch specified?
	if { [regexp {^-} $option] } {
	  puts "ERROR Unknown option\n"
	  return
	}
	set command $option
      }
    }
  }
  ::tclapp::socdev::makeutils::make_$command
#  if { [catch { ::tclapp::socdev::makeutils::make_$command }] } {
#    puts "ERROR executing make $command"
#  }
}

if { [llength $argv] > 0 } { make $argv }

