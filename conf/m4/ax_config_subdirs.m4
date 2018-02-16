m4_define([AX_CONFIG_FILES],
[AC_CONFIG_FILES(]
[m4_map_args_w([$1],[m4_bpatsubst(__file__,[configure.ac],[])],[],[ ])]
[)])

AC_DEFUN([AX_CONFIG_SUBDIRS],[
AS_VAR_SET([CONFIG_SUBDIRS],["m4_normalize([$1])"])
AC_SUBST([CONFIG_SUBDIRS])
m4_map_args_w([$1],[m4_sinclude(],[/configure.ac)])
])
