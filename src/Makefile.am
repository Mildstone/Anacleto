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

export DOCKER_CONTAINER
export DOCKER_IMAGE

DSHELL = $(top_srcdir)/conf/dk.sh
$(DOKER_TARGETS): SHELL = $(DSHELL)

docker-%:
	@ $(info [docker] $*)
	@ . $(DSHELL) $*


DOKER_TARGETS = prova

prova: DOCKER_IMAGE     = debian:latest
prova: DOCKER_CONTAINER = prova_dk
prova:
	@ $(info building $@)
	  ls -la

DOWNLOADS = tensorflow

tensorflow: ##@ext tensorflow
tensorflow_URL    = https://github.com/tensorflow/tensorflow.git
tensorflow_BRANCH = master

# python packages needed for tf
PYTHON_PACKAGES = pip six numpy wheel mock
tf_DOCKER_IMAGE = tensorflow/tensorflow:nightly-devel-py3

DOKER_TARGETS += tf-init
tf-init: ##@tf build process
tf-init: DOCKER_IMAGE = $(tf_DOCKER_IMAGE)
tf-init: DOCKER_CONTAINER = tf-build
tf-init: | tensorflow pip-install
	@ cd tensorflow;

tensorflow/.tf_configure.bazelrc: | tf-init
	@ cd tensorflow; ./configure

tf-configure: tensorflow/.tf_configure.bazelrc

tf-build: tf-configure | tf-init
	@ cd tensorflow; bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package

shell: prova
	@ /bin/sh
















