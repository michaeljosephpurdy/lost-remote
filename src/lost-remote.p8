pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- lost and found
-- by: mike purdy

gamestate={}
debug=false
musicplaying=false
function _init()
 gamestate='title'
 player.new()
 --debug
 init_gameover()
 levels.init()
 if debug then
 -- found.gravity=true
  --found.jumping=true
 -- found.player=true
  gamestate='game'
 	levels.set_level(1)
	end
end

function _update()
 if debug and btnp(🅾️) then
  levels.next_level()
 end
 toast.update()
 fireworks.update()
 unlockables.update()
 overlay.update()
 if gamestate=='title' then
  update_title()
 elseif gamestate=='game' then
  update_game()
 else
  update_gameover()
 end
 transition.update()
 if found.playmusic then
  if not musicplaying then
   music(9)
   musicplaying=true
  end
 end
end

function _draw()
 cls()
 if gamestate=='title' then
  draw_title()
 elseif gamestate=='game' then
  draw_game()
 else
  draw_gameover()
 end
 overlay.draw()
 camera(0,0)
 if gamestate=='game' then
  gametimer.draw()
 end
 toast.draw()
 fireworks.draw()
 transition.draw()
 if btnp(🅾️) then
  log(player.get().x)
  log(player.get().y)
 end
end


-->8
-- game

function update_game()
 gametimer.update()
 if not found.player then
 	if btnp(❎) then
 	 unlock.found('player', 'the main character!')
 	end
	else
	end
 player.update()
 entities.update()
 levels.update()
end

function draw_game()
 levels.cam()
 map()
 entities.draw()
 player.draw()
end
-->8
-- levels
local max_mapx=81
local max_mapy=18
local _levels={
 {cx=-1,  cy=-3, px=42,  py=44},
 {cx=15, cy=0,   px=142, py=108},
 {cx=32, cy=0,   px=256, py=108},
 {cx=49, cy=0,   px=392, py=108},
 {cx=66, cy=0,   px=538, py=108},
 {cx=49, cy=0,   px=512, py=12},
 {cx=32, cy=0,   px=376, py=108},
 {cx=15, cy=0,   px=200, py=108},
}
local obstacles={
}
local remote=nil
local gravity=nil
local animation=nil

local replaced_cause_gravity=false
local replaced_cause_not_gravity=false
local _current_level=1

local function cam()
 local l=_levels[_current_level]
 camera(l.cx*8, l.cy*8)
end

local function reset_player()
 player.move(0, 0)
end

local function move_player()
 local l=_levels[_current_level]
 player.move(l.px, l.py)
 if _current_level==5 then
  if found.remote then
   player.move(600, 56)
  end
  if found.gravity then
   player.move(568, 8)
  end
 end
end

local function set_level(i)
 transition.new()
 _current_level=i
 move_player()
end

local function replace(old, new)
 for y=0,max_mapy do
  for x=0,max_mapx do
   local s=mget(x,y)
   if s==old then
    mset(x, y, new)
   end
 	end
	end
end

local function next_level()
 if _current_level==#_levels then
  gamestate='over'
  sfx(3)
  return
 end
 sfx(2)
 reset_player()
 transition.new()
 _current_level+=1
 
 move_player()
 if _current_level==#_levels-1 then
  replace(177, 184)
 end
end

local function build_obstacles()
 for l in all(_levels) do
  for y=l.cy,l.cy+16 do
   for x=l.cx,l.cx+16 do
    local s=mget(x,y)
    local f=fget(s)
    if f==flags.ground or
       f==flags.ouch then
     entities.new(x*8,y*8,s)
     mset(x,y,179)
    end
   end
  end
 end
end

local function init()
 for y=0,max_mapy do
  for x=0,max_mapx do
   local s=mget(x,y)
   -- flag-debugger
   if s==168 then
    log(s..' '..fget(s))
   end
   if fget(s,7) and
      s!=154    and
      s!=185    then
    entities.new(x*8, y*8, s)
    mset(x, y, 132) 
  	else
  	 local f=fget(s)
  	 if f==flags.animation or
  	    f==flags.gravity or
  	    f==flags.jumping or
  	    f==flags.remote or
  	    f==flags.playmusic or
  	    f==flags.door or
  	    f==flags.remotedoor or
  	    f==flags.endingdoor then
  	  entities.new(x*8, y*8, s)
  	  mset(x, y, 179)
  	 end
  	end
 	end
	end
	for l in all(_levels) do
	 l.timer=0
	end
	replace(144, 150)
	set_level(1)
	--build_obstacles()
end

local function update()
 local l=_levels[_current_level]
 l.timer+=1
 local timer=l.timer
 if _current_level==1 then
  if timer>=30 then
   overlay.new(20, 60, "where's the remote?", true)
  end
  if not found.player then
  	if timer>=70 then
  	 overlay.new(49, 80, "wait", true)
  	end
  	if timer>=120 then
  	 overlay.new(35, 90, "where am i?", true)
  	end
  	if timer>=300 then
  	 overlay.new(25, 100, "try pressing ❎...", true)
  	end
  end
  if timer>=300 then timer=300 end
 elseif _current_level==2 then
  if timer<60 then
   overlay.new_over_player('ice?')
  end
  if timer>60 and timer<120 then
   overlay.new_over_player('whats going on?')
  end
  if timer>120 and timer<180 then
  	overlay.new_over_player("these spikes look dangerous")
  end
 end 
 if _current_level==5 and
    found.gravity then
  overlay.new(30, 80, 60, "huh. the ice is gone", false)
 end
end

local function get_number()
 return _current_level
end

local function restart()
 move_player()
end

local function swap(t1, t2)
 for y=0,max_mapy do
  for x=0,max_mapx do
   local s=mget(x,y)
   if s==t1 then
    mset(x, y, t2)
   elseif s==t2 then
    mset(x, y, t1)
   end
 	end
	end
end

local function replace_cause_gravity()
	replace(181, 182)
	swap(165,180)
	replace(179, 183)
	replace(171, 172)
end

local function replace_cause_remote()
	replace(187, 188)
end

levels={
 init=init,
 cam=cam,
 set_level=set_level,
 next_level=next_level,
 update=update,
 get_number=get_number,
 restart=restart,
 replace_cause_gravity=replace_cause_gravity,
 replace_cause_remote=replace_cause_remote,
}
-->8
-- gameover


deaths=0
gameovertimer=0
stats={}

function init_gameover()
	stats={
	 {msg='title screen', key='title_screen'},
	 {msg='time', str='time'},
	 {msg='deaths', str='deaths'},
	 {msg='found clothes', key='player_clothes'},
	 {msg='found gravity', key='gravity'},
	 {msg='found animations', key='animations'},
	 {msg='found music', key='music_playing'},
	 {msg='found the remote', key='remote'},
	}
end

function update_gameover()
 gameovertimer+=1
 if gameovertimer>300 then
  gameovertimer=300
 end
end

function draw_gameover()
 titleprint('thanks for playing!', 20, 8)
 for i,v in ipairs(stats) do
  if gameovertimer>i*30 then
  	if v.key then
  	 if found[v.key] then
	  	 m=v.msg..': '..'yes!'
	  	else
	  	 m=v.msg..': '..'nope'
	  	end
  	else
  	 if v.str=='time' then
  	 	m=v.msg..': '..gametimer.get()
  	 end
  	 if v.str=='deaths' then
  			m=v.msg..': '..tostr(deaths)
  	 end
  	end
  	titleprint(m, 20, i*10+18)
  end
 end
 if gameovertimer>270 then
  titleprint('press enter to reset', 30, 116)
 end
end

-->8
-- unlockables

local function unlock_title_screen()
 if gamestate=='title' then
  if btnp()!=0 then
  end
 end
end

local control_presses=0
local function unlock_controls()
 if not found.player_controller then
  if btnp()!=0 then
   control_presses+=1
  end
 end
 if not pending.player_controller then
  if control_presses>10 then
   found.player_controller=true
 	 unlock.unlock('player_controller',
 	 	'10 button presses!',
 	 	'you found the controls!')
 	end
 end
end

local function update()
 unlock_title_screen()
 --unlock_controls()
end

unlockables={
 update=update
}
-->8
-- player
local p={}
local jumps={-2}
local function new()
 p.x,p.y=0,0
 p.w,p.h=5,8
 p.vx,p.vy=0,0
 p.speed=1.5
 p.dead=0
 p.jump=0
 p.maxjump=#jumps
 p.s=1
 p.frame=1
 p.flip=false
 p.anim=0
 p.jump_height=0
 p.jump_allowed=true
end

local function y_controls()
 if not found.gravity then
  local ts=.1
  local speed=2
 	if btn(⬆️) then p.vy-=.1
 	 if p.vy>0 then p.vy=0 end
 	elseif btn(⬇️) then p.vy+=.1
   if p.vy<0 then p.vy=0 end
 	else
 		if p.vy<0 then
 		 p.vy+=ts
 		 if p.vy>=0 then p.vy=0 end
 		end
 		if p.vy>0 then
 		 p.vy-=ts
 		 if p.vy<=0 then p.vy=0 end
 		end
 	end
 	if p.vy>=speed then p.vy=speed end
	 if p.vy<=-speed then p.vy=-speed end
 end
end

local function x_controls()
 local ts=.2--turnspeed
 local speed=p.speed
 local svel=0
 if not found.gravity and
        levels.get_number()!=1 then
  ts=.1
  speed=1.75
  svel=0
 end
	if btn(➡️) then p.vx+=.1
	 if p.vx<0 then p.vx=0 end
 elseif btn(⬅️) then p.vx-=.1
  if p.vx>0 then p.vx=0 end
 else
  if p.vx<0 then
   p.vx+=ts
   if p.vx>=0 then p.vx=0 end
  end
  if p.vx>0 then
   p.vx-=ts
   if p.vx<=0 then p.vx=0 end
  end
 end
 if p.vx>=speed then p.vx=speed end
 if p.vx<=-speed then p.vx=-speed end
end

local function calculate_animation_frame()
	if found.animation then
  p.flip=false
  if p.vx<0 then
   p.flip=true
  end
  p.anim+=.5
  if p.anim>11 then p.anim=2 end
  p.frame=flr(p.anim)
  if p.vx==0 then
   p.frame=1
  end
 end
end

local function head_collide()
 local ouch=false
  --head flag
 local colliders={
  {x=(p.x+2),y=(p.y-3)},
 }
 for c in all(colliders) do
  local f=fget(mget(m(c.x),m(c.y)))
  if f==flags.ground then
   ouch=true
   log('head')
  end
 end
 return ouch
end

local function on_ground()
 local colliders={
--  {x=(p.x+1),y=(p.y+4)},
  {x=(p.x+2),y=(p.y+4)},
--  {x=(p.x+3),y=(p.y+4)}, 
 }
	local onground=false
	for c in all(colliders) do
	 local f=fget(mget(m(c.x),m(c.y)))
	 if f==flags.ground then
	  onground=true
	 end
	end
	log('onground'..tostr(onground))
	return onground
end

local function fix_y()
 for i=0,8 do
  local f=fget(mget(m(p.x+2),m(p.y+3)))
	 if f==flags.ground then
   log('fixing y')
	  p.y-=1
	 end
 end
end

local function update()
 if p.dead>0 then
  p.dead-=1
  if p.dead<=1 then
   deaths+=1
   levels.restart()
  end
  return
 else
  p.dead=0
 end
 local oldx=p.x
 local oldy=p.y
 if found.player then
  x_controls()
  if levels.get_number()!=1 then
   if not found.gravity then
    y_controls()
   end
  end
 end
 
 if found.jumping and
    btn(❎) and
 		 p.jump_height<20 and
  		p.jump_allowed then
  p.vy=-3
  p.jump_height+=1
 else
  if found.gravity and
     not on_ground() then
   p.vy+=.4
   if on_ground() then p.vy=0 end
  end
 end

	if p.jump_height>=10 or
	   not p.jump_allowed then
	 p.jump_allowed=false
	 p.jump_height=0
 end
 
 if on_ground() then
  p.jump_allowed=true
  if found.gravity and
     p.jump_height<=0 then
   p.vy=0
  end
 end
 
 --meat and potatoes
 p.x=p.x+p.vx
 p.y=p.y+p.vy
 
 if not found.gravity and on_ground() then
  p.y=ceil(oldy)
 end
 
 fix_y()
 
 if head_collide() then
  p.y=ceil(oldy)
  p.vy=0
  p.jump=0
 end
 
 calculate_animation_frame() 
 
 --flag
 p.fx,p.fy=(p.x+2),(p.y)
 local flag_body={
  fget(mget(m(p.fx),m(p.fy))),
  --fget(mget(m(p.fx-1),m(p.fy+1))),
  --fget(mget(m(p.fx-1),m(p.fy+2))),
  --fget(mget(m(p.fx-1),m(p.fy+3))),
  --fget(mget(m(p.fx+1),m(p.fy))),
  --fget(mget(m(p.fx+1),m(p.fy+1))),
  --fget(mget(m(p.fx+1),m(p.fy+2))),
  --fget(mget(m(p.fx+1),m(p.fy+3))),
 }
 --body_collisions
 for f in all(flag_body) do
  if f==flags.ouch then
   p.vx,p.vy=0,0
	  p.dead=20
	  sfx(1)
	  return
	 end 
  if f==flags.wall then
   p.x=round(oldx)
   p.y=round(oldy)
   p.vx=0
   p.vy=0
  end
  if f==flags.ground then
   p.x=round(oldx)
   p.vx=0
  end
 end

 local ent_collisions=entities.collides(p)
 if #ent_collisions>=1 then
  local e=ent_collisions[1]
  if e!=nil then
   overlay.new_over_player('press ❎')
   if btnp(❎) then
  	 local f=fget(e.s)
  	 if f==flags.remote then
  	  unlock.found('remote', 'the remote!')
  	  entities.delete(e)
  	  levels.replace_cause_remote()
  	  entities.remove_after_remote()
  	 elseif f==flags.door or
  	        e.s==128 or
  	        f==flags.remotedoor then
  	 	levels.next_level()
  	 elseif f==flags.gravity then
  	  levels.replace_cause_gravity()
  	  unlock.found('gravity', 'gravity!')
  	  entities.delete(e)
  	 elseif f==flags.animation then
  	  unlock.found('animation', 'animations!')
  	  entities.delete(e)
  	 elseif f==flags.playmusic then
  	  unlock.found('playmusic', 'music!')
  	  entities.delete(e)
  	 elseif f==flags.endingdoor then
  	  if levels.get_number()==2 then
  	   levels.set_level(1)
  	  else
  	   levels.next_level()
  	  end
  	 elseif f==flags.jumping then
  	  unlock.found('jumping', 'how to jump!')
  	  entities.delete(e)
  	 end
   end
  end
  if fget(e.s,0) and fget(e.s,1) then
   if e.s==129 and btnp(❎) then
    found.player_clothes=true
    unlock.found('player_clothes', 'some clothes!')
    e.s=145
   end
  end
  p.collides=true
 else
  p.collides=false
 end
end

local naked_animation={
 1,2,3,4,5,6,7,8,9,10,11
}
local clothed_animation={
 17,18,19,20,21,22,23,24,25,26,27
}

local function draw()
 palt(0, false)
 palt(1, true)
 if found.player then
  local x=p.x-1
  local y=p.y-4
  if p.dead>0 then
   for i=0,1,.05 do
    local sx=x+(sin(i)*p.dead/10)
    local sy=y+(cos(y)*p.dead/10)
   	circfill(sx, sy, (p.dead%8)/2, 8)
   end
 	else
   if found.player_clothes then
    local s=clothed_animation[p.frame]
  		spr(s,x,y, 1, 1, p.flip)
  	else
  	 local s=naked_animation[p.frame]
  		spr(s,x,y, 1, 1, p.flip)
  	end
  end
 end
 palt()
end

local function get()
 return p
end

local function move(x, y)
 log(x..y)
 p.x,p.y=x,y
end

player={
 new=new,
 update=update,
 draw=draw,
 get=get,
 move=move,
}
-->8
-- gametimer

local seconds=0
local minutes=0

local function init()
 seconds=0
 minutes=0
end

local function update()
 seconds+=30/1000
 if seconds>=60 then
  minutes+=1
  seconds='0'
 end
end

local function get()
 s=''
 if flr(minutes)<10 then
  s=s..'0'
 end
 s=s..flr(minutes)
 s=s..':'
 if flr(seconds)<10 then
  s=s..'0'
 end
 s=s..flr(seconds)
 return s
end

local function draw()
 local t=get()
 camera()
 vpprint(t, 108, 122)
end


gametimer={
 update=update,
 draw=draw,
 get=get,
 init=init,
}
-->8
-- tiles

local function init()
end

local function pickup()
end

local function update()
end

local function draw()
end

flags={
 ouch=33,--should be 21?,
 wall=5,
 gravity=24,
 animation=63,
 door=3,
 ground=16,
 remote=255,
 gravity=127,
 animation=63,
 jumping=31,
 playmusic=15,
 remotedoor=147,
 endingdoor=99,
}

tiles={
 init=init,
 pickup=pickup,
 update=update,
 draw=draw,
}
-->8
-- entities
local ents={}
local remove_later={}
local function new(x, y, s)
 local f=fget(s)
 local hidden=false
 if (f==flags.gravity or
     f==flags.animation or
     f==flags.jumping or
     f==flags.remotedoor) then
  hidden=true
 end
 local e={
  x=x, y=y, s=s, w=8, h=8, hidden=hidden
 }
 if f==flags.door then
  add(remove_later, e)
 end
 add(ents, e)
end

local function update()
 for e in all(ents) do
  if e.state=='move' then
   e.x+=e.dx
   e.y+=e.dy
  end
  if found.remote then
   e.hidden=false
  end
 end
end

local function draw()
 for e in all(ents) do
  if not e.hidden then
  	spr(e.s, e.x, e.y)
  end
 end
end

local function collides(o)
 local _ents={}
 for e in all(ents) do
  if not e.hidden then
  	if collide(o, e) then
  	 if fget(e.s, 0) then
  	 	add(_ents, e)
  	 end
  	end
  end
 end
 return _ents
end

local function delete(e)
 for _e in all(ents) do
  if e==_e then
   del(ents, e)
  end
 end
end

local function remove_after_remote()
 for e in all(remove_later) do
  del(ents, e)
 end
end

entities={
 new=new,
 update=update,
 draw=draw,
 collides=collides,
 delete=delete,
 remove_after_remote=remove_after_remote,
}
-->8
-- transition
local fills={
 0b0000000000000000,
 0b1000100010001000,
 0b1100110011001100,
 0b1110111011101110,
 0b1111111111111111,
}
local t=false
local t_time=0
local fill=1

local function new()
 t=true
end

local function update()
 if t then
  fillp(fills[flr(t_time)])
 	t_time+=.5
  if t_time > 5 then
   t=nil
   t_time=0
   fill=1
   fillp()
  end
 end
end

local function draw()
 if t then
  palt(0, false)
  palt(1, true)
  rectfill(0, 0, 128, 128, 1)
  palt()
 end
end

transition={
 new=new,
 update=update,
 draw=draw
}
-->8
-- overlay
local _overlays={}

local function new(x, y, msg, title)
 local o={x=x, y=y, msg=msg, title=title}
 add(_overlays, o)
end

local function new_over_player(msg)
 local p=player.get()
	overlay.new(p.x-#msg*2, p.y-8, msg)
end

local function new_centered(msg)
 overlay.new(64-#msg*2.25, 80, msg)
end

local function update()
 _overlays={}
end

local function draw()
 for o in all(_overlays) do
  if o.title then
   titleprint(o.msg, o.x, o.y)
  else
   vpprint(o.msg, o.x, o.y)
  end
 end
end

overlay={
 new=new,
 new_centered=new_centered,
 new_over_player=new_over_player,
 draw=draw,
 update=update
}
-->8
-- title
local remotex=48
local remotey=48
local t=-1
local t1=0
function update_title()
 t+=.005
 t1+=1
 if t>=1 then t=-1 end
 if found.title_screen then
  if btnp(❎) then
   gamestate='game'
  end
 end
 if t1>160 then
  unlock.found('title_screen', 'the title screen!', true)
 end
 if t1>=220 then t1=220 end
end

function draw_title()
 local x=sin(t)*5+60
 local y=cos(t)*5+60
 if t1>10 then
	 spr(238, x, y, 2, 2)
	end
 if t1>=60 then
  titleprint('lost remote', x+20, y+8)
 end
 if t1>=110 then
  titleprint('by mike purdy', x+5, y+18)
 end
 if t1>=160 then
  titleprint('press ❎', x-28, y-4)
 end
end
-->8
-- found/unlock

found={}
pending={}
locked={}

local function init()
 found={}
 pending={}
 locked={}
end

local function base_unlock(n, msg1, msg, title)
 if pending[n] then return end
 locked[n]=false
 found[n]=true
 local fn=function()
  --delayed
 -- locked[n]=false
 -- found[n]=true
 -- fireworks.new()
 end
 pending[n]=true
 toast.new({msg1, msg}, fn, title)
end

local function _found(n, msg, title)
 base_unlock(n, 'you found', msg, title)
end

local function _unlock(n, msg1, msg, title)
 base_unlock(n, msg1, msg)
end

unlock={
 update=update,
 draw=draw,
 unlock=_unlock,
 found=_found,
 init=init,
}
-->8
-- effects

local _fireworks={}

local function new(x,y,dx,dy)
 if not x then x=40 end
 if not y then y=40 end
 if not dx then dx=0 end
 if not dy then dy=-2 end
 add(_fireworks, {
  x=x,dx=dx,y=y,dy=dy,
  timer=200
 })
end

local function explode(f)

end

local function update()
 for f in all(_fireworks) do
  f.x+=f.dx
  f.y+=f.dy--gravity
  f.dy+=.05
  f.timer-=1
  if f.timer<0 then
   del(_fireworks.f)
  end
 end
end

local function draw()
 for f in all(_effects) do
  circfill(f.x,f.y,f.r,f.c)
 end
end

fireworks={
 new=new,
 update=update,
 draw=draw,
}
-->8
local toasts={}


local function new(msg, fn, title)
 if fn==nil then
  fn=function()end
 end
 local toast={}
 for i,v in ipairs(msg) do
  add(toast, {msg=v, x=64, y=-10*i*i, w=#v*2, timer=70, limity=10*i, fn=fn, title=title})
 end
 add(toasts, toast)
end
 
local function update()
 local toast=toasts[1]
 if toast==nil then return end
 for t in all(toast) do
  if t.y>0 then t.timer-=1 end
 	if t.y<t.limity then t.y+=2 end
 	if t.timer<0 then
 	 del(toasts, toast)
 	 t.fn()
 	end
 end
end

local function draw()
 local toast=toasts[1]
 if toast==nil then return end
 for t in all(toast) do
  if t.title then
   titleprint(t.msg, t.x-t.w, t.y)
  else
   vpprint(t.msg, t.x-t.w, t.y)
  end
 end
end

toast={
 new=new,
 update=update,
 draw=draw
}
-->8
-- functions

function round(i)
 local d=(i-flr(i))*10
 if d>=5 then return ceil(i) end
 return flr(i)
end

function log_table(t)
 log('{')
 for k,v in ipairs(t) do
  log(' '..k..': '..v..',')
 end
 log('}')
end

function log(msg)
 printh(msg, '2ndattemptggj2021')
end

function pprint(str, x, y, c)
-- print(str, x-1, y-1, c)
 print(str, x-1, y, c)
 print(str, x-1, y+1, c)
 print(str, x, y-1, c)
 print(str, x, y, c)
 print(str, x, y+1, c)
 print(str, x+1, y-1, c)
 print(str, x+1, y, c)
-- print(str, x+1, y+1, c)
end
 
function collide(e1,e2)
 return e1.x+e1.w>e2.x and
        e1.x<e2.x+e2.w and
        e1.y+e1.h>e2.y and
        e1.y<e2.y+e2.h
end

function vpprint(msg, x, y)
 palt(0, false)
 pprint(msg, x, y, 0)
 print(msg, x, y, 9)
 palt()
end

function titleprint(msg, x, y)
 pprint(msg, x, y, 5)
 print(msg, x, y, 9)
end

function m(i)
 return flr(flr(i)/8)
end
__gfx__
00000000111011111111011111110111111101111111011111110111111101111111011111110111111101111111011111011111000000000000000000000000
00000000110f01111110f0111110f0111110f0111110f0111110f0111110f0111110f0111110f0111110f0111110f01110f00111000000000000000000000000
00700700110f0111110f0111110f0011110f0111110f0111110f0111110f0111110f0111110f0111110f0111110f0111100ff011000000000000000000000000
0007700010fff01110fff01110ffff0110fff01110fff01110fff01110fff01110fff01110fff01110fff01110fff0110ffff011000000000000000000000000
0007700010fff0110f0f0f010f0f001110ff0f0110fff0110f0f0f010f0f0f010f0ff0110f0ff01110ff011110fff011100f0111000000000000000000000000
00700700110f0111100ff011100ff011110f0011110f0111100ff011100f0111100f0111100f0111110f0111110f0111110f0111000000000000000000000000
0000000010f0f01110f0f01110f0f01110ff0111110ff01110f0f01110f0f0110ff0f0110fff0111110ff011110ff0111110f011000000000000000000000000
0000000010f0f01110f001110f0101110f0f011110ff011110f001110f00f0111000f011100f0111110f011110f0f011110f0f01000000000000000000000000
00000000111011111111011111110111111101111111011111110111111101111111011111110111111101111111011111011111000000000000000000000000
00000000110f01111110f0111110f0111110f0111110f0111110f0111110f0111110f0111110f0111110f0111110f01110f00111000000000000000000000000
00000000110f0111110f0111110f0011110f0111110f0111110f0111110f0111110f0111110f0111110f0111110f0111110ff011000000000000000000000000
00000000108880111088801110888f0110888011110880111088801110888011108880111088801110888011108880110f888011000000000000000000000000
0000000010f8f0110f080f010f08001110f80f01110f01110f080f010f080f010f08f0110f08f01110f8011110f8f01111080111000000000000000000000000
00000000110801111008c0111008c01111080011110801111008c011100800111008011110080111110801111108011111080111000000000000000000000000
0000000010c0c01110c0c01110c0c01110cc0111110cc01110c0c01110c0c0110cc0c0110ccc0111110cc011110cc0111110c011000000000000000000000000
0000000010c0c01110c001110c0101110c0c011110cc011110c001110c00c0111000c011100c0111110c011110c0c011110c0c01000000000000000000000000
00855550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00656560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00656560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00656560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00444400000000000000000000aaaa00ddddeddd2222222267766776400000000000000400000000000000007777777000000000666666660444444000000000
04444440556556550000000000aaaa00dddddddd2222222276677667400000000000000400006600000000007777777000000000655555560444444000000000
44444444506006059000000000aaaa00eddddddd2222222276677667400444444444400400000600000000007777777066666660655555560444444000000000
444444445888ccc59770000000099000dddddddd2222222267766776400004000040000400000600000000006777777077777770655555560444444000000000
444449945080c0c59111111100099000ddddeddd22222222677667764111040000401114ddd6666ddddddddd7777777077777770655555560444444000000000
444449945080c0c59111111104444440dddddddd2222222276677667444404000040444499499994994994996666666077777770666666660444444000000000
444444445000c0c59222222204000040eddddddd2222222276677667400404000040400499499994994994997777777077777770000660000444444000000000
44444444500000059000000904000040dddddddd2222222267766776400404000040400499499994994994997777777077777770066666600444444000000000
00000000000000003b333b33444444444444444444444444000000000000000066666666cccccccccccc85cc0000000000000000000000000000000000000000
000000005555555533333333444544455444445444545444000000000000000065555556ccccccccccc5565c0000000000000000000000000000000000000000
000000005060060532233233444444444444444444444444000000000000000065555556cccccccccc5655650000000000000000000000000000000000000000
000800005666666524422423444454444444444c44444444000000000000000065555556ccccccccc56565550000000000000000000000000000000000000000
00000000500000054444444244444444444444cc44444c44000000000000000065555556cccccccc5656565c0000000000000000000000000000000000000000
00000000500000054544454445444444c4cc44ccc444cc4c000000000000000066666666cccccccc556565cc0000000000000000000000000000000000000000
00000000500000054444444444444444ccccc4cccccccccc000000000000000000066000ccccccccc5565ccc0000000000000000000000000000000000000000
00000000500000054454444444444454cccccccccccccccc000000000000000006666660cccccccccc55cccc0000000000000000000000000000000000000000
cccccccccccccccc00000000cc7711cccc7711cccc4444cceeeeeeeeeeeeeeeecc7711cccc77cccccc7711cccccccccccccccccc000000000000000000000000
cccccccccccccccc06060060c718821cc718882cc444444ce888e888e888e888c788882cc77cccccce21182cc6c6cc6ccccccccc000000000000000000000000
ccc2222222222ccc00dd0d00718218217182111144444444eeeeeeeeeeeeeeee7111821177cccccc78828821ccddcdcccccccccc000000000000000000000000
ccc2222222222ccc00055d6071821821718211114444444488e88ee444ee88e8711182117cccccc778282821ccc55d6ccccccccc000000000000000000000000
c22eeeeeeeeee22c06d55000118888211182882144444994eeeeee44444eeeee11118211cccccc7718211821c6d55ccccccccccc000000000000000000000000
2888e888e888e88200d0dd00118218211182182144444994e888e8444448e88811828211ccccc77c18211821ccdcddcccccccccc000000000000000000000000
eeeeeeeeeeeeeeee06006060c182182cc188882c44444444eeeeee44494eeeeec188821ccccc77ccc821182cc6cc6c6ccccccccc000000000000000000000000
88e88e88e88e88e800000000cc1111cccc1111cc4444444488e88e44444e88e8cc1111ccccc77ccccc1111cccccccccccccccccc000000000000000000000000
eeeeeeeeeeeeeeeecccccccccc77ccccc888cccccc77cccccccccccccccccccceeeeeeeecc9999cccc4444cccc77cccccccccccc000000000000000000000000
e888e888e888e888c6c6cc6cc77cccccc87cccccc77ccccccccccccccccccccce888e888c999999cc444444cc77cccccc6c6cc6c000000000000000000000000
eeeeeeeeeeeeeeeeccddcdcc77cccccc78c8cccc77cccccccccccccccccccccceeeeeeee999999994444444477ccccccccddcdcc000000000000000000000000
88e88ee444ee88e8ccc55d6c7cccccc77888ccc77cccccc7cccccccccccccccc44ee88e899999999444444447cccccc7ccc55d6c000000000000000000000000
eeeeee44444eeeeec6d55ccccccccc77ccccc888cccccc77cccccccccccccccc444eeeee9999944944444994cccccc77c6d55ccc000000000000000000000000
e888e8444448e888ccdcddccccccc77cccccc88cccccc77ccccccccccccccccc4448e8889999944944444994ccccc77cccdcddcc000000000000000000000000
eeeeee44494eeeeec6cc6c6ccccc77cccccc78cccccc77cccccccccccccccccc494eeeee9999999944444444cccc77ccc6cc6c6c000000000000000000000000
88e88e44444e88e8ccccccccccc77cccccc77888ccc77ccccccccccccccccccc444e88e89999999944444444ccc77ccccccccccc000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000550000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005555500000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005885555000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555655550
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055655556550
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555656555500
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555556565500
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005565555565000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005565655555000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555656550000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000056555556550000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000556565555500000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555565655500000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005555655000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000550000000
__label__
3b333b33cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
33333333c6c6cc6cc6c6cc6cc6c6cc6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
32233233ccddcdccccddcdccccddcdcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
24422423ccc55d6cccc55d6cccc55d6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
44444442c6d55cccc6d55cccc6d55ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
45444544ccdcddccccdcddccccdcddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
44444444c6cc6c6cc6cc6c6cc6cc6c6ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
44544444cccccccccccccccccccccccccccccc0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
44444444ccccccccccccccccccccccccccccc0f0cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
44454445c6c6cc6cc6c6cc6cc6c6cc6cccccc0f0cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
44444444ccddcdccccddcdccccddcdcccccc0fff0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
44445444ccc55d6cccc55d6cccc55d6ccccc0fff0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
44444444c6d55cccc6d55cccc6d55cccccccc0f0cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
45444444ccdcddccccdcddccccdcddcccccc0f0f0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
44444444c6cc6c6cc6cc6c6cc6cc6c6ccccc0f0f0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
44444454cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
44444444cccccccccccccccccccccccc3b333b33cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3b333b333b333b333b333b33
44454445cccccccccccccccccccccccc33333333cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc333333333333333333333333
44444444cccccccccccccccccccccccc32233233cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc322332333223323332233233
44445444cccccccccccccccccccccccc24422423cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc244224232442242324422423
44444444cccccccccccccccccccccccc44444442cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc444444424444444244444442
45444444cccccccccccccccccccccccc45444544cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc454445444544454445444544
44444444cccccccccccccccccccccccc44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc444444444444444444444444
44444454cccccccccccccccccccccccc44544444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc445444444454444444544444
44444444cccccccccccccccccccccccc444444443b333b33cccccccccccccccccccccccccccccccccccccccccccccccccccccccc444444444444444444444444
44454445cccccccccccccccccccccccc4445444533333333cccccccccccccccccccccccccccccccccccccccccccccccccccccccc445454445444445444454445
44444444cccccccccccccccccccccccc4444444432233233cccccccccccccccccccccccccccccccccccccccccccccccccccccccc444444444444444444444444
44445444cccccccccccccccccccccccc4444544424422423cccccccccccccccccccccccccccccccccccccccccccccccccccccccc444444444444444c44445444
44444444cccccccccccccccccccccccc4444444444444442cccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444c44444444cc44444444
45444444cccccccccccccccccccccccc4544444445444544ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc444cc4cc4cc44cc45444444
44444444cccccccccccccccccccccccc4444444444444444ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4cc44444444
44444454cccccccccccccccccccccccc4444445444544444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444454
44444444cccccccccccccccccccccccc44444444444444443b333b33cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444444
44454445cccccccccccccccccccccccc444544454454544433333333cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44454445
44444444cccccccccccccccccccccccc444444444444444432233233cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444444
44445444cccccccccccccccccccccccc444454444444444424422423cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44445444
44444444cccccccccccccccccccccccc4444444444444c4444444442cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444444
45444444cccccccccccccccccccccccc45444444c444cc4c45444544cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc45444444
44444444cccccccccccccccccccccccc44444444cccccccc44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444444
44444454cccccccccccccccccccccccc44444454cccccccc44544444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444454
44444444cccccccccccccccccccccccc44444444cccccccc444444443b333b33cccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444444
44454445cccccccccccccccccccccccc54444454cccccccc4454544433333333cccccccccccccccccccccccccccccccccccccccccccccccccccccccc44454445
44444444cccccccccccccccccccccccc44444444cccccccc4444444432233233cccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444444
44445444cccccccccccccccccccccccc4444444ccccccccc4444444424422423cccccccccccccccccccccccccccccccccccccccccccccccccccccccc44445444
44444444cccccccccccccccccccccccc444444cccccccccc44444c4444444442cccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444444
45444444ccccccccccccccccccccccccc4cc44ccccccccccc444cc4c45444544cccccccccccccccccccccccccccccccccccccccccccccccccccccccc45444444
44444444ccccccccccccccccccccccccccccc4cccccccccccccccccc44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444444
44444454cccccccccccccccccccccccccccccccccccccccccccccccc44544444cccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444454
44444444cccccccccccccccccccccccccccccccccccccccccccccccc44444444cccccccccccccccccccccccccccccccccccccccc3b333b33cccccccc44444444
44454445cccccccccccccccccccccccccccccccccccccccccccccccc54444454cccccccccccccccccccccccccccccccccccccccc33333333cccccccc44454445
44444444cccccccccccccccccccccccccccccccccccccccccccccccc44444444cccccccccccccccccccccccccccccccccccccccc32233233cccccccc44444444
44445444cccccccccccccccccccccccccccccccccccccccccccccccc4444444ccccccccccccccccccccccccccccccccccccccccc24422423cccccccc44445444
44444444cccccccccccccccccccccccccccccccccccccccccccccccc444444cccccccccccccccccccccccccccccccccccccccccc44444442cccccccc44444444
45444444ccccccccccccccccccccccccccccccccccccccccccccccccc4cc44cccccccccccccccccccccccccccccccccccccccccc45444544cccccccc45444444
44444444ccccccccccccccccccccccccccccccccccccccccccccccccccccc4cccccccccccccccccccccccccccccccccccccccccc44444444cccccccc44444444
44444454cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44544444cccccccc44444454
44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3b333b33cccccccccccccccccccccccc44444444cccccccc44444444
44454445cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc33333333cccccccccccccccccccccccc44545444cccccccc44454445
44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc32233233cccccccccccccccccccccccc44444444cccccccc44444444
44445444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc24422423cccccccccccccccccccccccc44444444cccccccc44445444
44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444442cccccccccccccccccccccccc44444c44cccccccc44444444
45444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc45444544ccccccccccccccccccccccccc444cc4ccccccccc45444444
44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444444cccccccccccccccccccccccccccccccccccccccc44444444
44444454cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44544444cccccccccccccccccccccccccccccccccccccccc44444454
44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444444cccccccccccccccccccccccccccccccccccccccc44444444
44454445cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc54444454cccccccccccccccccccccccccccccccccccccccc44454445
44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444444cccccccccccccccccccccccccccccccccccccccc44444444
44445444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4444444ccccccccccccccccccccccccccccccccccccccccc44445444
44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc444444cccccccccccccccccccccccccccccccccccccccccc44444444
45444444ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4cc44cccccccccccccccccccccccccccccccccccccccccc45444444
44444444ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4cccccccccccccccccccccccccccccccccccccccccc44444444
44444454cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444454
44444444cccccccccccccccccccccccc3b333b33cccccccccccccccc3b333b33cccccccccccccccccccccccc3b333b33cccccccccccccccccccccccc44444444
44454445cccccccccccccccccccccccc33333333cccccccccccccccc33333333cccccccccccccccccccccccc33333333cccccccccccccccccccccccc44454445
44444444cccccccccccccccccccccccc32233233cccccccccccccccc32233233cccccccccccccccccccccccc32233233cccccccccccccccccccccccc44444444
44445444cccccccccccccccccccccccc24422423cccccccccccccccc24422423cccccccccccccccccccccccc24422423cccccccccccccccccccccccc44445444
44444444cccccccccccccccccccccccc44444442cccccccccccccccc44444442cccccccccccccccccccccccc44444442cccccccccccccccccccccccc44444444
45444444cccccccccccccccccccccccc45444544cccccccccccccccc45444544cccccccccccccccccccccccc45444544cccccccccccccccccccccccc45444444
44444444cccccccccccccccccccccccc44444444cccccccccccccccc44444444cccccccccccccccccccccccc44444444cccccccccccccccccccccccc44444444
44444454cccccccccccccccccccccccc44544444cccccccccccccccc44544444cccccccccccccccccccccccc44544444cccccccccccccccccccccccc44444454
44444444cccccccccccccccccccccccc44444444cccccccccccccccc44444444cccccccccccccccccccccccc44444444cccccccccccccccccccccccc44444444
44454445cccccccccccccccccccccccc44545444cccccccccccccccc54444454cccccccccccccccccccccccc54444454cccccccccccccccccccccccc44454445
44444444cccccccccccccccccccccccc44444444cccccccccccccccc44444444cccccccccccccccccccccccc44444444cccccccccccccccccccccccc44444444
44445444cccccccccccccccccccccccc44444444cccccccccccccccc4444444ccccccccccccccccccccccccc4444444ccccccccccccccccccccccccc44445444
44444444cccccccccccccccccccccccc44444c44cccccccccccccccc444444cccccccccccccccccccccccccc444444cccccccccccccccccccccccccc44444444
45444444ccccccccccccccccccccccccc444cc4cccccccccccccccccc4cc44ccccccccccccccccccccccccccc4cc44cccccccccccccccccccccccccc45444444
44444444ccccccccccccccccccccccccccccccccccccccccccccccccccccc4ccccccccccccccccccccccccccccccc4cccccccccccccccccccccccccc44444444
44444454cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444454
44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3b333b3344444444
44454445cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3333333344454445
44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3223323344444444
44445444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2442242344445444
44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4444444244444444
45444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4544454445444444
44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4444444444444444
44444454cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4454444444444454
44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4444444444444444
54444454cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5444445444454445
44444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4444444444444444
4444444ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4444444c44445444
444444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc444444cc44444444
c4cc44ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4cc44cc45444444
ccccc4ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4cc44444444
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444454
cc9999cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444444
c999999cccccccccccccccccccccccccc6c6cc6cc6c6cc6cc6c6cc6cc6c6cc6cc6c6cc6cc6c6cc6cc6c6cc6cc6c6cc6cc6c6cc6cc6c6cc6cc6c6cc6c44454445
99999999ccccccccccccccccccccccccccddcdccccddcdccccddcdccccddcdccccddcdccccddcdccccddcdccccddcdccccddcdccccddcdccccddcdcc44444444
99999999ccccccccccccccccccccccccccc55d6cccc55d6cccc55d6cccc55d6cccc55d6cccc55d6cccc55d6cccc55d6cccc55d6cccc55d6cccc55d6c44445444
99999449ccccccccccccccccccccccccc6d55cccc6d55cccc6d55cccc6d55cccc6d55cccc6d55cccc6d55cccc6d55cccc6d55cccc6d55cccc6d55ccc44444444
99999449ccccccccccccccccccccccccccdcddccccdcddccccdcddccccdcddccccdcddccccdcddccccdcddccccdcddccccdcddccccdcddccccdcddcc45444444
99999999ccccccccccccccccccccccccc6cc6c6cc6cc6c6cc6cc6c6cc6cc6c6cc6cc6c6cc6cc6c6cc6cc6c6cc6cc6c6cc6cc6c6cc6cc6c6cc6cc6c6c44444444
99999999cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444454
3b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b333b33
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
32233233322332333223323332233233322332333223323332233233322332333223323332233233322332333223323332233233322332333223323332233233
24422423244224232442242324422423244224232442242324422423244224232442242324422423244224232442242324422423244224232442242324422423
44444442444444424444444244444442444444424444444244444442444444424444444244444442444444424444444244444442444444424444444244444442
45444544454445444544454445444544454445444544454445444544454445444544454445444544454445444544454445444544454445444544454445444544
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44544444445444444454444444544444445444444454444444544444445444444454444444544444445444444454444444544444445444444454444444544444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
54444454445454444454544444545444544444544454544454444454544444545444445444545444544444544454544454444454445400000000544400000000
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444099909990400099909990
4444444c4444444444444444444444444444444c444444444444444c4444444c4444444c444444444444444c444444444444444c444090900090090000909090
444444cc44444c4444444c4444444c44444444cc44444c44444444cc444444cc444444cc44444c44444444cc44444c44444444cc444090900990000409909090
c4cc44ccc444cc4cc444cc4cc444cc4cc4cc44ccc444cc4cc4cc44ccc4cc44ccc4cc44ccc444cc4cc4cc44ccc444cc4cc4cc44ccc44090900090090c00909090
ccccc4ccccccccccccccccccccccccccccccc4ccccccccccccccc4ccccccc4ccccccc4ccccccccccccccc4ccccccccccccccc4ccccc09990999000c099909990
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000cccc00000000c

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8383808040101080808080808080800005801010101005008000ff00000000000505213f7f0305051f000f21000000000505210000050500639393002100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
000000000000000000000000009090abababababababababababababababab90abababababababababababababababab9092ababababababababababababababab90b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008484848484840000009090b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b290b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b39093abababa3b3b3b3b3b3b3b3b3b3b3a590b2b3b3b3a4b3b3b3b3b3b3b3b3b3b3b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000084848484848484848484009090b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b290b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b39093b3b3b392b3b3b3abb3b3abb392929290b2abab9292929292b2b2b2b2b3b3b3b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
908484848484848484848484849090b3b2b2b2b2b2b2b3b3b3929292b3b3b290b3b3b3b3b3b3b3b3b3b3b3b392b3b3b39093b3b3b39392b3b3b3b3b3b3b395949390b2b3b39495949594b2b3b3b3b3b3b3b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9084848484848484848484848c9090b3b3b3b3b3b2b3b3b3b2949394b3b3b290b3b3b3b3b392b3b392b3b3b393b3b3b39093b3b3b3939592b3b3b3b3b3b3b3b39390b2b3b3b2b2b2b2b2b3b3b3b3b3b3b3b290909090909090a29090909090900000000000000000000000000000000000000000000000000000000000000000
908183828d8480848788898a8b9090b2b2b2b3b3b2b3b3b3b3b295b3b3b3b290b3b392b3b395b2b294b3b3b393b3b3929093b3b3b394b39592b3b3b3abb3b3b39390b2b3b3b3b3b3b3b2b3b3b3b2b2b2b2b200000000000000a20000000000900000000000000000000000000000000000000000000000000000000000000000
908585858585858586868686869090b3b3b3b3b2b3b3b3b3b3b3b2b3b3b3b290b3b395b2b2b2b3b3b2b3b3b393b3b3949093b3b3b3b3b3b394b3b3b3b3b392b39390b2b3b3b3b3b3b3b2b3b3b3b3b3b3b3b292929200000000a20000000000900000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000090b3aab3b3b2b3b3b3b3b3b3b2b3b392b29092b3b3b3b3b3b3b3b2b3b3b393b3b3b39093b3b3b3b3b3b3b3b392b3b3b395b39390b2b3b3b3b3b3b3b2b3b39ab3b3b3b3b2959495a2000000a2a500000000900000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009090b392b3b2b3b3b3b2b2b3b3b2b3ab95b29093b3b3b3b3b3b3b3b2b3b3b39392b3b39093b3b3b3abb3b3b3b394b3b3b3abb39390b2b3b3b3b2b3b3b2929292b3b3b3b3b20000a2a20000a2a29292000000900000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009090b394b3b2b3b3b3b3b3b3b3b2b3b3b3b29093b3b3b3b3b3b3b3b2b3b3b39394b3b39093b3b3b3b3b3b3b3b3b3b392b3b3b39390b2b3b3b3b2b3b3b2959594b3b3b3b3b20000a200000000a29594000000900000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009090b3b2b2b3b3b3b3b3b3b3b3b292b3b3b290939292b3b392b3b3b2b3b3b393b3b3b39093b3b3b392b3b392b3abb393b3b3a89390b2b3b3b3b2b3b3b2b3b3b3b3b3b3b3b200a2000000000000a200000000900000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009090b2b2b2b2b2b3b3b3b3b3b3b295b3b3b290949594b3b393b3b3b2b3b3b394b3b3929093b3b3b394b3b394b3b3b394b3b3929390b2b3b3b3b2b3b3b2b2b3b3b3b3b3b3b200a2000000000000a200000092900000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009090a0a1b3b3abababb3b3b2b2b2b3b3929290b3b3b3b3b393b3b3b2b3b3b3b3b3b3949094b3b3b3abb3b3b3b3b3b3b3b3b3949390b2b3b3b3b2b3b3b3b2b3b3b3b3b3b3b2a2a20000a2a20000a200000095000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009000a6b8b3b3b3b3b3b3b3b2a5b3b3b3939390b9b3b3b3b393b3b3b2b3b3b3b3b3a5b390b9b3b3b3b2b2b2b2b2b2b2b2b2b2b29390b2b9b3b3b2b2b3b3b2b2b2b2b2bbbbb2a2a2000000000000a200000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000090009292929292929292929292929292939390929292929293b2b2b2b2b2b2929292929092929292929292929292929292929292909292929292b2b3b3b3b3b3b3b3b3b3b2a2a2000000000000a292000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000090909494949595949594949495949595959490949495949594b3b3b3b3b3b3949495940094959595949594949495949594959595909595959595b2b2b2b2b2b2b2b2b2b2b2a2a2000000000000a295000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009090909090909090909090909090909090a2a2a2a20000a2a2a2a2000000900000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000000000a2000000000000000000000000900000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900000000092929292929292929292929292900000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000909090909090909090909090909090909090900000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000221502415026150271502815029150291502915027150241501c1501d1501d1501d1501e1501f1502115023150281502d150301503115032150321503315000000000000000000000000000000000000
001000000d2500b250092500825007250052500325002250012500125000250002500025000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000000002d0502c0502b0502b0502b0502b0502d050350503f05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000302500000000000000001425000000000001c250000000d25000000012500125001250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000038250000000000000000000000000022250000000000000000000000000000000000003425000000000000000000000000001f25000000000000000000000000000c2500000000000000000000000000
001000000f25000000000000f25000000000000f25000000000000d250000000d250000000d25000000000000f250000001d25000000000001c250000000f2500000000000000000000000000102500000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002425000000000000000000000000000000000000242500000000000000000000000000000000000026250000000000000000000000000000000000001f25000000000000000000000000000000000000
__music__
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
01 0a424344
02 0a4c4344

