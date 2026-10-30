   rem ==========================================================
   rem  BREAKOUT  -  Atari 2600 / batari Basic (standard kernel)
   rem
   rem  Joystick in port 0:  LEFT/RIGHT move paddle, FIRE serves
   rem  Game Reset switch restarts the game
   rem  3 balls, 8 brick layouts played in order, ball speeds up on level 3+
   rem ==========================================================

   set kernel_options pfcolors
   const pfres=12

   rem ---------- tunable constants ----------
   const paddley=80        : rem vertical position of the paddle
   const padmin=21         : rem leftmost paddle x
   const padmax=108        : rem rightmost paddle x (paddle is 32 px wide)
   const lostline=90       : rem ball y at which the ball is lost

   rem ---------- variables ----------
   dim bdx=a               : rem ball x velocity (8-bit wrap: 255 = -1)
   dim bdy=b               : rem ball y velocity
   dim serving=c           : rem 1 = ball waiting on paddle
   dim bricks=d            : rem bricks remaining
   dim snd=e               : rem sound timer
   dim c1=f                : rem playfield column under ball's left edge
   dim c2=g                : rem playfield column under ball's right edge
   dim r1=h                : rem playfield row under ball's top
   dim r2=i                : rem playfield row under ball's bottom
   dim level=j
   dim spd=k               : rem ball speed (1 or 2)
   dim hit=l               : rem set when a brick was broken this frame
   dim cx=m                : rem cell column for killcell
   dim cy=n                : rem cell row for killcell
   dim tmp=o
   dim layout=p            : rem next brick layout to load (0-7)

init
   score=0
   lives=96                : rem 3 balls
   level=1
   spd=1
   layout=0
   pfclear

   pfcolors:
   $0C
   $0C
   $42
   $3A
   $1E
   $C6
   $0E
   $0E
   $0E
   $0E
   $0E
   $0E
end

   player0:
   %11111111
   %11111111
end

   NUSIZ0=$07              : rem quad-width player = 32 px paddle
   COLUP0=$9A
   CTRLPF=$21              : rem reflected playfield, 4 px wide ball
   ballheight=4
   scorecolor=$1E
   player0x=64
   player0y=paddley
   AUDV0=0

newlevel
   rem ----- load the next layout in sequence -----
   if layout=0 then goto layout0
   if layout=1 then goto layout1
   if layout=2 then goto layout2
   if layout=3 then goto layout3
   if layout=4 then goto layout4
   if layout=5 then goto layout5
   if layout=6 then goto layout6
   if layout=7 then goto layout7

   rem ---- layout 0: Classic - four solid rows (112 bricks) ----
layout0
   playfield:
   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   X..............................X
   X.XXXXXXXXXXXXXXXXXXXXXXXXXXXX.X
   X.XXXXXXXXXXXXXXXXXXXXXXXXXXXX.X
   X.XXXXXXXXXXXXXXXXXXXXXXXXXXXX.X
   X.XXXXXXXXXXXXXXXXXXXXXXXXXXXX.X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
end
   bricks=112
   goto layoutdone

   rem ---- layout 1: Checkerboard (56 bricks) ----
layout1
   playfield:
   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   X..............................X
   X.X.X.X.X.X.X.X.X.X.X.X.X.X.X..X
   X..X.X.X.X.X.X.X.X.X.X.X.X.X.X.X
   X.X.X.X.X.X.X.X.X.X.X.X.X.X.X..X
   X..X.X.X.X.X.X.X.X.X.X.X.X.X.X.X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
end
   bricks=56
   goto layoutdone

   rem ---- layout 2: Pyramid (76 bricks) ----
layout2
   playfield:
   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   X..............................X
   X...........XXXXXXXX...........X
   X.......XXXXXXXXXXXXXXXX.......X
   X...XXXXXXXXXXXXXXXXXXXXXXXX...X
   X.XXXXXXXXXXXXXXXXXXXXXXXXXXXX.X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
end
   bricks=76
   goto layoutdone

   rem ---- layout 3: Vertical bars (84 bricks) ----
layout3
   playfield:
   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   X..............................X
   X.XXX.XXX.XXX.XXX.XXX.XXX.XXX..X
   X.XXX.XXX.XXX.XXX.XXX.XXX.XXX..X
   X.XXX.XXX.XXX.XXX.XXX.XXX.XXX..X
   X.XXX.XXX.XXX.XXX.XXX.XXX.XXX..X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
end
   bricks=84
   goto layoutdone

   rem ---- layout 4: Fortress - hollow middle (72 bricks) ----
layout4
   playfield:
   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   X..............................X
   X.XXXXXXXXXXXXXXXXXXXXXXXXXXXX.X
   X.XXXX....................XXXX.X
   X.XXXX....................XXXX.X
   X.XXXXXXXXXXXXXXXXXXXXXXXXXXXX.X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
end
   bricks=72
   goto layoutdone

   rem ---- layout 5: Diagonal stripes (84 bricks) ----
layout5
   playfield:
   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   X..............................X
   X.XXX.XXX.XXX.XXX.XXX.XXX.XXX..X
   X..XXX.XXX.XXX.XXX.XXX.XXX.XXX.X
   X.X.XXX.XXX.XXX.XXX.XXX.XXX.XX.X
   X.XX.XXX.XXX.XXX.XXX.XXX.XXX.X.X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
end
   bricks=84
   goto layoutdone

   rem ---- layout 6: Bands with gaps (84 bricks) ----
layout6
   playfield:
   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   X..............................X
   X.XXXXXXXXXXXXXXXXXXXXXXXXXXXX.X
   X.XXXX....XXXX....XXXX....XXXX.X
   X.....XXXX....XXXX....XXXX.....X
   X.XXXXXXXXXXXXXXXXXXXXXXXXXXXX.X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
end
   bricks=84
   goto layoutdone

   rem ---- layout 7: Chevron (28 bricks) ----
layout7
   playfield:
   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   X..............................X
   X.XXXX....................XXXX.X
   X.....XXXX............XXXX.....X
   X.........XXXX....XXXX.........X
   X.............XXXX.............X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
   X..............................X
end
   bricks=28
   goto layoutdone

layoutdone
   layout=layout+1 : layout=layout&7   : rem advance, wrapping 7 -> 0
   player0x=64
   serving=1
   snd=0
   AUDV0=0

main
   drawscreen

   if switchreset then goto init

   rem ----- sound effect -----
   AUDV0=0
   if snd>0 then snd=snd-1 : AUDC0=4 : AUDF0=10 : AUDV0=8

   rem ----- paddle movement -----
   if joy0left then player0x=player0x-3
   if joy0right then player0x=player0x+3
   if player0x<padmin then player0x=padmin
   if player0x>padmax then player0x=padmax

   rem ----- ball waiting to be served -----
   if serving=0 then goto playing
   ballx=player0x+14
   bally=paddley-6
   if joy0fire then serving=0 : bdy=0-spd : bdx=spd
   goto main

playing
   rem collisions reported by drawscreen apply to the ball's current spot
   if collision(ball,player0) then gosub paddlehit
   if collision(ball,playfield) then gosub pfhit

   if bricks=0 then goto levelup

   ballx=ballx+bdx
   bally=bally+bdy

   if bally>lostline then goto lostball
   goto main

   rem ----- ball bounced off the paddle -----
paddlehit
   if bdy>128 then goto paddledone  : rem already travelling upward
   bdy=0-spd
   tmp=ballx-player0x
   if tmp>200 then tmp=0   : rem ball clipped the paddle's left edge
   if tmp<11 then bdx=0-spd
   if tmp>20 then bdx=spd
   AUDC0=12 : AUDF0=20 : AUDV0=8 : snd=3
paddledone
   return

   rem ----- ball touched walls and/or bricks -----
pfhit
   c1=(ballx-17)/4
   c2=(ballx-14)/4
   r1=bally/8
   r2=(bally+3)/8

   rem side walls and ceiling (set direction explicitly so the
   rem ball can't get stuck re-colliding with the wall)
   if ballx<21 then bdx=spd
   if ballx>137 then bdx=0-spd
   if r1=0 then bdy=spd

   rem check the (up to) four cells the ball overlaps
   hit=0
   cx=c1 : cy=r1 : gosub killcell
   cx=c2 : cy=r1 : gosub killcell
   cx=c1 : cy=r2 : gosub killcell
   cx=c2 : cy=r2 : gosub killcell
   if hit>0 then bdy=0-bdy
   return

killcell
   if cx<1 then goto killdone
   if cx>30 then goto killdone
   if cy<1 then goto killdone
   if cy>5 then goto killdone
   if pfread(cx,cy) then goto brickgone
killdone
   return
brickgone
   pfpixel cx cy off
   hit=1
   bricks=bricks-1
   score=score+10
   AUDC0=4 : AUDF0=10 : AUDV0=8 : snd=4
   return

   rem ----- missed the ball -----
lostball
   lives=lives-32
   if lives<32 then goto gameover
   player0x=64
   serving=1
   goto main

   rem ----- cleared the board: next level, next layout -----
levelup
   level=level+1
   score=score+100
   if level>2 then spd=2
   goto newlevel

   rem ----- game over: press FIRE or RESET to play again -----
gameover
   AUDV0=0
   drawscreen
   if switchreset then goto init
   if joy0fire then goto init
   goto gameover
