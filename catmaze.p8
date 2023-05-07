pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- catmaze

maze = {}
cat = {}
cs = 16
house = {}
wc = 6
queue = {}
state = 0
countdown = 0
round = 1
blink = false
light = 0

function _init()
	for x=0,7 do
	  maze[x] = {}
	 for y=0,6 do
	  maze[x][y] = {v=false,
	                r=true,
	                d=true}
	 end
	end
	mkmaze(0,0)
	cat.x = 0
	cat.y = 0
	cat.icon = "🐱"
	cat.color = 9
	house.x = 7
	house.y = 6
	house.icon = "⌂"
	house.color = 12
end

function mkmaze(x,y)
 maze[x][y].v=true
 todo = {}
 local function up()
  if y>0 then
   if not maze[x][y-1].v then
    maze[x][y-1].d=false
    mkmaze(x,y-1)
   end
  end
 end
 local function right()
  if x<7 then
   if not maze[x+1][y].v then
    maze[x][y].r=false
    mkmaze(x+1,y)
   end
  end
 end
 local function down()
  if y<6 then
   if not maze[x][y+1].v then
    maze[x][y].d=false
    mkmaze(x,y+1)
   end
  end
 end
 local function left()
  if x>0 then
   if not maze[x-1][y].v then
    maze[x-1][y].r=false
    mkmaze(x-1,y)
   end
  end  
 end
 add(todo,up)
 add(todo,right,flr(rnd(2)+1))
 add(todo,down,flr(rnd(3)+1))
 add(todo,left,flr(rnd(4)+1))
 for f in all(todo) do
  f()
 end
end

function _update()
 if state == 0 then
  if btnp(❎) or btnp(🅾️) then
   light = 127
   state = 0.5
   countdown = 135
  end
 elseif state == 0.5 then
  countdown = countdown - 1
  if countdown < 70 and
     light > 29 then
    light = light - 2
  end
  if countdown == 0 then
   countdown = 100
   state = 1
  end
 elseif state == 1 then
  if #queue < 10 then
   if btnp(⬆️) then
    add(queue,"⬆️")
   elseif btnp(➡️) then
    add(queue, "➡️")
   elseif btnp(⬇️) then
    add(queue,"⬇️")
   elseif btnp(⬅️) then
    add(queue,"⬅️")
   end
  end
  countdown = countdown - 1
  if countdown == 0 then
   countdown = 100
   state = 2
  end
 elseif state == 2 then
  if (countdown % 10) == 0 then
   nextmove = deli(queue,1)
   if nextmove == "⬆️" then
    if cat.y > 0 then
     if not maze[cat.x][cat.y-1].d then
      cat.y = cat.y - 1
     end
    end
   elseif nextmove == "➡️" then
    if cat.x < 7 then
     if not maze[cat.x][cat.y].r then
      cat.x = cat.x + 1
     end
    end
   elseif nextmove == "⬇️" then
    if cat.y < 6 then
     if not maze[cat.x][cat.y].d then
      cat.y = cat.y + 1
     end 
    end 
   elseif nextmove == "⬅️" then
     if cat.x > 0 then
      if not maze[cat.x-1][cat.y].r then
       cat.x = cat.x - 1
      end
     end
   end
   if house.x == cat.x and 
     house.y == cat.y then
    state = 3
    house.icon = ""
    cat.icon = "♥"
    cat.color = 8
   end
  end
  countdown = countdown - 1
  if countdown == 0 then
   countdown = 100
   state = 1
   round = round + 1
  end
 elseif state == 3 then
  if btnp(❎) or btnp(🅾️) then
   run()
  end
  countdown = countdown - 1
  if countdown == 0 then
   countdown = 100
  end
  if (countdown%10) == 0 then
   if blink then
    blink = false
   else
    blink = true
   end
  end
 end
end

function _draw()
	cls(1)
 line(0,0,127,0,wc)
 line(0,0,0,(127-cs),wc)
 line(127,0,127,(127-cs),wc)
 line(0,127,127,127,wc)
 line(0,112,127,112,wc)
 line(86,113,86,127,wc)
 clip((cat.x*cs)+flr(cs/2)-light,
      (cat.y*cs)+flr(cs/2)-light,
      light*2,light*2)
 for x=0,7 do
 	for y=0,6 do
 	 pset(x*cs+flr(cs/2),
 	      y*cs+flr(cs/2),13)
 		if maze[x][y].r then
 		 line(x*cs+cs,y*cs,
 		       x*cs+cs,y*cs+cs,wc)
 		end
 		if maze[x][y].d then
 		 line(x*cs,y*cs+cs,
 		      x*cs+cs,y*cs+cs,wc) 
 		end
 	end
 end
 clip()
 cursor(cat.x*cs+cs-11,
        cat.y*cs+cs-11, cat.color)
 print(cat.icon)
 cursor(house.x*cs+cs-11,
        house.y*cs+cs-11, house.color)
 print(house.icon)
 if state == 1 then
  pset(2, 118, 11)
  pset(2, 120, 11)
  pset(2, 122, 11)
 elseif state == 2 then
  pset(2, 118, 8)
  pset(2, 120, 8)
  pset(2, 122, 8)
 end
 cursor(5,118,10)
 if state == 0 then
  print("ready? ❎ to start\0")
 elseif state == 0.5 then
  if countdown < 15 then
   print("go!\0")
  else
   print("...\0")
  end
 elseif state == 1 or state == 2 then
  for v in all(queue) do
   print(v.."\0")
  end
 elseif state == 3 then
  print("🐱 happy cat! 🐱\0")
 end
 if state != 3 or blink then
  roundstring = tostr(round)
  width=min(#roundstring,8)
  cursor(122-(width*3),118,7)
  print(round.."\0")
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
