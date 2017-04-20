import ctypes as _c, numpy as _n
import socket as _s, struct as _p

class w7x_timing(object):
    _NULL = _c.c_void_p(None)
    @staticmethod
    def _tobyte(val):
        if not isinstance(val,int):
            value = 0;
            for ch in val: value.value |= 4<<ch
            return value
        return val
    @staticmethod
    def _toctypes(delay,width,period,cycle,repeat,count):
        delay  = None if delay  is None else _c.c_uint64(int(delay))
        width  = None if width  is None else _c.c_uint32(int(width))
        period = None if period is None else _c.c_uint32(int(period))
        cycle  = None if cycle  is None else _c.c_uint64(int(cycle))
        repeat = None if repeat is None else _c.c_uint32(int(repeat))
        count  = None if count  is None else _c.c_uint32(int(count))
        return (delay,width,period,cycle,repeat,count)
    @staticmethod
    def _byref(*args):
        return tuple((w7x_timing._NULL if a is None else _c.byref(a)) for a in args)
    def __init__(self):
        try:
            self.cdll = _c.CDLL('libw7x_timing_lib.so')
            self.cdll.getError.restype=_c.c_void_p
            self._error = _c.cast(self.cdll.getError(),_c.c_char_p)
        except OSError as exc:
            print('w7x_timing: '+ str(exc))
    def arm(self):
        self.cdll.arm()
    def disarm(self):
        self.cdll.disarm()
    def makeClock(self,delay=None,width=None,period=None,cycle=None,repeat=None,count=None):
        args = w7x_timing._toctypes(delay,width,period,cycle,repeat,count)
        delay,width,period,cycle,repeat,count = w7x_timing._byref(*args)
        self.cdll.makeClock(delay,width,period,cycle,repeat,count)
    def makeSequence(self,delay=None,width=None,period=None,cycle=None,repeat=None,times=[]):
        times = _n.ascontiguousarray(times,dtype=_n.uint64)
        timref= times.ctypes.data_as(_c.POINTER(_c.c_uint64))
        args  = w7x_timing._toctypes(delay,width,period,cycle,repeat,len(times))
        delay,width,period,cycle,repeat,count = w7x_timing._byref(*args)
        self.cdll.makeSequence(delay,width,period,cycle,repeat,count,timref)
    def reinit(self,delay=6e7):
        delay = None if delay  is None else _c.c_uint64(int(delay))
        ref   = w7x_timing._NULL if delay is None else _c.byref(delay)
        self.cdll.reinit(ref)
    def trig(self):
        self.cdll.trig()
    def extclk(self,value):
        self.cdll.extclk(_c.c_int8(-1) if value else _c.c_int8(0))
    def gate(self,value=0):
        value = _c.c_uint8(w7x_timing._tobyte(value))
        self.cdll.gate(value)
    def invert(self,value=0):
        value = _c.c_uint8(w7x_timing._tobyte(value))
        self.cdll.invert(value)
    @property
    def error(self):
        return str(self._error.value)
    @property
    def state(self):
        return self.cdll.getState()
    @property
    def params(self):
        args = w7x_timing._toctypes(0,0,0,0,0,0)
        refs = w7x_timing._byref(*args)
        self.cdll.getParams(*refs)
        return tuple(int(a.value) for a in args)

    def run(self,port):
        def senderror(conn):
            msg = str(self.error)
            conn.send(_p.pack('<L',len(msg))+msg)
        try: #create an AF_INET, STREAM socket (TCP)
            sock = _s.socket(_s.AF_INET, _s.SOCK_STREAM)
        except _s.error as msg:
            print 'Failed to create socket. Error code: ' + str(msg[0]) + ' , Error message : ' + msg[1]
            return
        try:
            sock.bind(('', int(port)))
        except _s.error as msg:
            print 'Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1]
            return
        while True:
            try:
                sock.listen(10)
                conn, addr = sock.accept()
                print('%s: Connection established'%(addr[0],))
                while True:
                    try:
                        head = conn.recv(7)
                        if not head.startswith('W7X'):
                            if len(head)>0:
                                raise Exception('%s: Invalid header "%s"'%(addr[0],head))
                            raise Exception('%s: Connection closed'%(addr[0],))
                        length = _p.unpack('<L',head[3:])[0]
                        remaining = length+1
                        cmd = []
                        while remaining>0:
                            cmd.append(conn.recv(remaining+256))
                            remaining-= len(cmd[-1])
                        cmd = ''.join(cmd)
                        cmd,param = cmd[0],cmd[1:]
                        if   cmd == 'C':
                            param = tuple((None if p<0 else p) for p in _p.unpack('<qllqll',param[:32]))
                            self.makeClock(*param)
                        elif cmd == 'S':
                            args = tuple((None if p<0 else p) for p in _p.unpack('<qllql',param[:28]))
                            times = _n.frombuffer(param[28:length],_n.uint64)
                            self.makeSequence(*args,times=times)
                        elif cmd == 'R':
                            self.reinit([(None if p<0 else p) for p in _p.unpack('<q',param[:8])][0])
                        elif cmd == 'A':
                            self.arm()
                        elif cmd == 'D':
                            self.disarm()
                        elif cmd == 'T':
                            self.trig()
                        elif cmd == 'E':
                            self.extclk(_p.unpack('<b',param[0])[0])
                        elif cmd == 'G':
                            self.gate(_p.unpack('<b',param[0])[0])
                        elif cmd == 'I':
                            self.invert(_p.unpack('<b',param[0])[0])
                        elif cmd == 's':
                            conn.send(_p.pack('<L',self.state))
                            continue
                        elif cmd == 'p':
                            conn.send(_p.pack('<qllqll',*self.params))
                            continue
                        elif cmd == 'e':
                            pass #only return error
                        else:
                            raise Exception('%s: Invalid command "%s"'%(addr[0],cmd))
                        senderror(conn)
                    except KeyboardInterrupt:
                        conn.close()
                        del(conn)
                        raise
                    except Exception as e:
                        print(e)
                        conn.close()
                        del(conn)
                        break
            except KeyboardInterrupt:
                sock.close()
                raise
            except Exception as e:
                print(e)

class remote(object):
    @staticmethod
    def _makeMsg(prog,form,length,*args):
        return 'W7X'+_p.pack('<L',length)+prog[0]+_p.pack('<'+form,*args)
    def __init__(self,address):
        self.connect(address)
    def connect(self,address):
        self.sock = _s.socket(_s.AF_INET, _s.SOCK_STREAM)
        self.sock.connect(address)
    def _exchange(self,msg):
        self.sock.send(msg)
        length = _p.unpack('<L',self.sock.recv(4))[0]
        if length>0:
            return self.sock.recv(length+255)
    def makeClock(self,delay=-1,width=-1,period=-1,cycle=-1,repeat=-1,count=-1):
        msg = remote._makeMsg('C','qllqll',32,int(delay),int(width),int(period),int(cycle),int(repeat),int(count))
        return self._exchange(msg)
    def makeSequence(self,delay=-1,width=-1,period=-1,cycle=-1,repeat=-1,times=-1):
        times = _n.array(times,_n.int64).tobytes()
        length = len(times)+28
        msg = remote._makeMsg('S','qllql',length,int(delay),int(width),int(period),int(cycle),int(repeat))+times
        return self._exchange(msg)
    def reinit(self,default_delay=-1):
        msg = remote._makeMsg('R','q',8,default_delay)
        return self._exchange(msg)
    def arm(self):
        msg = remote._makeMsg('A','',0)
        return self._exchange(msg)
    def disarm(self):
        msg = remote._makeMsg('D','',0)
        return self._exchange(msg)
    def trig(self):
        msg = remote._makeMsg('T','',0)
        return self._exchange(msg)
    def extclk(self,value=True):
        msg = remote._makeMsg('E','B',1,-1 if value else 0)
        return self._exchange(msg)
    def gate(self,val=0):
        msg = remote._makeMsg('G','B',1,w7x_timing._tobyte(val))
        return self._exchange(msg)
    def invert(self,val=0):
        msg = remote._makeMsg('I','B',1,w7x_timing._tobyte(val))
        return self._exchange(msg)
    @property
    def state(self):
        self.sock.send(remote._makeMsg('s','',0))
        return _p.unpack('<L',self.sock.recv(4))[0]
    @property
    def params(self):
        self.sock.send(remote._makeMsg('p','',0))
        return _p.unpack('<qllqll',self.sock.recv(64)[:32])
    @property
    def error(self):
        msg = remote._makeMsg('e','',0)
        return int(self._exchange(msg))

if __name__=="__main__":
    import sys
    if len(sys.argv)==2:
       w7x = w7x_timing()
       w7x.run(int(sys.argv[1]))
    elif len(sys.argv)==3:
       remote((sys.argv[1],int(sys.argv[2])))

import unittest as _u
class Test(_u.TestCase):
    def checkClock(self,out,error,*args,**kwargs):
        self.assertEqual(self.remote.makeClock(*args,**kwargs).split('\n',2)[1].strip(),error)
        self.assertEqual(self.remote.params,out)

    def connect(self):
        self.remote=remote(('192.168.44.109',5000))
        self.assertIsNone(self.remote.reinit())
        self.checkClock((0,5,10,10000000,5,54272),'',cycle=1e7,count=54272,repeat=5)
        self.checkClock((0,5,10,10000000,5,54272),'ERROR: COUNT > MAX_SAMPLES(54272)',cycle=10000000,count=500000,repeat=5)
        self.assertEqual(self.remote.reinit(6e8),'MAKE CLOCK: DELAY: 600000000, WIDTH: 5, PERIOD: 10, COUNT: 0, CYCLE: 0, REPEAT: 0\n' is not None
)
        self.assertEqual(self.remote.params,out)
        self.assertIsNone(self.remote.arm())
        self.assertIsNone(self.remote.disarm())
        self.assertIsNone(self.remote.trig())
        self.assertIsNone(self.remote.gate([2,4]))
        self.assertIsNone(self.remote.invert([4,5]))
    def runTest(self):
        self.connect()

def test():
    suite=_u.TestSuite((Test('connect'),))
    tr=_u.TextTestRunner()
    tr.run(suite)