include $(top_srcdir)/Common.mk
include $(top_srcdir)/conf/kscripts/tensorflow.mk

SUBDIRS = sh_template

if ENABLE_NODEJS
SUBDIRS += nodejs
endif

if ENABLE_QT
SUBDIRS += qt_example
endif

bin_PROGRAMS = main
main_SOURCES = main.cpp



DOCKER_TARGETS = prova-%

prova-%: DOCKER_CONTAINER = prova
prova-%: DOCKER_IMAGE     = debian:latest

prova-init: DOCKER_CONTAINER = prova
prova-init: DOCKER_URL = $(srcdir)/docker_build
prova-init: DOCKER_DOCKERFILE = $(srcdir)/docker_build/Dockerfile-git
prova-init:
	@ :;

prova-shell: 
	@ /bin/bash


##    .########.########.##....##..######...#######..########..########.##........#######..##......##  
##    ....##....##.......###...##.##....##.##.....##.##.....##.##.......##.......##.....##.##..##..##  
##    ....##....##.......####..##.##.......##.....##.##.....##.##.......##.......##.....##.##..##..##  
##    ....##....######...##.##.##..######..##.....##.########..######...##.......##.....##.##..##..##  
##    ....##....##.......##..####.......##.##.....##.##...##...##.......##.......##.....##.##..##..##  
##    ....##....##.......##...###.##....##.##.....##.##....##..##.......##.......##.....##.##..##..##  
##    ....##....########.##....##..######...#######..##.....##.##.......########..#######...###..###.  

DOWNLOADS = tensorflow

tensorflow: ##@ext tensorflow
tensorflow_URL    = https://github.com/tensorflow/tensorflow.git
tensorflow_BRANCH = master

# python packages needed for tf
PYTHON_PACKAGES = pip six numpy wheel mock
tf_DOCKER_IMAGE = tensorflow/tensorflow:nightly-devel-py3

DOCKER_TARGETS += tf-%
tf-init: ##@tf build process
tf-init: DOCKER_IMAGE = $(tf_DOCKER_IMAGE)
tf-init: DOCKER_CONTAINER = tf-build
tf-init: | tensorflow pip-install
	@ cd tensorflow;

tf-%: export DOCKER_CONTAINER = tf-build

tensorflow/.tf_configure.bazelrc: | tf-init
	@ cd tensorflow; ./configure

tf-configure: tensorflow/.tf_configure.bazelrc

tf-build: tf-configure | tf-init
	@ cd tensorflow; bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package

tf-shell:
	/bin/bash















