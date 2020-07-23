include $(top_srcdir)/Common.mk

SUBDIRS = sh_template parse_examples project_variables mds_example jp_notebook

if ENABLE_NODEJS
SUBDIRS += nodejs
endif

if ENABLE_QT
SUBDIRS += qt_example
endif

bin_PROGRAMS = autoconf-bootstrap-example
noinst_PROGRAMS = autoconf-bootstrap-example
autoconf_bootstrap_example_SOURCES = main.cpp



DOCKER_TARGETS = prova-%
DIRECTORIES = cntmp

prova-%: DOCKER_CONTAINER = prova
prova-%: DOCKER_IMAGE     = debian:latest

prova-init: DOCKER_CONTAINER = prova
prova-init: DOCKER_URL = $(srcdir)/docker_build
prova-init: DOCKER_DOCKERFILE = $(srcdir)/docker_build/Dockerfile-git
prova-init: DOCKER_MOUNTS = cntmp:/usr/local
prova-init: cntmp
	@ :;

prova-shell: 
	@ /bin/bash

















