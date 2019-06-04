# //////////////////////////////////////////////////////////////////////////// #
# //  EXAMPLE  /////////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #
#
include $(top_srcdir)/Common.mk

if ENABLE_QT
include $(top_srcdir)/conf/kscripts/qtdesktop.mk
endif

PRO = qt_example.pro

## TODO: make this smarter defining sources here and then passing it to qt
EXTRA_DIST = $(PRO) \
             mainwindow.ui \
             mainwindow.h \
             main.cpp \
             mainwindow.cpp

all: $(TARGET)
clean: clean-local
