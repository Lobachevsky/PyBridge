#!/usr/bin/env python3
import socketserver, socket, sys, io, traceback, struct, json

class H(socketserver.BaseRequestHandler):

    PyBridgeContext={}
        
    def runit(self, cmd, h):
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
        while 1:
            b = self.request.recv(8, socket.MSG_WAITALL)
            if not b: break
            n = struct.unpack('>Q', b)[0] # n:number of bytes in JSON string, big-endian 8-byte integer
            cmd = str(self.request.recv(1, socket.MSG_WAITALL), 'utf8') # type of request
            h = json.loads(str(self.request.recv(n, socket.MSG_WAITALL), 'utf8')) # h:parsed JSON string
            print('cmd: ' + cmd + ', h:' + repr(h))
            r = self.runit(cmd, h)			
            r = bytes(r, "utf8")
            
            self.request.sendall(struct.pack('>Q', len(r)))
            self.request.sendall(r)

socketserver.TCPServer(('', 5000), H).serve_forever()
