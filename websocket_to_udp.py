import asyncio
import socket
import websockets
from argparse import ArgumentParser

async def main(args):
    # Initialize UDP socket for both sending and receiving
    udp_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    udp_sock.bind(('0.0.0.0', args.listen_udp_port))
    udp_sock.setblocking(False)

    async def ws_to_udp(websocket):
        '''Forwards incoming WebSocket messages to UDP.'''
        async for message in websocket:
            data = message.encode() if isinstance(message, str) else message
            udp_sock.sendto(data, (args.udp_host, args.udp_port))

    async def udp_to_ws(websocket):
        '''Listens for UDP packets and forwards them to the WebSocket.'''
        loop = asyncio.get_running_loop()
        while True:
            # Non-blocking receive from UDP
            data, addr = await loop.sock_recvfrom(udp_sock, 1024)
            if websocket.open:
                await websocket.send(data)

    async def relay_handler(websocket):
        '''Manages bidirectional tasks for each connection.'''
        # Run both directions concurrently
        await asyncio.gather(
            ws_to_udp(websocket),
            udp_to_ws(websocket)
        )

    print(f'Bidirectional Relay: WS(port {args.ws_port}) <-> UDP(port {args.udp_port})')
    async with websockets.serve(relay_handler, args.ws_host, args.ws_port):
        await asyncio.Future()

if __name__ == '__main__':
    from argparse import ArgumentParser
    parser = ArgumentParser()
    parser.add_argument('--ws_host', required=True)
    parser.add_argument('--ws_port', type=int, required=True)
    parser.add_argument('--udp_host', required=True)
    parser.add_argument('--udp_port', type=int, required=True)
    parser.add_argument('--listen_udp_port', type=int, required=True,
                        help='Port to listen for return UDP traffic')
    args = parser.parse_args()
    asyncio.run(main(args))
