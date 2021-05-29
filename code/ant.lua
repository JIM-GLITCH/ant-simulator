local cell = require "code.cell"
--- TAnt class, 

local apiG = love.graphics
local TActor = require('code.actor')
local vec = require('libs.vec2d_arr')
local cfg = require('code.simconfig')
local map = {}                          --circular reference to Map module. Set with TAnt.setMap on map.lua


-- Sorry of the Delphi-like class styles :P
local TAnt = {}
local imgAntWalk = {} 

     
-- PUBLIC class fields
function TAnt.setMap ( ourMap )
  map = ourMap
end

-- a global init before any ant is created.
function TAnt.init()
  imgAntWalk[0] = apiG.newImage('images//antWalk_01.png')
  imgAntWalk[1] = apiG.newImage('images//antWalk_02.png')
  imgAntWalk[2] = apiG.newImage('images//antWalk_02.png')
  imgAntWalk[3] = apiG.newImage('images//antWalk_03.png')
end


-- Sim has to set this refernce to the grid 
-- TAnt.grid = nil
-- PRIVATE class fields
local fSomething
  
-- PRIVATE class methods
local function doSomthing ()
  
end
  

--- Creating a new instance for TAnt class
function TAnt.create()
  local ant = TActor.create()
  
  --private instance fields
  local fSomevar = 0    
  local fPastPositions = {}    --all positions they can remember, this is a fixed size queue as array of vectors
  local fPastPositionSpeeds={} --all position's speed they can remember, this is a fixed size queue as array of numbers
  local fOldestPositionIndex = 0
  local fComEvery = math.random(unpack(cfg.antComNeedFrameStep))
  local fComEveryOffset =math.random(cfg.antComNeedFrameStep[2]) 
    
  --properties
  ant.direction = { 1.0, 0.0 } --direction heading movement unitary vector
  ant.oldPosition = {0, 0}
  ant.radius = 2
  ant.speed = 0.1
  ant.traveled = 0 -- traveled distance
  ant.friction = 1
  ant.acceleration = 0.04  + math.random()*0.05
  ant.erratic = cfg.antErratic                  --crazyness
  ant.maxSpeed = cfg.antMaxSpeed   
  ant.lookingForTask = 1  
  ant.comingFromTask = 0 
  ant.comingFrom = ''  
  ant.lastTimeSeen = {food = -1, cave = -1}   --we can access t['food'] = n
  ant.maxTimeSeen = -1  
  ant.lastTimeUpdatedPath = -1
  ant.lookingFor = 'food'
  ant.nextTask   = 'cave'
  ant.cargo = { material = '', count = 0, capacity = 1 } 
  ant.oldestPositionRemembered = {0,0}  --vector 2D arr 
  ant.oldestPositionRememberedSpeed=0.1 
  ant.betterPathCount = 0
  ant.color = cfg.colorAnts
  ant.lastCollisionTime = -1
  ant.pheromonesBackTime = -1
  ant.pheromonesWrite = false
  
  
  
  ant.antPause = {
      iterMin = 10,                   --Stop for pause every iterMin to iterMax iterations.
      iterMax = 20,
      timeMin = 5,                    --Stop time from timeMin to timeMax iterations.
      timeMax = 15,
      nextPause = -1                  --When is the next pause?
    }
  ant.comRadius = 20                  -- Distance of comunication Ant-to-Ant. ant.radius is body radius
    
  
  --PRIVATE functions
  --TODO: local function checkFor
    
  --PUBLIC 
  ant.classType = TAnt 
  ant.classParent = TActor 
  
    
  function ant.init()          
    --preallocating  array
    for i=1,cfg.antPositionMemorySize do
      fPastPositions[i] = vec.makeFrom( ant.position )
      fPastPositionSpeeds[i]=ant.speed
    end
    fOldestPositionIndex = 1
    ant.oldestPositionRemembered = fPastPositions[1]
    ant.oldestPositionRememberedSpeed=fPastPositionSpeeds[1]
  end
  
  function ant.taskFound( cell )
    --swap
    ant.lookingFor, ant.nextTask = ant.nextTask, ant.lookingFor        
    local dv = vec.makeScale( ant.direction, -1) --go oposite 
    ant.direction = dv      
    ant.speed = 0          
    ant.disablePheromonesWrite( cfg.antPositionMemorySize )
  end
  
  function ant.updatePaused()    
    if cfg.simFrameNumber >= ant.pauseUntil then ant.unPause() end    
  end
  
  --- 
  function ant.disablePheromonesWrite( time )
    ant.pheromonesWrite = false
    ant.pheromonesBackTime = cfg.simFrameNumber + time
  end
  
  function ant.enablePheromonesWrite()
    ant.pheromonesWrite = true
  end
  
  --- Pause ant movement and thinking
  -- negaive time to pause indefinitely 
  function ant.pause( time )    
    ant.pauseUntil = cfg.simFrameNumber + time
    ant.paused = true    
  end
 
  function ant.unPause()
    ant.paused = false
  end
  
  --return normalized dir heading to Posi, or {1,0} if length = 0
  
  function ant.getDirectionTo( posi )
    local tempVec = vec.makeSub( posi, ant.position )
    local tempLen = vec.length( tempVec )
    if tempLen == 0 then tempVec[1],tempVec[2] = 1,0 else
      tempVec[1] = tempVec[1] / tempLen
      tempVec[2] = tempVec[2] / tempLen
    end  
    return tempVec
  end
  
  -- same as getDirectionTo, but do not create and not return a new table, use the one in the parameter
  function ant.setDirectionTo(varVec, posi )
    vec.setFrom( varVec, posi)
    vec.sub( varVec, ant.position )
    local tempLen = vec.length( varVec )
    if tempLen == 0 then varVec[1], varVec[2] = 1,0 else
      varVec[1] = varVec[1] / tempLen
      varVec[2] = varVec[2] / tempLen
    end      
  end
  
  function ant.storePositionAndSpeed( posi ,speed)
     vec.setFrom( fPastPositions[fOldestPositionIndex], posi )
     fPastPositionSpeeds[fOldestPositionIndex]=speed
     fOldestPositionIndex = fOldestPositionIndex + 1
     if fOldestPositionIndex > cfg.antPositionMemorySize then fOldestPositionIndex = 1 end     
     ant.oldestPositionRemembered = fPastPositions[ fOldestPositionIndex ]
     ant.oldestPositionRememberedSpeed = fPastPositionSpeeds[ fOldestPositionIndex ]
  end

  
  
  function ant.resetPositionMemory( posi )
      for i = 1, #fPastPositions do
        vec.setFrom( fPastPositions[i], posi )
      end
  end
  
  --- Avoid collisions with obstacles
 
  function ant.objectAvoidance()
    local ahead = vec.makeScale( ant.direction, cfg.antSightDistance )
    local adir = { ant.direction[1], ant.direction[2] }
    if  not map.gridCanPass(vec.makeSum( ant.position, ahead )) then        
      -- if something blocking ahead, where to turn? left or right?
      --print('something in my way')
      local vLeft = vec.makeFrom( ant.direction )
      local vRight = vec.makeFrom( ant.direction )
      
        local blocked = false
        vec.rotate( vLeft, -cfg.antObjectAvoidance_FOV )
        vec.rotate( vRight, cfg.antObjectAvoidance_FOV )
        local goLeft = vec.makeScale( vLeft, cfg.antSightDistance/2 )
        local goRight = vec.makeScale( vRight, cfg.antSightDistance/2 )    
        vec.add( goLeft, ant.position )
        vec.add( goRight, ant.position )
        local freeLeft = map.gridCanPass( goLeft )
        local freeRight = map.gridCanPass( goRight )      
        
        if freeLeft and not freeRight then
          --goleft
          vec.setFrom( ant.direction, vLeft )        
        elseif freeRight and not freeLeft then
          --goright
          vec.setFrom( ant.direction, vRight )              
        elseif not freeLeft and not freeRight then 
          --I'm blocked try more wide, one more time
          blocked = true
        end
      
    end
  end 
  
 
  
  
  function ant.update()     
    ant.storePositionAndSpeed( ant.position ,ant.speed )    
    
    if ant.paused then
      ant.updatePaused()
    else      
      ant.speed = ant.speed + ant.acceleration
      ant.speed = ant.speed * ant.friction
      if ant.speed > ant.maxSpeed then ant.speed = ant.maxSpeed end               
      
      -- direction variation for next update    
      vec.rotate( ant.direction, ant.erratic * math.random() -(ant.erratic*0.5) )    
      
      ant.friction = 1   
      --if math.random()<0.01 then ant.pause(10) end
      
    end    
    --test pause    
  end
  
  function ant.dirToRad()
    if ant.direction[2]>0 then 
      return math.acos( ant.direction[1] )
    else
      return math.pi*2 - math.acos( ant.direction[1] )
    end    
  end

  function ant.drawNormal()            
    apiG.setColor(ant.color)
        
   apiG.line(ant.position[1] - ant.direction[1]*2, ant.position[2] - ant.direction[2]*2, ant.position[1] + ant.direction[1]*2, ant.position[2] + ant.direction[2]*2 ) 
    --sprites draw
    local imgIdx = math.floor(ant.traveled % 4 )
    apiG.draw(imgAntWalk[ imgIdx ], ant.position[1] , ant.position[2], ant.dirToRad(), cfg.imgScale, cfg.imgScale, 16, 16)
    
    
    if ant.cargo.count~=0 then
      apiG.setColor(cfg.colorFood)
      if not cfg.debugGrid then apiG.circle("line", ant.position[1] + ant.direction[1]*2.1, ant.position[2] + ant.direction[2]*2.1, 0.5) end
    end
    -- debug    
  end
  
  ant.draw = ant.drawNormal
  
  function ant.drawDebug()
    ant.drawNormal()    
    apiG.setColor(cfg.colorBlue)
    apiG.circle("line",ant.oldestPositionRemembered[1], ant.oldestPositionRemembered[2],1);
    --sight and comunication radius
    apiG.setColor(cfg.colorGray)
    apiG.circle( "line", ant.position[1], ant.position[2], cfg.antSightDistance );    
  end
  
  function ant.setDrawMode( mode )
    if mode=="debug" then ant.draw = ant.drawDebug
    else ant.draw = ant.drawNormal
    end
  end
     
  
  function ant.headTo( posi )             
    vec.setFrom( ant.direction, posi)
    vec.sub( ant.direction, ant.position )
    local tempLen = vec.length( ant.direction )
    if tempLen == 0 then ant.direction[1], ant.direction[2] = 1,0 else
     ant.direction[1] = ant.direction[1] / tempLen
     ant.direction[2] = ant.direction[2] / tempLen
    end
    ant.lastTimeUpdatedPath = cfg.simFrameNumber
  end 
  
  --- ask ant if need comunication for this frame
  -- TODO: name has to change, is not always communication.. not in algorithm 4
  function ant.isComNeeded()
    return 
      ((cfg.simFrameNumber + fComEveryOffset) % fComEvery == 0     )   
  end
  function ant.communicate()
    local X = ant.grid[1]
    local Y = ant.grid[2]
    local destination={0,0}
    local detectAnts=0
    local otherAnts = 0
    for i=1,9 do
      local grid=map.grid[X + cfg.mapGridComScan[i][1]]
                        [Y + cfg.mapGridComScan[i][2]]
      for _,ant2  in pairs(grid.ants) do
        detectAnts=detectAnts+1
        if detectAnts>=20 then goto endfor end --Jump out of the two-level `for` loop
        if ant2.pheromonesWrite then
          local interest= ant.lookingFor
          local time =ant2.lastTimeSeen[interest]
          if interest== ant2.nextTask and time > ant.maxTimeSeen 
          then
            ant.maxTimeSeen=time
            vec.add(destination,ant2.oldestPositionRemembered)
            otherAnts=otherAnts+1
            
          end      
        elseif cfg.simFrameNumber >= ant2.pheromonesBackTime  then ant2.enablePheromonesWrite() end  
        
      end--for
    end --for
    ::endfor::
    if otherAnts > 0 then 
      vec.scale(destination,1/otherAnts) 
    ant.headTo(destination)
    end --if
  end
          
  function ant.detectNeighbor()--detect food or cave and just set direction to it
    local X = ant.grid[1]
    local Y = ant.grid[2]
    for i=1,9 do
      local grid=map.grid[X + cfg.mapGridComScan[i][1]]
                       [Y + cfg.mapGridComScan[i][2]]
      if grid.cell and grid.cell.type ==ant.lookingFor then
        -- local vector1 =  vec.makeSub(ant.grid ,ant.position)
        -- local vector2 = vec.makeSum(cfg.mapGridComScan[i],vector1)
        ant.direction =vec.makeNormalized(cfg.mapGridComScan[i])
      end
    end 
  end
  return ant
end

return TAnt
