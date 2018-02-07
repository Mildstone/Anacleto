include $(top_srcdir)/Common.mk

SUBDIRS = sh_template

if ENABLE_NODEJS
SUBDIRS += nodejs
endif

if ENABLE_QT
SUBDIRS += qt_example
endif

bin_PROGRAMS = main
main_SOURCES = main.cpp
