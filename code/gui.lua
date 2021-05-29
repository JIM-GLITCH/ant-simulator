
-- User Interface stuff using SUIT lib > 
local suit = require('libs.suit')
local cfg = require('code.simconfig')
local sim = require('code.simulation')
local apiG = love.graphics
local map = require('code.map')

local ui = {}
local cmul = cfg.colorMul
suit.theme.color = {
	normal   = {bg = { 66*cmul, 66*cmul, 66*cmul}, fg = {188*cmul,188*cmul,188*cmul}},
	hovered  = {bg = { 50*cmul,153*cmul,187*cmul}, fg = {255*cmul,255*cmul,255*cmul}},
	active   = {bg = {255*cmul,153*cmul,  0}, fg = {225*cmul,225*cmul,225*cmul}}
}


ui.cnormal = suit.theme.color.normal
ui.selectedColor =  { bg={55*cmul, 113*cmul, 140*cmul}, fg={255*cmul,255*cmul,255*cmul} } 
ui.cc = ui.cnormal
ui.consumedClick = false

ui.labelStyle =  { normal = { fg={155*cmul,200*cmul,125*cmul} }   }

ui.leftPanelWidth = 110
ui.leftPanelColor = { 82*cmul, 82*cmul, 82*cmul}

ui.numAnts = 0 -- set this on main.lua to update


local btnDims = {w = 85, h = 40}

function ui.onRadioCellsChanged( NewIdx )
  print ( ui.radioBtns_cells.selectedCaption )
end

ui.radioBtns_cells = {
  {caption = 'pan view'},
  {caption = 'block'},
  {caption = 'grass'},
  {caption = 'cave'},
  {caption = 'food'},
  {caption = 'portal'},
  {caption = 'remove'},  
  bWidth = btnDims.w,
  bHeight = btnDims.h,
  selectedIdx = 1,
  selectedCaption = 'pan view',
  onChanged = ui.onRadioCellsChanged
}

ui.showPheromones = { checked = false, text = 'phrms'}
  

function ui.suitRadio( rbtns )
  local grow
  --ui.consumedClick = false
    
  for i=1,#rbtns do 
    if rbtns.selectedIdx  then
      if rbtns.selectedIdx == i then
        ui.cc = ui.selectedColor
        grow = 25
      else
        ui.cc = ui.cnormal
        grow = 0
      end
    end
    rbtns[i].ret = suit.Button(rbtns[i].caption, { color = { normal = ui.cc }} , suit.layout:row( rbtns.bWidth + grow, rbtns.bHeight) )  
    if rbtns[i].ret.hit then  
      --ui.consumedClick = true
      rbtns.selectedIdx = i
      if rbtns.onChanged then
        rbtns.selectedCaption = rbtns[i].caption
        rbtns.onChanged(i)
      end
    end
  end 
end

function ui.onZoomInOut( inc ) end --event called onZoomInOut; overrided on main.lua


function ui.mainUpdate()
  suit.layout:reset(10,10) 
  suit.layout:padding(10,5)   
  -- apiG.print("Hello World!", 400, 300)
  -- suit.Label(, { color =  ui.labelStyle }, suit.layout:row(btnDims.w, 20 )   )
  -- suit.Label(ui.numAnts..' ants', { color =  ui.labelStyle }, suit.layout:row(btnDims.w, 20 )  ) 
  -- suit.Label(cfg.simFrameNumber..' fs', { color =  ui.labelStyle }, suit.layout:row(btnDims.w, 20 )  ) 
  -- suit.Label('find '..cfg.FindAllFoodTime, { color =  ui.labelStyle }, suit.layout:row(btnDims.w, 20 )  )a
  -- suit.Label('foodnumber '..cfg.foodNumbers..' fs', { color =  ui.labelStyle }, suit.layout:row(btnDims.w, 20 )  )

  if suit.Button('zoom+',suit.layout:row(btnDims.w, btnDims.h)).hit then ui.onZoomInOut(0.5) end 
  if suit.Button('zoom-',suit.layout:row()).hit then ui.onZoomInOut(-0.5) end 
  if suit.Button('start',suit.layout:row(btnDims.w, btnDims.h)).hit then sim.start() end 
  if suit.Button('stop',suit.layout:row(btnDims.w, btnDims.h)).hit then  sim.stop() end 
  if suit.Button('pause',suit.layout:row(btnDims.w, btnDims.h)).hit then cfg.pause= not cfg.pause end 
  if suit.Button('change map',suit.layout:row(btnDims.w, btnDims.h)).hit then sim.changeMap() end 
  
  ui.suitRadio(ui.radioBtns_cells)     
  
  if suit.Checkbox( ui.showPheromones, suit.layout:row() ).hit then cfg.debugPheromones = ui.showPheromones.checked end
  
end

function ui.draw()
  apiG.setBackgroundColor({0.5,0.5,0.5})
  apiG.setColor( ui.leftPanelColor )
  apiG.rectangle("fill", 0,0, ui.leftPanelWidth, apiG.getHeight() )
 -- apiG.setColor(120,180,100)
 -- apiG.print(tostring(love.timer.getFPS( ))..' FPS', 10, 10)  
 -- apiG.print('F# '..cfg.simFrameNumber, 10, 25)     
  --apiG.print("DebugCounter 1 = "..cfg.debugCounters[1], 10, 25)
  --apiG.print("DebugCounter 2 = "..cfg.debugCounters[2], 10, 40)
  suit.draw()
  -- apiG.setColor(236/256,240/256,241/256)
  -- apiG.print(love.timer.getFPS()..' FPS'                                  ,120, 0)
  -- apiG.print(ui.numAnts..' ants'                                          ,120, 20)
  -- apiG.print('the time of finding all food: '..cfg.FindAllFoodTime..' fs' ,120, 40)
  -- apiG.print('the number of unfound food: '..cfg.foodNumbers              ,120, 60)
  apiG.setColor( {0.,0.,0.} )

  apiG.print(
              love.timer.getFPS()                       ..' FPS'                            ..'\n'..                              
              ui.numAnts                                ..' ants'                           ..'\n'..   
              'sim time: '                              ..cfg.simFrameNumber..' fs'         ..'\n'..                                   
              'the number of all food: '                ..cfg.foodNumbers                   ..'\n'..
              'the number of found food: '              ..cfg.foodFoundNumbers              ..'\n'..
              'the number of all food storage: '        ..cfg.foodAmount                   ..'\n'..
              'the number of arrived food storage: '    ..cfg.foodArrivedStorage            ..'\n'..
              'the time of finding all food: '          ..cfg.FindAllFoodTime..' fs'        ..'\n'.. 
              'the time of task finished: '             ..cfg.taskFinishedTime..' fs'       ..'\n'..
              'the Arithmetic: '                        ..cfg.arithmetic()                  ..'\n'..
              'the map: '                               ..cfg.mapExampleNumber              ..'\n'..
              'the grid found: '                        ..cfg.mapGridFound                  ..'\n'..
              'the mapAreaGrid: '                        ..cfg.mapAreaXYg
              ,120, 10)
end

function ui.setContentScale( x, y)
  suit.setContentScale( x, y )
end

return ui