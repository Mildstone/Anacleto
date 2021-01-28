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


rename source Tcl_source
proc source { args } {  
    array set options { -encoding "utf-8" }
    set tags [list]
    set current_parser [lindex [split [version] " "] 0]

    # // IS EMPTY STRING //
    proc is_empty {string} {
        expr {![binary scan $string c c]}
    }

    # // IS NON-EMPTY STRING //
    proc not_empty {string} {
        expr {![is_empty $string]}
    }

    # // HELP //
    proc help {} {
            puts {
  source

  Description: 
  Add tracing of commands

  Syntax: 
  source  [-encoding <arg>] [-notrace] [-quiet] [-verbose] <file>

  Usage: 
    Name         Description
    ------------------------
    [-encoding]  specify the encoding of the data stored in filename
    [-notrace]   disable tracing of sourced commands
    [-quiet]     Ignore command errors
    [-verbose]   Suspend message limits during command execution
    <file>       script to source

  Categories: }
    } 

    
    while {[llength $args]-1} {
      switch -glob -- [lindex $args 0] {
          -h* { help }
          -encoding {set args [lassign $args - options(-encoding)]}
          -notrace { lappend tags "-notrace" ; set args [lrange $args 1 end] }
          -quiet   { lappend tags "-quiet" ; set args   [lrange $args 1 end] }
          -verbose { lappend tags "-verbose" ; set args [lrange $args 1 end] }
          -*      {error "unknown option [lindex $args 0]"}
          default break
      } 
    }
    foreach {a b} [array get options] { lappend lout $a $b }
    set filename [lindex $args [llength $args]-1 ]
    
    if { [string tolower $current_parser] == "xsct" } {
      set tags ""
    }
    if {[not_empty $filename]} {
      puts "\[ LOADING SOURCE \] Tcl_source $tags $lout $filename"
      uplevel 1 Tcl_source $tags $lout $filename;
    } else { help }
}




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

