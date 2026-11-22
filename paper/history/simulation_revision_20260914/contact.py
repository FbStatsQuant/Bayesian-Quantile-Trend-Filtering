from PIL import Image,ImageOps,ImageDraw
from pathlib import Path
p=Path(__file__).resolve().parent/'render'
groups=[[1,2,3,4,5,6],[7,8,9,10,11,12],[13,14,15,16,17,18],[19,20,21,22,23,24],[25,26,27,28,29,30],[31,32,33,34,35,36],[37,38]]
for i,group in enumerate(groups,1):
    sheet=Image.new('RGB',(1440,3*962),'#D1D5DB')
    draw=ImageDraw.Draw(sheet)
    for j,n in enumerate(group):
        img=Image.open(p/f'page-{n:02d}.png').convert('RGB')
        img.thumbnail((700,922))
        x=(j%2)*720+10;y=(j//2)*962+28
        sheet.paste(img,(x,y));draw.text((x,y-20),f'Page {n}',fill='black')
    sheet.save(p/f'contact-{i}.png')
