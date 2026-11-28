# Pokemon Muia: dà la camminata a uno sprite de personagio coi 4 fotogrami uguai.
# Uso: python3 Strumenti/camminata_sprite.py entrada.png uscida.png
# Fotogrami 1 e 3: corpo zo de 2 pixel e un piede alzà (o avanti/indrio de profilo).
# Crea i fotogrammi de camminata per i sprite fermi (4 fotogrammi uguali)
from PIL import Image
import sys
def frame_walk(f0, row, which):
    W,H=f0.size
    out=Image.new('RGBA',(W,H),(0,0,0,0))
    bb=f0.getbbox()
    if not bb: return f0.copy()
    bottom=bb[3]                      # prima riga vuota soto i piedi
    body=f0.crop((0,0,W,bottom-2)); feet=f0.crop((0,bottom-2,W,bottom))
    dy=2 if bottom+2<=H else H-bottom
    out.paste(body,(0,dy))
    if row in (0,3):   # verso basso / alto: un piede alzà
        p=feet.load()
        for x in range(W):
            if (which==1 and x>=W//2) or (which==3 and x<W//2):
                for y in range(2): p[x,y]=(0,0,0,0)
        out.alpha_composite(feet,(0,bottom-2+dy))
    else:              # de profilo: el piede avanti o indrio
        dx=-2 if which==1 else 2
        out.alpha_composite(feet,(dx,bottom-2+dy)) if dx>0 else out.alpha_composite(feet.crop((2,0,W,2)),(0,bottom-2+dy))
    return out
def converti(src,dst):
    im=Image.open(src).convert('RGBA'); fw,fh=im.width//4,im.height//4
    new=im.copy()
    for r in range(4):
        f0=im.crop((0,r*fh,fw,r*fh+fh))
        for c in range(4):
            fr=f0 if c in (0,2) else frame_walk(f0,r,c)
            new.paste((0,0,0,0),(c*fw,r*fh,c*fw+fw,r*fh+fh)); new.paste(fr,(c*fw,r*fh))
    new.save(dst)
if __name__=='__main__':
    converti(sys.argv[1],sys.argv[2])
