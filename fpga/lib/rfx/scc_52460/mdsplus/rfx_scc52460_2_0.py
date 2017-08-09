#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function
from MDSplus import *

class rfx_scc52460_2_0(Device):
	parts=[{'path': ':NAME',        'type': 'text'},
	   {'path': ':COMMENT',     'type': 'text'},
	   {'path': ':DEV_NAME',    'type': 'text'},
	   {'path': ':TRIG_SOURCE', 'type': 'numeric', 'value': 0       },
	   {'path': ':PTS',         'type': 'numeric', 'value': 132000  }]
	for i in range(2):
		parts.append({'path': '.CHANNEL_%d' % (i), 'type': 'structure'})
		parts.append({'path': '.CHANNEL_%d:START_IDX' % (i), 'type': 'numeric', 'value': 0})
		parts.append({'path': '.CHANNEL_%d:END_IDX' % (i),   'type': 'numeric', 'value': 132000})
		parts.append({'path': '.CHANNEL_%d:DATA' % (i),
		      'type': 'signal',
		      'options':('no_write_model', 'compress_on_put')})
		parts.append({'path': ':INIT_ACTION', 'type': 'action','valueExpr': "Action(Dispatch(2, 'CAMAC_SERVER', 'INIT', 50, None), Method(None, 'init', head))", 'options': ('no_write_shot',)})
		parts.append({'path': ':STORE_ACTION', 'type': 'action','valueExpr': "Action(Dispatch(2, 'CAMAC_SERVER', 'STORE', 50, None), Method(None, 'store', head))", 'options':('no_write_shot',)})


	# //////////////////////////////////////////////////////////////////////////
	# // INIT //////////////////////////////////////////////////////////////////
	def init(self, arg):
		from ctypes import CDLL, c_int, c_char_p
		try:
			deviceLib = CDLL("librfx_scc52460_2_0.a")
		except:
			print ('Cannot link to device library')
			return 0
		try:
			name = self.name.data()
		except:
			print ('Missing Name in device')
			return 0
		try:
			name = self.dev_name.data()
		except:
			print ('Missing DevName in device')
			return 0
		try:
			pts = self.pts.data()
		except:
			print ('Missing or invalid Post Trigger Samples')
			return 0
		deviceLib.initialize(c_char_p(name), c_char_p(dev_name), c_int(pts))
		return 1


	# //////////////////////////////////////////////////////////////////////////
	# // STORE /////////////////////////////////////////////////////////////////
	def store(self,arg):
		from ctypes import CDLL, c_char_p, c_short, byref
		#instantiate library object
		try:
			deviceLib = CDLL("librfx_scc52460_2_0.a")
		except:
			print ('Cannot link to device library')
			return 0
		try:
			name = self.name.data()
		except:
			print ('Missing Name in device')
			return 0
		#instantiate arrays with 132000 samples each.
		DataArray = c_int * 132000
		rawChan = []
		rawChan.append(DataArray())
		rawChan.append(DataArray())
		#//  ACQUIRE  //#
		status = deviceLib.acquire(c_char_p(name), byref(rawChan[0]), byref(rawChan[1]))
		if status == -1:
			print ('Acquisition Failed')
			return 0
		# at this point the raw signals are contained in rawChan. We must now:
		# 1  reduce the dimension of the stored array using the start idx and
		#    end idx parameters for each channel, which define
		#    the number of samples around the trigger which need to be stored
		#    in the pulse file (for this purpose the value of
		#    post trigger samples is also required)
		# 2  build the appropriate timing information
		# 3  put all together in a Signal object
		# 4  store the Signal object in the tree
		#    read PostTriggerSamples
		try:
			pts = self.pts.data()
		except:
			print ('Missing or invalid Post Trigger Samples')
			return 0
		# for each channel we read start idx and end idx
		startIdx = []
		endIdx = []
		try :
			for chan in range(0,4):
				currStartIdx = self.__getattr__('channel_%d_start_idx'%(chan)).data()
				currEndIdx = self.__getattr__('channel_%d_end_idx'%(chan)).data()
				startIdx.append(currStartIdx)
				endIdx.append(currEndIdx)
		except:
			print ('Cannot read start idx or end idx')
			return 0

		# 1) Build reduced arrays based on start idx and end idx for each channel
		# recall that a transient recorder stores acquired data in a circular
		# buffer and stops after acquiring PTS samples after the trigger. This
		# means that the sample corresponding to the trigger is at offset PTS
		# samples before the end of the acquired sample array. the total number
		# of samples returned by routine acquire()
		totSamples = 132000

		# we read the time associated with the trigger. It is specified in the
		# TRIG_SOURCE field of the device tree structure. #it will be required in
		# order to associate the correct time with each acquired sample

		#	try:
		#	    trigTime = self.trig_source.data()
		#	except:
			#    print 'Missing or invalid trigger source'
			#    return 0
			# we need clock frequency as well
		try:
			clockFreq = 2E6 # FIXED FOR NOW self.clock_freq.data()
			clockPeriod = 1./clockFreq
		except:
			print ('Missing or invalid clock frequency')
			return 0
	  # the following steps are performed for each acquired channel
		reducedRawChans = []
		for chan in range(0,2):
			# first index of the part of interest of the sample array
			actStartIdx = totSamples - pts + startIdx[chan]
			# last index of the part of interest of the sample array
			actEndIdx = totSamples - pts  + endIdx[chan]
			# make sure we do not exceed original array limits
			if actStartIdx < 0:
				actStartIdx = 0
				if actEndIdx > totSamples:
					actEndIdx = totSamples - 1
			#build reshaped array
			reducedRawChan = rawChan[chan][actStartIdx:actEndIdx]

	   # 2)  Build timing information. For this purpose we use a MDSplus
	   # "Dimension" object which contains two fields: # "Window" and "Axis".
	   # Window object defines the start and end index of the associated data
	   # array and the time which is # associated with the sample at index 0.
	   # Several possible combination of start and end indexes are possible
	   # (the can also be #negative numbers). We adopt here the following
	   # convention: consider index 0 as the index of the sample corresponding
	   # #to the trigger, and therefore associated with the trigger time. From
	   # the way we have built the reduced raw sample array, #it turns out that
	   # the start idx and end idx defined #in the Window object are the same
	   # of the start and end indexes defined in the device configuration.
	   #
	   # The "Range" object describes a (possibly multispeed or busrt) clock.
	   # Its fields specify the clock period, the start and end time #for that
	   # clock frequency. In our case we need to describe a continuous single
	   # speed clock, so there is no need to #specify start and end times(it is
	   # a continuous, single speed clock).
	   #
	   # build the Dimension object in a single call

		dim = Dimension(Window(startIdx[chan], endIdx[chan], trigTime),
						Range(None, None, clockPeriod))

	   # 3) Put all togenther in a "Signal" object. MDSplus Signal objects
	   # define three fields: samples, raw samples, dimension # raw samples are
	   # contained in reducedRawChan. The computation required to convert the
	   # raw 16 bit sample into a +-10V # value is: sample =
	   # 10.*rawSample/32768. We may compute a new float array containing such
	   # data and store it together # with the raw sample (in the case we would
	   # like to reain also raw data. There is however a better way to do it #
	   # by storing only the required information, i.e. the raw(16 bit) samples
	   # and the definition of the expression which # converts raw data into
	   # actual voltage levels. Therefore, the first field of the Signal object
	   # will contain only the # definition of an expression, which refers to
	   # the raw samples (the second field) of the same Signal object. # The
	   # MDSplus syntax for this conversion is: 10.*$VALUE/32768. # We shall
	   # use Data method compile() to build the MDSplus internal representation
	   # of this expression, and the stick it # as the first field of the
	   # Signal object

		convExpr = Data.compile("10.* $VALUE/32768.")
		# use MDSplus Int16Array object to vest the short array reducedRawChan
		# into the appropriate MDSplus type

		rawMdsData = Int16Array(reducedRawChan)
		# every MDSplus data type can have units associated with it
		rawMdsData.setUnits("Count")
		convExpr.setUnits("Volt")
		# build the signal object
		signal = Signal(convExpr, rawMdsData, dim)
		# write the signal in the tree
		try:
			self.__getattr__('channel_%d_data'%(chan)).putData(signal)
		except:
			print ('Cannot write Signal in the tree')
			return 0
		#endfor chan in range(0,4):
		#return success (odd numbers in MDSplus)
		return 1


