


AC_DEFUN([AX_TARGET_SELFHELP],[
  AC_PUSH_LOCAL([ax_target_selfhelp])
  SET_SELFHELP
  AC_POP_LOCAL([ax_target_selfhelp])
])


AC_DEFUN_LOCAL([ax_target_selfhelp],[SET_SELFHELP],[
AS_VAR_READ([TARGET_SELFHELP],[

#GREEN  := \$(shell tput -Txterm setaf 2)
#WHITE  := \$(shell tput -Txterm setaf 7)
#YELLOW := \$(shell tput -Txterm setaf 3)
#RESET  := \$(shell tput -Txterm sgr0)

#HELP_FUNC = \\\\
    #%help; \\\\
    #while(<>) { \\\\
	#if(/^(\[a-z0-9_-\]+):.*\\#\\#(?:@(\\w+))?\\s(.*)\$\$/) { \\\\
	    #push(@{$$help{\$\$2}}, \[\$\$\$1, \$\\\\$3]); \\\\
	#} \\\\
    #}; \\\\
    #print "usage: make [target]\n\n"; \\\\
    #for ( sort keys %help ) { \\\\
	#print "\${YELLOW}\$\$_\${WHITE}:\n"; \\\\
	#printf("  %-20s %s\n", \$\$_->[0], \$\$_->[1]) for @{\$\$help{\$\$_}}; \\\\
	#print "\n"; \\\\
    #}

#help:           ##@miscellaneous Show this help.
	#@perl -e '\$(HELP_FUNC)' \$(MAKEFILE_LIST)

])
 AC_SUBST([TARGET_SELFHELP])
 m4_ifdef([AM_SUBST_NOTMAKE], [AM_SUBST_NOTMAKE([TARGET_SELFHELP])])
])



AC_DEFUN_LOCAL([ax_target_selfhelp],[AS_VAR_READ],[
read -d '' $1 << _as_read_EOF
$2
_as_read_EOF
])

