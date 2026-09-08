"""Generate an opaque iOS AppIcon asset catalog with Python's standard library."""
from pathlib import Path
import json
import struct
import zlib

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'App/Assets.xcassets'
ICONS = ASSETS / 'AppIcon.appiconset'
POINTS = [(0.22, 0.30), (0.34, 0.66), (0.50, 0.43), (0.66, 0.66), (0.78, 0.30)]
SEGMENTS = list(zip(POINTS, POINTS[1:]))

def distance(x, y, a, b):
    dx, dy = b[0] - a[0], b[1] - a[1]
    t = max(0.0, min(1.0, ((x-a[0])*dx + (y-a[1])*dy)/(dx*dx+dy*dy)))
    return ((x-a[0]-t*dx)**2 + (y-a[1]-t*dy)**2)**0.5

def png(size):
    pixels = bytearray()
    for y in range(size):
        pixels.append(0)
        for x in range(size):
            u, v = (x+0.5)/size, (y+0.5)/size
            d = min(distance(u, v, a, b) for a, b in SEGMENTS)
            ink = max(0.0, min(1.0, (0.038-d)*size + 0.5))
            dot = min(((u-c)**2+(v-0.80)**2)**0.5 for c in (0.38, 0.50, 0.62))
            blue = max(0.0, min(1.0, (0.023-dot)*size + 0.5))
            color = [round(25 + (250-25)*ink)]*3
            color = [round(c*(1-blue)+b*blue) for c,b in zip(color,(94,159,232))]
            pixels.extend(color)
    def chunk(kind, data):
        return struct.pack('>I',len(data))+kind+data+struct.pack('>I',zlib.crc32(kind+data)&0xffffffff)
    return b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',size,size,8,2,0,0,0))+chunk(b'IDAT',zlib.compress(bytes(pixels),9))+chunk(b'IEND',b'')

def main():
    ICONS.mkdir(parents=True,exist_ok=True)
    ASSETS.joinpath('Contents.json').write_text(json.dumps({'info':{'author':'xcode','version':1}},indent=2))
    specs = [('iphone',20,[2,3]),('iphone',29,[2,3]),('iphone',40,[2,3]),('iphone',60,[2,3]),('ipad',20,[1,2]),('ipad',29,[1,2]),('ipad',40,[1,2]),('ipad',76,[1,2]),('ipad',83.5,[2]),('ios-marketing',1024,[1])]
    entries = []
    rendered = set()
    for idiom,points,scales in specs:
        for scale in scales:
            size = int(points*scale)
            filename = f'icon-{size}.png'
            if size not in rendered:
                ICONS.joinpath(filename).write_bytes(png(size))
                rendered.add(size)
            entries.append({'idiom':idiom,'size':f'{points}x{points}','scale':f'{scale}x','filename':filename})
    ICONS.joinpath('Contents.json').write_text(json.dumps({'images':entries,'info':{'author':'xcode','version':1}},indent=2))
    ROOT.joinpath('wewln-icon.png').write_bytes(ICONS.joinpath('icon-1024.png').read_bytes())
    print(f'Generated {len(rendered)} opaque RGB icons and AppIcon catalog')

if __name__ == '__main__':
    main()
