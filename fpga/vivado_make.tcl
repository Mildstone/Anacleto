# ////////////////////////////////////////////////////////////////////////// //
#
# This file is part of the anacleto project.
# Copyright 2018 Andrea Rigoni Garola <andrea.rigoni@igi.cnr.it>.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# ////////////////////////////////////////////////////////////////////////// //



global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)


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

