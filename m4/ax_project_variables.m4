
#NAME := $(or $(foreach x,$(project_LISTS),\
#					   $(if $(filter $($x_TARGETS),\
#									 $(MAKECMDGOALS)),\
#									 $(lastword $(value $x)),)),\
#			 $(project_DEFAULT))


# _flt = $(subst ' ',_,$(subst .,_,$1))

# _ven = $(or ${VENDOR},\
#			${$(call _flt,$1)_VENDOR})

# _ver = $(or $(filter-out ${PACKAGE_VERSION},${VERSION}),\
#			${$(call _ven,$1)_$(call _flt,$1)_VERSION},\
#			${$(call _flt,$1)_VERSION},\
#			${$(subst $(call _ven,$1)_,,$1)_VERSION},\
#			$(shell echo $(lastword $(subst _, ,$1)) | \
#			  $(SED) 's/[^0-9.]*\([0-9.]*\).*/\1/'),\
#			${VERSION})

# _nam = $(subst $(call _ven,$1)_,,$(subst _$(call _ver,$1),,$1))
# _var = $(or $($(call _flt,$(VENDOR)_$(NAME)_$(VERSION)_$1)),\
#			$($(call _flt,$(NAME)_$(VERSION)_$1)),\
#			$($(call _flt,$(VENDOR)_$(NAME)_$1)),\
#			$($(call _flt,$(NAME)_$1)))

# $(eval override VERSION :=$(strip $(call _ver,$(NAME))))
# $(eval override VENDOR  :=$(strip $(call _ven,$(NAME))))
# $(eval override NAME    :=$(strip $(call _nam,$(NAME))))
# $(foreach x,$(project_VARIABLES),$(eval override $x:=$(call _var,$x)))


AC_DEFUN([AX_PROJECT_VARIABLES],[
 AX_PUSH_LOCAL([ax_project_variables])
 AS_VAR_READ([PROJECT_VARIABLES],[

NAME := \$(or \$(foreach x,\$(project_LISTS),\\\\
					   \$(if \$(filter \$(\$x_TARGETS),\\\\
									 \$(MAKECMDGOALS)),\\\\
									 \$(lastword \$(value \$x)),)),\
			 \$(project_DEFAULT))

_flt = \$(subst ' ',_,\$(subst .,_,\$[]1))
_ven = \$(or \${VENDOR},\\\\
			\${\$(call _flt,\$[]1)_VENDOR})
_ver = \$(or \$(filter-out \${PACKAGE_VERSION},\${VERSION}),\\\\
			\${\$(call _ven,\$[]1)_\$(call _flt,\$[]1)_VERSION},\\\\
			\${\$(call _flt,\$[]1)_VERSION},\\\\
			\${\$(subst \$(call _ven,\$[]1)_,,\$[]1)_VERSION},\\\\
			\$(shell echo \$(lastword \$(subst _, ,\$[]1)) | \\\\
			  \$(SED) 's/[[^0-9.]]*\\\\([[0-9.]]*\\\\).*/\\\\1/'),\\\\
			\${VERSION})
_nam = \$(subst \$(call _ven,\$[]1)_,,\$(subst _\$(call _ver,\$[]1),,\$[]1))
_var = \$(or \$(\$(call _flt,\$(VENDOR)_\$(NAME)_\$(VERSION)_\$[]1)),\\\\
			\$(\$(call _flt,\$(NAME)_\$(VERSION)_\$[]1)),\\\\
			\$(\$(call _flt,\$(VENDOR)_\$(NAME)_\$[]1)),\\\\
			\$(\$(call _flt,\$(NAME)_\$[]1)))

\$(eval override VERSION :=\$(strip \$(call _ver,\$(NAME))))
\$(eval override VENDOR  :=\$(strip \$(call _ven,\$(NAME))))
\$(eval override NAME    :=\$(strip \$(call _nam,\$(NAME))))
\$(foreach x,\$(project_VARIABLES),\$(eval override \$x:=\$(call _var,\$x)))

 ])
 AC_SUBST([PROJECT_VARIABLES])
 m4_ifdef([AM_SUBST_NOTMAKE], [AM_SUBST_NOTMAKE([PROJECT_VARIABLES])])
 AX_POP_LOCAL([ax_project_variables])
])


dnl ////////////////////////////////////////////////////////////////////////////
dnl // Utility functions

AX_DEFUN_LOCAL([ax_project_variables],[AS_BANNER],[
		  AS_ECHO
		  AS_BOX([// $[]1 //////], [\/])
		  AS_ECHO
		 ])


AX_DEFUN_LOCAL([ax_project_variables],[AS_VAR_READ],[
read -d '' $1 << _as_read_EOF
$2
_as_read_EOF
])
