 --[[
    MIT LICENSE
    Copyright (c) 2021 Chen Junyao
    Copyright (c) 2018 Denys Almaral
    

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]

--- Our main game stuff, 
-- try to keep it simple... oh well..
  
  
--aliases and modules
--api
local apiG = love.graphics
local api = love

if api.system.getOS()=='Android' or api.system.getOS()=='iOS' then CURRENT_PLATFORM = 'mobile' else CURRENT_PLATFORM = 'desktop' end

--application
local cfg = require('code.simconfig') 
cfg.mapExampleNumber=tonumber(arg[2]) or cfg.mapExampleNumber
cfg.antComAlgorithm =tonumber(arg[3]) or cfg.antComAlgorithm
cfg.numAnts         =tonumber(arg[4]) or cfg.numAnts
cfg.mapMaxX         =tonumber(arg[5]) or cfg.mapMaxX
cfg.mapMaxY         =tonumber(arg[6]) or cfg.mapMaxY
TEST                =arg[7] or ''
trial               =arg[8] or 0
cfg.antPositionMemorySize= tonumber(arg[9]) or cfg.antPositionMemorySize
local sim = require('code.simulation')
local map = require('code.map')
local cam = require('code.camview')

local ui = require('code.gui')
-- doing a global scaling for basic adaptation to different screens/windows sizes
local contentScaling 
local function screenSizeUpdated()
  contentScaling = apiG.getHeight() / cfg.idealContentHeight  
  ui.setContentScale( contentScaling, contentScaling )
  cam.contentScale = contentScaling
end
screenSizeUpdated()

function math.randomchoice(t) --Selects a random item from a table
  local keys = {}
  for key, value in pairs(t) do
      keys[#keys+1] = key --Store keys in another table
  end
  local index = keys[math.random(1, #keys)]
  return t[index]
end

function api.load(arg)
  if TEST =="memorysize" then
    F=io.open('./'..TEST..'map'..cfg.mapMaxX..'x'..cfg.mapMaxY..'ants100memorysize'..cfg.antPositionMemorySize..'trial'..trial..'.txt','w') 
  elseif TEST =="algorithm_comparison"then 
    F=io.open('./'..TEST..cfg.arithmetic()  .. 'map'..cfg.mapMaxX..'x'..cfg.mapMaxY..'ants'..cfg.numAnts..'trial'..trial..'.txt','w') 
  else 
    F=io.open('./'..TEST..'map'..cfg.mapMaxX..'x'..cfg.mapMaxY..'ants'..cfg.numAnts..'trial'..trial..'.txt','w') 
  end
-- print('Initializing...')
  -- if arg[#arg] == "-debug" then require("mobdebug").start() end    
  sim.init()  
  
  
   
  cam.translation = {x = 500, y = 300 }
  cam.scale = { x = 2, y = 2 }
  cam.zoomOrigin = { x = apiG.getWidth() / 2, y = apiG.getHeight() / 2 }
  apiG.setBackgroundColor(cfg.colorBk)
  apiG.setDefaultFilter("nearest", "nearest")
  apiG.setLineStyle( 'rough' )
  sim.start()
  
end    

----------------------------------------------------------------
-- chose api.update  upon  arg TEST

if TEST =="searchmap" then
  function api.update()
    
    ui.numAnts = map.ants.count
    ui.mainUpdate()
    -- F:write(cfg.mapGridFound..'\n')
    
    F:write(cfg.mapGridFound..'\n')
    if not cfg.pause then sim.update()   end
    if cfg.start and  cfg.FindAllFoodTime==-1 and cfg.foodFoundNumbers>=cfg.foodNumbers then cfg.FindAllFoodTime=cfg.simFrameNumber end
    -- if cfg.start and  cfg.taskFinishedTime==-1 and cfg.foodArrivedStorage>=0.95*cfg.foodAmount then cfg.taskFinishedTime=cfg.simFrameNumber end 
    if cfg.start and  cfg.taskFinishedTime==-1 and cfg.simFrameNumber>15000 then F:close(); os.exit() end 
    -- if cfg.start and  cfg.taskFinishedTime==-1 and cfg.simFrameNumber>=500 then cfg.taskFinishedTime=cfg.simFrameNumber;F:close(); os.exit(cfg.taskFinishedTime)  end
    -- if cfg.start and  cfg.taskFinishedTime==-1 and cfg.mapGridFound>=cfg.mapAreaXYg then cfg.taskFinishedTime=cfg.simFrameNumber;F:close(); os.exit(cfg.taskFinishedTime)  end
  end

elseif TEST =="movefood" then
  function api.update()
    
    ui.numAnts = map.ants.count
    ui.mainUpdate()
    -- F:write(cfg.mapGridFound..'\n')
    
    F:write(cfg.foodArrivedStorage..'\n')
    if not cfg.pause then sim.update()   end
    if cfg.start and  cfg.FindAllFoodTime==-1 and cfg.foodFoundNumbers>=cfg.foodNumbers then cfg.FindAllFoodTime=cfg.simFrameNumber end
    -- if cfg.start and  cfg.taskFinishedTime==-1 and cfg.foodArrivedStorage>=0.95*cfg.foodAmount then cfg.taskFinishedTime=cfg.simFrameNumber end 
    if cfg.start and  cfg.taskFinishedTime==-1 and cfg.simFrameNumber>10000 then F:close(); os.exit() end 
    -- if cfg.start and  cfg.taskFinishedTime==-1 and cfg.simFrameNumber>=500 then cfg.taskFinishedTime=cfg.simFrameNumber;F:close(); os.exit(cfg.taskFinishedTime)  end
    -- if cfg.start and  cfg.taskFinishedTime==-1 and cfg.mapGridFound>=cfg.mapAreaXYg then cfg.taskFinishedTime=cfg.simFrameNumber;F:close(); os.exit(cfg.taskFinishedTime)  end
  end
elseif  TEST =='memorysize' then
  function api.update()
    
    ui.numAnts = map.ants.count
    ui.mainUpdate()
    -- F:write(cfg.mapGridFound..'\n')
    
    F:write(cfg.foodArrivedStorage..'\n')
    if not cfg.pause then sim.update()   end
    if cfg.start and  cfg.FindAllFoodTime==-1 and cfg.foodFoundNumbers>=cfg.foodNumbers then cfg.FindAllFoodTime=cfg.simFrameNumber end
    -- if cfg.start and  cfg.taskFinishedTime==-1 and cfg.foodArrivedStorage>=0.95*cfg.foodAmount then cfg.taskFinishedTime=cfg.simFrameNumber end 
    if cfg.start and cfg.simFrameNumber>20000 then F:close(); os.exit() end 
    -- if cfg.start and  cfg.taskFinishedTime==-1 and cfg.simFrameNumber>=500 then cfg.taskFinishedTime=cfg.simFrameNumber;F:close(); os.exit(cfg.taskFinishedTime)  end
    -- if cfg.start and  cfg.taskFinishedTime==-1 and cfg.mapGridFound>=cfg.mapAreaXYg then cfg.taskFinishedTime=cfg.simFrameNumber;F:close(); os.exit(cfg.taskFinishedTime)  end
  end
elseif TEST =="algorithm_comparison" then 
  function api.update()
    ui.numAnts = map.ants.count
    ui.mainUpdate()
    F:write(cfg.foodArrivedStorage..'\n')
    if not cfg.pause then sim.update()   end
    if cfg.start and  cfg.FindAllFoodTime==-1 and cfg.foodFoundNumbers>=cfg.foodNumbers then cfg.FindAllFoodTime=cfg.simFrameNumber end
    -- if cfg.start and  cfg.taskFinishedTime==-1 and cfg.foodArrivedStorage>=0.95*cfg.foodAmount then cfg.taskFinishedTime=cfg.simFrameNumber end 
    if cfg.start and cfg.simFrameNumber>20000 then F:close(); os.exit() end
    -- if cfg.simFrameNumber == 1 or 500 or 1000 or 1500 then cfg.pause = true end
  end

elseif TEST =='' then
  function api.update()
    ui.numAnts = map.ants.count
    ui.mainUpdate()
    -- F:write(cfg.mapGridFound..'\n')
    
    -- F:write(cfg.foodArrivedStorage..'\n')
    if not cfg.pause then sim.update()   end
    if cfg.start and  cfg.FindAllFoodTime==-1 and cfg.foodFoundNumbers>=cfg.foodNumbers then cfg.FindAllFoodTime=cfg.simFrameNumber end
    -- if cfg.simFrameNumber == 1 or 500 or 1000 or 1500 then cfg.pause = true end
  end
end

-------------------------------------------------------------------------------------------



function api.draw()        
  --gameworld  
  -- if cfg.simFrameNumber == 1 then print( (os.clock() - TIME_start)..'secs' ) end
      
  apiG.push()      
  apiG.translate( cam.translation.x, cam.translation.y )          
  apiG.scale( cam.scale.x * contentScaling, cam.scale.y * contentScaling )            
  map.draw()
  if cfg.start then sim.draw() end 
  --ui stuff
  apiG.pop()
  
  --ui
  apiG.scale(contentScaling, contentScaling)
  ui.draw()  
end

function api.keypressed(key)
  if key=='1' then
      
  elseif key=='2' then    
      cfg.antComEveryFrame  = not cfg.antComEveryFrame 
      print('cfg.antComEveryFrame = ',cfg.antComEveryFrame)
  elseif key=='3' then
      cfg.debugGrid = not cfg.debugGrid
      print('cfg.debugGrid =',cfg.debugGrid)
  elseif key=='4' then
      cfg.antComAlgorithm = cfg.antComAlgorithm + 1
      if cfg.antComAlgorithm > 3 then cfg.antComAlgorithm = 0 end     
      print('cfg.antComAlgorithm = ', cfg.antComAlgorithm )
  elseif key=='5' then
      cfg.debugPheromones = not cfg.debugPheromones
      print('cfg.debugPheromones =',cfg.debugPheromones)
  elseif key=='m' then
       print('Memory: '..math.floor( collectgarbage ('count'))..'kb')
  elseif key=='escape' then
      api.event.quit()
  elseif key=='6' then
      cfg.antObjectAvoidance = not cfg.antObjectAvoidance 
      print('cfg.antObjectAvoidance = ', cfg.antObjectAvoidance )
  elseif key=='0'then
      cfg.debugHideAnts = not cfg.debugHideAnts
      print('cfg.debugHideAnts = ', cfg.debugHideAnts )
  elseif key=='f11' then
      api.window.setFullscreen( not api.window.getFullscreen() )
      screenSizeUpdated()
  end
  
end

local function dragmoved(x, y, dx, dy)    
  local tool =  ui.radioBtns_cells.selectedCaption


  if api.mouse.isDown(1) and (x > ui.leftPanelWidth) then     
    if (tool ~= 'cave') and (tool ~= 'portal') and (tool~='pan view') then
      sim.setCell(ui.radioBtns_cells.selectedCaption, cam.screenToWorld(x, y) ) 
    end    
  end 


  if (x > ui.leftPanelWidth)   then
    if api.mouse.isDown(3) or api.mouse.isDown(2) or ( api.mouse.isDown(1) and tool =='pan view' ) then      
      cam.translation.x = cam.translation.x + dx
      cam.translation.y = cam.translation.y + dy
    end
  end  
end

--needed to do this because mousemoved makes big dx,dy jumps on mobile
if CURRENT_PLATFORM == 'desktop' then
  function api.mousemoved(x,y,dx,dy, istouch)
    dragmoved(x,y,dx,dy)
  end
else
  function api.touchmoved(id, x,y,dx,dy, pressure)
    dragmoved(x,y,dx,dy)
  end
end


function api.mousepressed(x, y, button,  istouch)  
  if button == 1 and (x > ui.leftPanelWidth) then 
    sim.setCell(ui.radioBtns_cells.selectedCaption, cam.screenToWorld(x, y) )
  end  
end

function api.wheelmoved( x, y)    
  local inc = y * 0.5
  
  cam.zoomOrigin.x, cam.zoomOrigin.y = api.mouse.getX(), api.mouse.getY()
  cam.zoom(inc)
end

function ui.onZoomInOut( inc ) 
  cam.zoomOrigin = { x = apiG.getWidth() / 2, y = apiG.getHeight() / 2 }
  cam.zoom(inc)
end


  
