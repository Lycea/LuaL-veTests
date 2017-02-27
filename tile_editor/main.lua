
require "gooi"
--require "maps"

local tilesets = {} -- 1 for first loaded and so on ... in it is a tiles table with all tiles
local tilesets_img = {}
local btn = {}

local map = {}
map[1] = {}
map[2] = {}
map[3] = {}
local dummy_tile = nil
local dummy_img  = nil

local tile_page_count = 1;
local btn_count = 1

local btn_selected = 0
local show_help = true
local btn_plus
local btn_minus
local show_grid = true

local scale_btns  = 1;
local scale_tiles = 1;


local gr = love.graphics
local kb = love.keyboard
local mo = love.mouse

------------------------------
--  Own functions
------------------------------
function save_map()

file_name = txt_save_name.text

--file = io.open("map.lua","w")
file = io.open(file_name..".lua","w")

file:write(file_name.." = {}\n")
file:write(file_name..".__index = "..file_name.."\n")

for __ = 1 , 3 do
  file:write(file_name..".mapl"..__.." = {")
  for _ = 1, txt_map_h.text do
    file:write("{")
    for _j = 1,txt_map_w.text do
      if _j ~= txt_map_w.text-0 then
        file:write(map[__][_][_j]or"0" )
        file:write(",")
      else
        file:write(map[__][_][_j]or"0" )
        --print("test1")
      end
    end
    --line is finished
    if _ ~= txt_map_h.text-0 then
      file:write("},")
      file:write("\n")
    else
      file:write("}")
      file:write("\n")
      --print("test2")
    end
  end
  --table is finished
  file:write("}")
  file:write("\n\n")
  
  
  gooi.alert("Map was saved !!")
end




io.close(file)

--dofile("map.lua")

end


function draw_map()
  
  local x_ = 230
  local y_ = 190
  --print (#map)
  --print(#map[1])
  --print(#map[2])
  --print(#map[3])
   for _ = 1 , txt_map_h.text do  -- earch line
      for _2 = 1, txt_map_w.text do  -- each col
        --print (_2 .. _)
        local value = map[1][_][_2]
        --layer1
        if map[1][_][_2] then

          --print some debug stuff to the console ... maybe not needed anymore
            --print(math.floor(((value*1000)%1000)+0.1))
            --print(value-math.floor(value))
            --print("tileset "..math.floor(value).."// tile "..math.floor((value - math.floor(value))*1000))
          --print((value - math.floor(value))
          --print(math.floor((value - math.floor(value))*1000))
          love.graphics.draw(tilesets_img[math.floor(value)], tilesets[math.floor(value)][math.floor(((value*1000)%1000)+0.1)-1],x_ ,y_,0,1,1) --last two will be calculated with the width of a tile 
        else
          love.graphics.draw(dummy_img, dummy_tile,x_ ,y_,0,1,1)
        end
        
        
        
        
        value = map[2][_][_2]
        --layer 2
        if map[2][_][_2] then
          love.graphics.draw(tilesets_img[math.floor(value)], tilesets[math.floor(value)][math.floor(((value*1000)%1000)+0.1)-1],x_ ,y_,0,1,1) 
        else
          love.graphics.draw(dummy_img, dummy_tile,x_ ,y_,0,1,1)
        end
        
        value = map[3][_][_2]
        --layer 3
        if map[3][_][_2] then
          love.graphics.draw(tilesets_img[math.floor(value)], tilesets[math.floor(value)][math.floor(((value*1000)%1000)+0.1)-1],x_ ,y_,0,1,1) 
        else
          love.graphics.draw(dummy_img, dummy_tile,x_ ,y_,0,1,1)
        end
          x_ = x_ + line_div_h -- sets new starting x  so new tile
      end
      y_ = y_ + line_div_v -- sets new starting y so new line
      x_ = 230 -- reset x value
   end
   
end
function enable_edit_dlg ()
    disable_edit_dlg(false)
end


function disable_edit_dlg (bool)
  
  if(bool == true) then
    
    --disables tile selection buttons
    for i = 1 , #btn do
      btn[i]:setEnabled(false)
    end
    
    --disables +/- for tiles
    btn_plus:setEnabled(false)
    btn_minus:setEnabled(false)
    btn_save:setEnabled(false)
  else
    --enables the things that were disabled before
    for i = 1 , #btn do
      btn[i]:setEnabled(true)
    end
    btn_plus:setEnabled(true)
    btn_minus:setEnabled(true)
    btn_save:setEnabled(true)
  end

end

--disable all not to use buttons and controls
function disable_start(bool)
   disable_edit_dlg(true)
   --print("test".. 0.1234)
end

-- draws the tiles on the buttons
function draw_button_preview(_set,_page)
  local b_second_line = false
  _set = _set +1
  button_x  = 275
  --print(_set.." ".._page.." meep\n")
     for i = (_page*20 -20 +1), (_page*20) do
       if i < (_page*20 -9) and i <= #tilesets[_set]  then
          love.graphics.draw(tilesets_img[_set], tilesets[_set][i], button_x, 55,0,scale_btns,scale_btns)
                            --tileset        which quad                   width                      hight
          button_x= button_x + 50
       elseif i > (_page*20 -10) and i <= #tilesets[_set] then
         if b_second_line == false then
           button_x = 275
           b_second_line = true
         end
         love.graphics.draw(tilesets_img[_set], tilesets[_set][i], button_x, 105,0,scale_btns,scale_btns)
         button_x= button_x + 50
       else
         
       end
     end 
end



------------------------------
--  Löve functions
------------------------------

--preload importent values /files into the programm
function love.load()
  -- canvas stuff
  width  = gr.getWidth()
  height = gr.getHeight()
  scale  = 1
  wCanvas, hCanvas = width / scale, height / scale

  canvas = gr.newCanvas(wCanvas, hCanvas)
  canvas:setFilter("linear", "linear")
	gooi.setCanvas(canvas)
  
--start of everything else
if arg[#arg] == "-debug" then require("mobdebug").start() end

    dummy_img = gr.newImage("images/dummy.png")
    dummy_tile = gr.newQuad(0,   0, 32, 32, 32, 32)

  style = {
		--font = gr.newFont(fontDir.."ProggySquare.ttf", 16),
		fgColor = "#FFFFFF",
		bgColor =  { 255,0,0, 170},  --#25AAE1F0
    mode3d = true,
    glass = true,
    round = .5,
    showBorder = true,
    font = love.graphics.newFont(love.window.toPixels(13)),  --8 for small
    borderColor = '#ffffff'
	}
	gooi.setStyle(style)
	gooi.desktopMode()
  
  
  ----------------------------------------
  --             Tile selection screen part
  ----------------------------------------
  local x_def = 270
  local _button =
  {
    w = 45, h = 45, x = x_def, y = 50 , start = 0
  }
  
  
  bg_tiles = gooi.newLabel("", _button.x -50, 0 ,gr.getWidth()--[[_button.w*13]] , 4* _button.h):setOpaque(true):roundness(0, 0)--setOrientation("center")
  
  
  local lbl_tiles = gooi.newLabel(" Tiles", _button.x -30, 10 ,gr.getWidth()-(_button.x-30)-5):setOpaque(true):roundness(.5, 0):roundness(0, 0):bg("218AB8"):setOrientation("center")
  
  --the "slider"
   lbl2 = gooi.newLabel("1", _button.x-30, _button.y, 25, 2*_button.h + 5):setOpaque(true):roundness(.2, 0):setOrientation("center")
  
  btn_plus = gooi.newButton(" ", _button.x - 25 , _button.h +10 , 15,15 ):bg({255,255,255,170}):onPress(function()
      --print(spi_sets.value)
      if tile_page_count < #tilesets[spi_sets.value+1] /20 then
        tile_page_count = tile_page_count +1
      end
	end)

  btn_minus = gooi.newButton(" ", _button.x - 25 , _button.w*3 -15  , 15,15 ):bg({255,255,255,170}):onPress(function()  
    if tile_page_count > 1 then
       tile_page_count = tile_page_count -1
    end
	end)

  -- do selection buttons
  for i=0,  1 do
    _button.x = x_def
    for j = 0 , 9 do
      btn[btn_count] = gooi.newButton("    ", _button.x, _button.y, _button.w, _button.h):bg({255,0,0}):onRelease(function(f)
          if btn_selected == 0 then
            
            print("Selected button "..f.id)
            btn[f.id -(_button.start-1)]:bg("#00ff00")
            btn_selected = f.id -(_button.start-1)
            print(btn_selected)
          else
            print("Selected button "..f.id)
            btn[f.id -(_button.start-1)]:bg("#00ff00")
            btn[btn_selected]:bg("#ff0000")
            btn_selected = f.id -(_button.start-1)
            print(btn_selected)
          end
          
        end
      )
      btn_count = btn_count+1
      _button.x = _button.x + _button.w + 5
    end
    _button.y = _button.y + _button.w + 5
  end
  
    _button.start = btn[1].id
    --print(_button.start)

initSave(x_def,_button)
---------------------
---         toolbox
---------------------
lb_bg_tool = gooi.newLabel("",0, 4*_button.h , x_def-50, gr.getHeight()-(4*_button.h)):setOpaque(true):roundness(0, 0)

lb_tbx  = gooi.newLabel("Toolbox",5, 185,210,35):setOrientation("center"):setOpaque(true):bg("218AB8"):fg("FFFFFF")
          :roundness(0,0)

lb_size_t  = gooi.newLabel("tile size:",30, 230)
txt_tile_w = gooi.newText({ text = "32" ,x = 80 , y = 230, w = 50})
txt_tile_h = gooi.newText({ text = "32" ,x = 150 ,y = 230, w = 50})
gooi.newLabel("/",140, 230)


  lb_w  = gooi.newLabel("w:",30, 280)
  txt_map_w = gooi.newText({ text = "20",x = 50 ,y = 280, w = 50})
  
  lb_h  = gooi.newLabel(" / h:",105, 280)
  txt_map_h = gooi.newText({text = "20",x = 130, y = 280, w = 50})

  lb_set = gooi.newLabel("Tileset",30, 310)
  spi_sets = gooi.newSpinner({min = 0, max = 0 , value = 0, x = 30, y = 335 , w = 180})

	rad_add    = gooi.newRadio({ x = 30, y = 370 , text = "   add tile", radioGroup = "g1", selected = true,w = 150}):roundness(0.8,1)
	rad_remove = gooi.newRadio({ x = 30, y = 400 , text = "remove tile", radioGroup = "g1",w = 150})
  
  lb_layer = gooi.newLabel("Layer",30, 430)
  spi_layer = gooi.newSpinner({min = 1, max = 3 , value = 1, x = 30, y = 480 , w = 180})
  
  --lb_ = gooi.newLabel("Layer",30, 520)
  ch_layer = gooi.newCheck("grid mode",30, 520,130):onRelease(function(c)
		if c.checked then
      show_grid = true
		else
      show_grid = false
    end
  end):change()

---------------------
---         editor
---------------------

-- preload a map to fill in or change
 for _ = 1 , 3 do
    local _l = 1
    
    for _2 = 1 , txt_map_h.text do
      map[_][_2] = {}
    end
 end
 
 
 
 
end
 
 
function initSave(x_def,_button)
    ---------------------
    ---         Load / Save Buttons 
    ---------------------
  lb_bg_save =  gooi.newLabel("",0, 0 , x_def-50, 4*_button.h):setOpaque(true):roundness(0, 0)
  btn_save   = gooi.newButton("Save", 10,10):onRelease(function(f)     save_map() end )

  lb_save_name  = gooi.newLabel("Name:", 70, 10)
  txt_save_name = gooi.newText({ text = "map" ,x = 120 , y = 10, w = 95})
    
   
  lb_layer = gooi.newLabel("Scale",0, 90)
  scale_1  = gooi.newRadio({ x = 40, y = 90 , text = "1x", radioGroup = "g2", selected = true,w = 55}):roundness(0.8,1):onRelease(function()
		scale, gooi.sx, gooi.sy = 1, 1, 1
		love.window.setMode(wCanvas * scale, hCanvas * scale)
	end)
  
	scale_2  = gooi.newRadio({ x = 95, y = 90 , text = "2x", radioGroup = "g2",w = 55}):roundness(0.8,1):onRelease(function()
		scale, gooi.sx, gooi.sy = 0.75, 0.75, 0.75
		love.window.setMode(wCanvas * scale, hCanvas * scale)
	end)
  scale_3  = gooi.newRadio({ x = 150, y = 90 , text = "3x", radioGroup = "g2",w = 55}):roundness(0.8,1):onRelease(function()
		scale, gooi.sx, gooi.sy = 0.5, 0.5, 0.5
		love.window.setMode(wCanvas * scale, hCanvas * scale)
	end)
  
  
  end
  
  
  
function love.draw()
  --print"Hello, world!"
  
  gr.setCanvas(canvas)
    gr.clear()
    
    gr.setLineWidth(1)
    --draw  grid for editing
    gr.rectangle("line", 230 , 190, 600,600)
    
    
    if #tilesets_img > 0 then
    -- set the icon set
      --draw_button_preview(spi_sets.value,lbl2.text)
     draw_map()
    end
    --draw lines to divide the rectangle
    if txt_map_w.text == "" or txt_map_h.text == "" or show_grid == false then
      
    else
       line_div_v = 600 / txt_map_w.text
       line_div_h = 600 / txt_map_h.text
      
      for i = 1 , txt_map_w.text -1 do
        gr.line(230+line_div_v*i,190,230+line_div_v*i,790)
        
      end
      
      for i = 1 , txt_map_h.text -1 do
        gr.line(230,190+line_div_h*i,830,190+line_div_h*i)
      end
    end
    
    if show_help then
      disable_start()
      
      gooi.alert(  "Welcome! \n"..
                   "First stepps:\n"..
                   "1.Enter the tilesize\n"..
                   "2.Select a layout for the map(w: /h:\n)"..
                   "3.Drop a tileatlas(*png)\n"..
                   "4.Have fun :)")
      show_help = false
      
    end
    
    
    
    gooi.draw()
  
  
  
  
  
    if #tilesets_img > 0 then
    -- set the icon set
      draw_button_preview(spi_sets.value,lbl2.text)
      --draw_map()
    end
    

    gr.print(love.timer.getFPS().." FPS")
  
  gr.setCanvas()
  gr.draw(canvas,0,0,0,scale,scale)

end


function love.update(dt)
 
    old_w = 39 
    old_h = 20
  
  if txt_map_h.text ~= old_h and txt_map_h.text ~= ""then
    -- shorten or longer map()
    if tonumber(txt_map_h.text) > old_h then
      for _ = old_h , tonumber(txt_map_h.text) do
        map[1][_+1] = {}
        map[2][_+1] = {}
        map[3][_+1] = {}
      end
    else
      for _ = old_h , tonumber(txt_map_h.text) do
        map[1][_+1] = nil
        map[2][_+1] = nil
        map[3][_+1] = nil
      end
    end
    old_h = txt_map_h.text
  end
  
  
  lbl2:setText(tile_page_count)
  gooi.update(dt)
  
end


--for getting a tileset to load
function love.filedropped(file)
  local name = file:getFilename()
  print("-----------------------");
  print(name)
  
  -- check if it is a png
  if name.find(name, ".png",1) then
    count = #tilesets_img
    print(#tilesets_img)
    
    tilesets_img[count+1]= love.graphics.newImage(file)
    print(#tilesets_img)
    
  
--  tiles.width = 32 
--  tiles.hight = 32
--  grass_set_h = tilesets.grass:getHeight()
--  grass_set_w = tilesets.grass:getWidth()
  
--  grass_quads = {
--      love.graphics.newQuad(0,   0, tiles.width, tiles.hight, grass_set_w, grass_set_h), -- 1 = dirt
--      love.graphics.newQuad(32,  0, tiles.width, tiles.hight, grass_set_w, grass_set_h), -- 2 = box
--      love.graphics.newQuad(0,  32, tiles.width, tiles.hight, grass_set_w, grass_set_h), -- 3 = flowers
--      love.graphics.newQuad(32, 32, tiles.width, tiles.hight, grass_set_w, grass_set_h)  -- 4 = boxtop
--    }

  -- set the tile width/hight for the set
  print ("width  "..txt_tile_w.text)
  print ("height "..txt_tile_h.text)
  
  scale_btns = 32 /  txt_tile_w.text 
  scale_tiles = 32/  txt_tile_w.text
  
  -- get hight / width of the tile atlas // image
  img_h = tilesets_img[#tilesets_img]:getHeight()
  img_w = tilesets_img[#tilesets_img]:getWidth()

-- calc rows /lines
   rows = img_h / txt_tile_h.text
   cols = img_w / txt_tile_w.text
   
   count = 1
   tilesets[#tilesets_img] = {}
   
   local x_ = 0
   local y_ = 0
  for i = 1, rows do
     for j = 1 , cols do
      tilesets[#tilesets_img][count] = love.graphics.newQuad(x_,  y_, txt_tile_w.text, txt_tile_h.text, img_w, img_h)
      count = count + 1
      x_ = x_+32
    end
    x_ = 0
    y_ = y_ + 32
  end
  print ("tiles: "..#tilesets[#tilesets_img])
  tilesets[#tilesets_img]['x'] = dummy_tile
  
  spi_sets.max = #tilesets -1
    enable_edit_dlg()
  else
    gooi.alert("No valid input img only *.png are valid !")
    return 
  end
  
  print("-----------------------");
end


function love.mousereleased(x, y, button)
  --print("beep\n")  
  b_mpr = false
  gooi.released() 
end


function love.mousepressed(x, y, button)
  if x > 230 and y > 190 then
   --print (x.." "..y)
   --print("beep\n")
   if #tilesets_img > 0 and btn_selected ~= 0 then
     b_mpr = true
     
     -- calc the rectangle where it is
     local col = math.floor((x- 230) / line_div_h)  +1
     local row = math.floor((y - 190) / line_div_v) +1
     --map[spi_layer.value][row][col] =  (btn_selected*lbl2.text)/1000 + spi_sets.value +1
     map[spi_layer.value][row][col] =  (btn_selected+ ((lbl2.text*20)-19)) /1000 + spi_sets.value +1
     --print(btn_selected)
     print((btn_selected*lbl2.text)/1000 + spi_sets.value +1 )
     print("Btn sel: "..btn_selected .." /lbl_text "..lbl2.text )
   end
  end
  gooi.pressed() 
end

function love.mousemoved( x, y, dx, dy, istouch )
  if b_mpr and x > 230 and y > 190 then
   --print (x.." "..y)
   --print("moved\n")
   local col = math.floor((x- 230) / line_div_h)  +1
   local row = math.floor((y - 190) / line_div_v) +1
   --map[spi_layer.value][row][col] =  (btn_selected*lbl2.text)/1000 + spi_sets.value +1 
   map[spi_layer.value][row][col] =  (btn_selected+ ((lbl2.text*20)-19)) /1000 + spi_sets.value +1
   --print( map[spi_layer.value][row][col])
   end
end

function love.textinput(text)
	gooi.textinput(text)
end


function love.keypressed(key)
	gooi.keypressed(key)
	if key == "escape" then
		quit()
  else
    if key == "left" then
      --print("hi l")
    end
    if key == "right" then
      --print("hi r")
    end
	end
end

function quit()
	love.event.quit()
end
  
  
  