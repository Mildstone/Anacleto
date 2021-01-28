include $(top_srcdir)/Common.mk
include $(top_srcdir)/conf/kscripts/python.mk
include $(top_srcdir)/conf/kscripts/ext_mdsplus.mk



if EXT_MDSPLUS
bin_PROGRAMS = mds-test
mds_test_SOURCES      = mds_test.cpp
mds_test_CPPFLAGS     = $(MDSCPPFLAGS)
mds_test_LDFLAGS      = $(MDSLDFLAGS) -Wl,-rpath,${MDS_LIBDIR}

# further python script with program
pythondir = $(PYTHON_USERBASE)
mds_test_PYTHON = mds-test.py
mds_testdir = /tmp/$(PACKAGE)

## this is called before link
## mds_test_DEPENDENCIES = ext-mdsplus

## this is done before compiling code
$(mds_test_OBJECTS): ext-mdsplus

CLEANFILES = test_model.characteristics  test_model.datafile  test_model.tree

else
$(warning ext sources for Mdsplus are disabled, please reconfigure)
endif
