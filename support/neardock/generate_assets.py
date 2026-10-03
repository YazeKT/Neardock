"""Deterministically render the approved geometric SVG mark and platform assets."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import json
from io import BytesIO
import os

ROOT = Path(__file__).resolve().parents[2]
ORANGE, INK = '#F97316', '#17191E'
POLYGONS = [[(28,24),(46,24),(66,52),(54,66),(46,55),(46,104),(28,104)],[(100,104),(82,104),(60,74),(72,60),(82,73),(82,24),(100,24)]]
PATHS = ['M28 24H46L66 52L54 66L46 55V104H28Z','M100 104H82L60 74L72 60L82 73V24H100Z']

def save(image, path, **options):
    path=Path(path)
    data=BytesIO()
    image.save(data, format=options.pop('format', 'PNG'), **options)
    content=data.getvalue()
    if path.exists() and path.read_bytes()==content:
        return
    temp=path.with_name(path.name+'.neardock-tmp')
    temp.write_bytes(content)
    os.replace(temp,path)

def write(path, text):
    path = ROOT / path
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding='utf-8')

def svg(color=ORANGE, tile=False, wordmark=False):
    width = 420 if wordmark else 128
    bg = f'<rect width="128" height="128" rx="24" fill="{INK}"/>' if tile else ''
    text = '<text x="140" y="81" font-family="Segoe UI,Arial,sans-serif" font-size="52" font-weight="700" fill="#17191E">Neardock</text>' if wordmark else ''
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} 128" role="img" aria-labelledby="title"><title id="title">Neardock</title>{bg}<g fill="{color}">'+''.join(f'<path d="{p}"/>' for p in PATHS)+f'</g>{text}</svg>\n'

def mark(size, color=ORANGE, bg=None, inset=0):
    scale = 4
    img = Image.new('RGBA', (size*scale,size*scale), bg or (0,0,0,0))
    draw = ImageDraw.Draw(img)
    span = size - inset*2
    for poly in POLYGONS:
        draw.polygon([((inset+x/128*span)*scale,(inset+y/128*span)*scale) for x,y in poly],fill=color)
    return img.resize((size,size),Image.Resampling.LANCZOS)

brand = ROOT/'branding'
brand.mkdir(exist_ok=True)
for name, opts in [('neardock.svg',{}),('neardock-white.svg',{'color':'#FFFFFF'}),('neardock-black.svg',{'color':INK}),('neardock-icon.svg',{'tile':True}),('neardock-wordmark.svg',{'wordmark':True})]:
    write('branding/'+name,svg(**opts))
for size in [32,128,256,512]:
    save(mark(size),ROOT/f'app/assets/img/logo-{size}.png')
for size in [32,512]:
    save(mark(size,'#FFFFFF'),ROOT/f'app/assets/img/logo-{size}-white.png')
save(mark(32,INK),ROOT/'app/assets/img/logo-32-black.png')
for path in ['app/assets/img/logo.ico','app/assets/packaging/logo.ico','app/windows/runner/resources/app_icon.ico']:
    save(mark(256,bg=INK),ROOT/path,format='ICO',sizes=[(16,16),(24,24),(32,32),(48,48),(64,64),(128,128),(256,256)])
res = ROOT/'app/android/app/src/main/res'
for density,size in [('mdpi',48),('hdpi',72),('xhdpi',96),('xxhdpi',144),('xxxhdpi',192)]:
    folder=res/f'mipmap-{density}'
    save(mark(size,bg=INK),folder/'ic_launcher.png')
    adaptive=round(size*108/48)
    save(mark(adaptive,inset=adaptive*.17),folder/'ic_launcher_foreground.png')
    save(mark(adaptive,'#FFFFFF',inset=adaptive*.17),folder/'ic_launcher_monochrome.png')
    save(mark(adaptive,'#FFFFFF',inset=adaptive*.17),folder/'ic_launcher_quicktile_foreground.png')
save(mark(192,bg=INK),res/'mipmap-xxxhdpi/ic_launcher_round.png')
vector = '<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="128" android:viewportHeight="128"><group android:pivotX="64" android:pivotY="64" android:scaleX="0.66" android:scaleY="0.66">'+''.join(f'<path android:fillColor="{ORANGE}" android:pathData="{p}"/>' for p in PATHS)+'</group></vector>\n'
write('app/android/app/src/main/res/drawable/ic_launcher_foreground.xml',vector)
write('app/android/app/src/main/res/values/ic_launcher_background.xml',f'<resources><color name="ic_launcher_background">{INK}</color></resources>\n')
for folder in ['drawable','drawable-v21']:
    write(f'app/android/app/src/main/res/{folder}/launch_background.xml','<layer-list xmlns:android="http://schemas.android.com/apk/res/android"><item android:drawable="?android:colorBackground"/><item><bitmap android:gravity="center" android:src="@mipmap/ic_launcher"/></item></layer-list>\n')
banner=Image.new('RGB',(320,180),INK)
banner.paste(mark(140), (90,20),mark(140))
save(banner,res/'drawable/banner.png')
for path in (ROOT/'support/build/msix/content/Images').glob('*.png'):
    with Image.open(path) as original:
        w,h=original.size
        old_pixels=original.convert('RGBA').tobytes()
    tile=Image.new('RGBA',(w,h),INK)
    glyph=mark(min(w,h), '#FFFFFF' if 'Badge' in path.name else ORANGE)
    tile.alpha_composite(glyph,((w-glyph.width)//2,(h-glyph.height)//2))
    if tile.tobytes() != old_pixels:
        save(tile,path)
write('website/assets/neardock.svg',svg())
write('website/assets/neardock-icon.svg',svg(tile=True))
sheet=Image.new('RGB',(720,240),'#F4F6F8')
for i,size in enumerate([16,24,32,48,64,128]):
    glyph=mark(size,bg=INK)
    sheet.paste(glyph,(20+i*115,50),glyph)
save(sheet,brand/'icon-size-review.png')
social=Image.new('RGB',(1200,630),INK)
social_draw=ImageDraw.Draw(social)
font_dir=Path('C:/Windows/Fonts')
try:
    title_font=ImageFont.truetype(str(font_dir/'segoeuib.ttf'),76)
    body_font=ImageFont.truetype(str(font_dir/'segoeui.ttf'),34)
except OSError:
    title_font=ImageFont.load_default(size=76)
    body_font=ImageFont.load_default(size=34)
glyph=mark(230)
social.paste(glyph,(60,70),glyph)
social_draw.text((300,140),'Neardock',fill='white',font=title_font)
social_draw.text((95,355),'Share files between nearby devices.',fill='white',font=body_font)
social_draw.text((95,430),'Windows + Android',fill=ORANGE,font=body_font)
save(social,ROOT/'website/assets/social.png')
print('SVG masters, Windows, Android, MSIX and website icons generated.')
