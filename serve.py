#!/usr/bin/env python3

import http.server

class WASMHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Required for SharedArrayBuffer (pthreads)
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()

if __name__ == "__main__":
    http.server.test(
        HandlerClass=WASMHandler,
        bind='127.0.0.1',
        port=8000)
