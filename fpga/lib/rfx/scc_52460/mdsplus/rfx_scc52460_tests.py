#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function


class rfx_scc52460_2_0_test:

	def init(self):
		from ctypes import CDLL, c_int, c_char_p
		name = "scc52460_2_0"
		dev_name = "/dev/scc52460_2_0"
		pts=132000
		try:
			deviceLib = CDLL("librfx_scc52460_2_0.a")
		except:
			print ('Cannot link to device library')
			return 0
		deviceLib.initialize(c_char_p(name), c_char_p(dev_name), c_int(pts))


	def store(self):
		from ctypes import CDLL, c_char_p, c_int, byref
		try:
			deviceLib = CDLL("librfx_scc52460_2_0.a")
		except:
			print ('Cannot link to device library')
			return 0
		DataArray = c_int * 132000
		rawChan = []
		rawChan.append(DataArray())
		rawChan.append(DataArray())
		status = deviceLib.acquire(c_char_p(name), byref(rawChan[0]), byref(rawChan[1]))
		if status == -1:
			print ('Acquisition Failed')
			return 0



if __name__ == '__main__':
	import struct
	import matplotlib.pyplot as plt
	import numpy as np
	f = open("scc52460_data.out", "rb")
	a=[]
	for i in range(132000):
		a.append(struct.unpack('i', f.read(4))[0])
	plt.plot(arr)
	plt.show()



