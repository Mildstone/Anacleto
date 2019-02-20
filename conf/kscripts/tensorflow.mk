

# get tensorflow include dirs, see https://www.tensorflow.org/how_tos/adding_an_op/
# This is for CMAKE
# execute_process(COMMAND python3 -c "import tensorflow; print(tensorflow.sysconfig.get_include())" OUTPUT_VARIABLE Tensorflow_INCLUDE_DIRS)
# execute_process(COMMAND python3 -c "import tensorflow as tf; print(' '.join(tf.sysconfig.get_link_flags()), end='')" OUTPUT_VARIABLE Tensorflow_LINK_FLAGS)
# execute_process(COMMAND python3 -c "import tensorflow as tf; print(' '.join(tf.sysconfig.get_compile_flags()), end='')" OUTPUT_VARIABLE Tensorflow_COMPILE_FLAGS)


PYTHON ?= python3

TENSORFLOW_INCLUDE_DIRS = $(shell $(PYTHON) -c "import tensorflow; print(tensorflow.sysconfig.get_include())" )
TENSORFLOW_LIB_FLAGS = $(shell $(PYTHON) -c "import tensorflow as tf; print(' '.join(tf.sysconfig.get_link_flags()), end='')" )
TENSORFLOW_COMPILE_FLAGS = $(shell $(PYTHON) -c "import tensorflow as tf; print(' '.join(tf.sysconfig.get_compile_flags()), end='')" )




