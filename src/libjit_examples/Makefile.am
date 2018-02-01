include $(top_srcdir)/Common.mk
# include $(top_srcdir)/conf/kscripts/ext_libjit.mk


AM_CFLAGS   = -I$(top_builddir)/ext/libjit/include -I. -I$(srcdir)
AM_CXXFLAGS = -I$(top_builddir)/ext/libjit/include -I. -I$(srcdir)

noinst_PROGRAMS = t1 t2 t3 t4 t5

t4_SOURCES = t4.cpp
t4_LDADD = $(top_builddir)/ext/libjit/jitplus/libjitplus.la $(top_builddir)/ext/libjit/jit/libjit.la

LDADD = $(top_builddir)/ext/libjit/jit/libjit.la
DEPENDENCIES = $(top_builddir)/ext/libjit/jit/libjit.la
