include $(top_srcdir)/Common.mk
include $(top_srcdir)/fpga/Common.mk

VENDOR = w7x


#NAME := $(or $(lastword $(foreach x,$(project_LISTS),\
#					   $(if $(filter $($x_TARGETS),\
#									 $(MAKECMDGOALS)),\
#									 $(lastword $(value $x)),))),\
#			 $(project_DEFAULT))


print_n:
	@ echo "nam=$(NAME) from=$(FROM)"


## CORES ##
vivado_CORES   = timing_1.0
timing_1_0_SOURCES = \
					 src/w7x_timing_v1_0_S00_AXI.vhd \
					 src/w7x_timing_v1_0.vhd \
					 src/w7x_timing.vhd \
					 src/TestTiming.vhd


## PROJECTS ##
vivado_PROJECTS = timing_brd_1.0
timing_brd_IP_SOURCES = timing_1.0






