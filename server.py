#!/usr/bin/env python3
TCPPort = 5000
import socketserver, socket, sys, os, io, traceback, struct, json, threading

class H(socketserver.BaseRequestHandler):

    PyBridgeContext={}
       
    def runit(self, cmd, h):
        if cmd == 'Q': # end
            os._exit(0)
        try:
            ctx = self.PyBridgeContext
            if cmd == 'X':   # exec
                result = exec(h['expr'], ctx)
            elif cmd == '0': # eval
                result = eval(h['expr'], ctx)
            elif cmd == 'A': # assign
                ctx['PyBridgeTemp']=h['value']
                result = exec(h['name']+'=PyBridgeTemp', ctx)
                del ctx['PyBridgeTemp']
            elif cmd == '1': # monadic
                result = getattr(globals(), h['fn'])(h['args'][0])
                
            result=self.serializeit(result)
            return(result)
			
        except:
            result = "E" + traceback.format_exc()
            return(result)

    def serializeit(self, result):
        try:
            return("0" + json.dumps(result))
        except:
            r = "1" + repr(result)
            traceback.print_exc()
            print(r)
            return(r)
    
    def handle(self):
        try:
            MSG_WAITALL = socket.MSG_WAITALL
        except:
            MSG_WAITALL = 8 # work-around for bug in Windows Python Libs (5.4.2)
        while 1:
            b = self.request.recv(8, MSG_WAITALL)
            if not b: break
            n = struct.unpack('>Q', b)[0] # n:number of bytes in JSON string, big-endian 8-byte integer
            cmd = str(self.request.recv(1, MSG_WAITALL), 'utf8') # type of request
            h = json.loads(str(self.request.recv(n, MSG_WAITALL), 'utf8')) # h:parsed JSON string
            print('cmd: ' + cmd + ', h:' + repr(h))
            r = self.runit(cmd, h)			
            r = bytes(r, "utf8")
            
            self.request.sendall(struct.pack('>Q', len(r)))
            self.request.sendall(r)

    def main():
        print('PyBridge listening on port '+str(TCPPort))
        socketserver.TCPServer(('', TCPPort), H).serve_forever()

try:
    argv = sys.argv
    argv = argv[argv.index("--") + 1:] # get args after "--"
    TCPPort=int(argv[0])
except:
	traceback.print_exc()

threading.Thread(target=H.main).start()
