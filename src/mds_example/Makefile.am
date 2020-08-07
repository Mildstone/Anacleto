include $(top_srcdir)/Common.mk
include $(top_srcdir)/conf/kscripts/ext_mdsplus.mk



if EXT_MDSPLUS
bin_PROGRAMS = mds-test
mds_test_SOURCES      = mds_test.cpp
mds_test_CPPFLAGS     = $(MDSCPPFLAGS)
mds_test_LDFLAGS      = $(MDSLDFLAGS) -Wl,-rpath,${MDS_LIBDIR}

## this is called before link
## mds_test_DEPENDENCIES = ext-mdsplus

## this is done before compiling code
$(mds_test_OBJECTS): ext-mdsplus

debug: ##@mdsplus debug test program
debug:
	@ gdbserver localhost:5677 mds-test


PYTHON_PACKAGES = debugpy
debugpy: ##@mdsplus debug test program
debugpy:
	@ gdbserver localhost:5677 python -m debugpy --listen 5678 --wait-for-client $(srcdir)/mds-test.py


else
$(warning ext sources for Mdsplus are disabled, please reconfigure)
endif
