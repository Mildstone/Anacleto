include $(top_srcdir)/Common.mk
include $(top_srcdir)/conf/kscripts/ext_mdsplus.mk


if EXT_MDSPLUS
bin_PROGRAMS = mds-test
mds_test_SOURCES      = mds_test.cpp
mds_test_CPPFLAGS     = $(MDS_CPPFLAGS)
mds_test_LDFLAGS      = $(MDS_LDFLAGS) -Wl,-rpath,${MDS_LIBDIR}
EXTRA_mds_test_DEPENDENCIES = ext-mdsplus
else
$(warning ext sources for Mdsplus are enabled, please reconfigure)
endif
