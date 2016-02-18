#!/usr/bin/env python3
import socketserver, socket, sys, io, traceback, struct, json
import fns # module whose functions to expose; you can replace this with "import anothermodule as fns"

class H(socketserver.BaseRequestHandler):

    def runit(self, h):
        try:
            return(getattr(fns, h['fn'])(h['arg']))
        except:
            result = "1Python Error"
            traceback.print_exc()
            print(result)
            return(result)

    def serializeit(self, result):
        try:
            return("0" + json.dumps(result))
        except:
            r = "2JSON Serialization failed, repr: " + repr(result)
            traceback.print_exc()
            print(r)
            return(r)
    
    def handle(self):
        while 1:
            b = self.request.recv(8, socket.MSG_WAITALL)
            if not b: break
            n = struct.unpack('>Q', b)[0] # n:number of bytes in JSON string, big-endian 8-byte integer
            h = json.loads(str(self.request.recv(n, socket.MSG_WAITALL), 'utf8')) # h:parsed JSON string
            print('h:' + repr(h))
            r = self.runit(h)
            r = self.serializeit(r)				
            r = bytes(r, "utf8")
            
            self.request.sendall(struct.pack('>Q', len(r)))
            self.request.sendall(r)

socketserver.TCPServer(('', 5000), H).serve_forever()
