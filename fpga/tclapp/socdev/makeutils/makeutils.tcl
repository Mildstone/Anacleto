
package require Tcl 8.5

namespace eval ::tclapp::socdev::makeutils {

	# Allow Tcl to find tclIndex
	variable home [file join [pwd] [file dirname [info script]]]
	if {[lsearch -exact $::auto_path $home] == -1} {
	lappend ::auto_path $home
	}

}
package provide ::tclapp::socdev::makeutils 1.0
