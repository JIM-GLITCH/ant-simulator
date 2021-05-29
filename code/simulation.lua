
--- simulation 
local cfg = require('code.simconfig')
local cam = require('code.camview')
local TAnt = require('code.ant')
local map = require('code.map')
local TQuickList = require('code.qlist')
local vec = require('libs.vec2d_arr')
local TCell = require('code.cell')
local mapExample = require('code.mapexample')
local sim = {}

sim.interactionAlgorithm = {}

function sim.init()  
  math.randomseed(os.time())
  cfg.init()
  -- map = require('code.map')
  map.init()
  -- TAnt = require('code.ant')  
  TAnt.init()
  
  -- map.setCell_cave(20, 20)
  -- map.setCell_food(12, 5)
  
  -- local newAnt
  -- local numAnts = cfg.numAnts
  -- if CURRENT_PLATFORM == 'mobile'then numAnts = cfg.numAntsMobile end
  -- for i=1,numAnts do
  --   newAnt = TAnt.create() 
  --   newAnt.init()
  --   map.addAnt( newAnt )
  --   local ang = math.random()*6.28
  --   newAnt.direction = {math.cos(ang), math.sin(ang)}
  --   newAnt.position[1] = math.cos(ang)*(50+i/60)
  --   newAnt.position[2] = math.sin(ang)*(50+i/60)
  --   if i<4 then newAnt.setDrawMode("debug") end
  -- end  
end

function sim.start()
  cfg.start=true
  cfg.pause=false
  local newAnt
  local numAnts = cfg.numAnts
  if CURRENT_PLATFORM == 'mobile'then numAnts = cfg.numAntsMobile end
  for i=1,numAnts do
    newAnt = TAnt.create() 
    newAnt.init()
    map.addAnt( newAnt )
    local ang = math.random()*6.28
    newAnt.direction = {math.cos(ang), math.sin(ang)}
    -- newAnt.position[1] =cfg.antBirthPlace[1] + math.cos(ang)*(50+i/60)
    -- newAnt.position[2] =cfg.antBirthPlace[2] +  math.sin(ang)*(50+i/60)
    newAnt.position[1] =cfg.antBirthPlace[1]
    newAnt.position[2] =cfg.antBirthPlace[2]
    if i<4 then newAnt.setDrawMode("debug") end
  end  
  
end

function sim.changeMap()
  cfg.mapExampleNumber=cfg.mapExampleNumber+1
  if mapExample.example[cfg.mapExampleNumber] then
  --doNothing
  else 
    cfg.mapExampleNumber=1
  end
  sim.init()
  
end

sim.stop=sim.init

function sim.algorithm_doNothing()
    
end

function sim.interactionWithCells(ant)
  local gx = math.floor( ant.position[1] / cfg.mapGridSize )
  local gy = math.floor( ant.position[2] / cfg.mapGridSize )
  local cell =  map.grid[gx][gy].cell
  local grid =map.grid[gx][gy]
  if grid.isFound ==false then grid.isFound=true; cfg.mapGridFound=cfg.mapGridFound+1 end
  if cell then     
      cell.affectAnt( ant )      
      -- is this cell interesting for me?
      if ant.lastTimeSeen[cell.type] then ant.lastTimeSeen[cell.type] = cfg.simFrameNumber   end
      if cell.type=="food" and cell.storage<=0 then 
          -- turn this cell into empty
          map.grid[gx][gy].cell=TCell.newGround() 
          map.grid[gx][gy].pass=true 
      end
  end
end



-- **Mix of old algorithm with Pheromones inspiration**, store bestSeen info on the cells.
-- this time they communicate indirectly using the Grid cells, equivalent to pheromones nature
function sim.algorithm_pheromones()  
    for _,node in pairs(map.ants.array) do      
      --ant bounces with limits
      local ant = node.obj 
      if not ant.paused then
       
      --ants with surfaces      
        map.resolve_BlockingCollision_andMove( ant ) 
        sim.interactionWithCells(ant)
                
        
        if (cfg.antComEveryFrame or ant.isComNeeded())  then                            
          --get info on ant cell position, of time and position stored from other ants.
         -- local antPosiX, antPosiY = ant.gridInfo.posi[1], ant.gridInfo.posi[2] 
          local antPosiX = math.floor( ant.position[1] / cfg.mapGridSize )
          local antPosiY = math.floor( ant.position[2] / cfg.mapGridSize )
          local pheromInfoSeen
          --TODO: what if ant can see a good phermone close to current cell and go for it? 
          for i=1,9 do
            pheromInfoSeen = map.grid[ antPosiX + cfg.mapGridComScan[i][1]  ]
                                     [ antPosiY + cfg.mapGridComScan[i][2]  ].pheromInfo.seen
            local myInterest = pheromInfoSeen[ ant.lookingFor ]
            
            if  myInterest.time > ant.maxTimeSeen then                
              ant.maxTimeSeen = myInterest.time
              ant.headTo( myInterest.where )
            end              
          end
          -- share what i Know in the map... if
          if ant.pheromonesWrite then 
            
            pheromInfoSeen = map.grid[ antPosiX ] [ antPosiY ].pheromInfo.seen
            for name,time in pairs(ant.lastTimeSeen) do                
              local interest = pheromInfoSeen[ name ]                
              if time > interest.time then
                  interest.time = time                    
                  interest.where[1] = ant.oldestPositionRemembered[1]
                  interest.where[2] = ant.oldestPositionRemembered[2]               
              end
            end --for             
            
          elseif cfg.simFrameNumber >= ant.pheromonesBackTime  then ant.enablePheromonesWrite() end
          
        end   
        
        --ant knows where to go, but lets avoid some future collisons
        if cfg.antObjectAvoidance then ant.objectAvoidance()    end
      end --paused?
      ant.update() 
    end --for ant node    
end

function sim.algorithm_speed_pheromones()  
  for _,node in pairs(map.ants.array) do      
    --ant bounces with limits
    local ant = node.obj 
    if not ant.paused then
     
    --ants with surfaces      
      map.resolve_BlockingCollision_andMove( ant )
      sim.interactionWithCells(ant)
              
      
      if (cfg.antComEveryFrame or ant.isComNeeded())  then                            
        --get info on ant cell position, of time and position stored from other ants.
       -- local antPosiX, antPosiY = ant.gridInfo.posi[1], ant.gridInfo.posi[2] 
        local antPosiX = math.floor( ant.position[1] / cfg.mapGridSize )
        local antPosiY = math.floor( ant.position[2] / cfg.mapGridSize )
        local pheromInfoSeen
        --TODO: what if ant can see a good phermone close to current cell and go for it? 
        for i=1,9 do
          pheromInfoSeen = map.grid[ antPosiX + cfg.mapGridComScan[i][1]  ]
                                   [ antPosiY + cfg.mapGridComScan[i][2]  ].pheromInfo.seen
          local myInterest = pheromInfoSeen[ ant.lookingFor ]
          
          if  myInterest.time > ant.maxTimeSeen then                
            ant.maxTimeSeen = myInterest.time
            ant.headTo( myInterest.where )
          end              
        end
        -- share what i Know in the map... if
        if ant.pheromonesWrite then 
          
          pheromInfoSeen = map.grid[ antPosiX ] [ antPosiY ].pheromInfo.seen
          for name,time in pairs(ant.lastTimeSeen) do                
            local interest = pheromInfoSeen[ name ]                
            if time > interest.time then
                interest.time = time                    
                -- local Proportion= ant.oldestPositionRememberedSpeed / ant.speed
                local Proportion=1              
                interest.where[1] = ant.position[1]+(ant.oldestPositionRemembered[1]-ant.position[1])*Proportion
                interest.where[2] = ant.position[2]+(ant.oldestPositionRemembered[2]-ant.position[2])*Proportion  
            --     interest.where = vec.makeSum(ant.position,
            --                                  vec.makeScale(
            --                                    vec.makeSub(ant.oldestPositionRemembered,ant.position),
            --                                    Proportion))
             end
          end --for             
          
        elseif cfg.simFrameNumber >= ant.pheromonesBackTime  then ant.enablePheromonesWrite() end
        
      end   
      
      --ant knows where to go, but lets avoid some future collisons
      if cfg.antObjectAvoidance then ant.objectAvoidance()    end
    end --paused?
    ant.update() 
  end --for ant node  
end


function sim.algorithm_communication()
  for _,node in pairs(map.ants.array) do      
    --ant bounces with limits
    local ant = node.obj 
    if not ant.paused then
     
    --ants with surfaces      
      map.resolve_BlockingCollision_andMove( ant ) 
      sim.interactionWithCells(ant)
              
      
      if (cfg.antComEveryFrame or ant.isComNeeded())  then                            
        --get info on ant cell position, of time and position stored from other ants.
       -- local antPosiX, antPosiY = ant.gridInfo.posi[1], ant.gridInfo.posi[2] 
        local antPosiX = math.floor( ant.position[1] / cfg.mapGridSize )
        local antPosiY = math.floor( ant.position[2] / cfg.mapGridSize )
        if antPosiX ==ant.grid[1] and antPosiY==ant.grid[2]  then
        else 
          --change the ant's communication area from a grid to another grid
          map.grid[ant.grid[1]][ant.grid[2]].ants[ant.id] = nil
          map.grid[antPosiX][antPosiY].ants[ant.id]=ant
          ant.grid={antPosiX,antPosiY}
        end
        ant.communicate()
        -- ant.detectNeighbor()
      end
      ant.update()
    end 
  end
end

function sim.update()
  if cfg.FindAllFoodTime==-1  and cfg.foodNumbers==0 then  cfg.firstFindFoodTime=cfg.simFrameNumber   end
  if cfg.antComAlgorithm == 1 then sim.algorithm_pheromones() 
  elseif cfg.antComAlgorithm == 2 then  sim.algorithm_speed_pheromones()
  elseif cfg.antComAlgorithm == 3 then sim.algorithm_communication()
  else sim.algorithm_doNothing() end

  -- for _,node in pairs(map.ants.array) do
  --   node.obj.update()    
  --   --update on grid > don't delete yet, maybe needed again chico.
  --   --map.updateOnGrid(map.grid, node.obj)  
  -- end

  cfg.simFrameNumber = cfg.simFrameNumber + 1
end

function sim.draw()
  map.draw()  
  if not cfg.debugHideAnts then
    for _,node in pairs(map.ants.array) do
      node.obj.draw()    
    end  
  end
end

function sim.onClick(x, y)
  local xg, yg = map.worldToGrid( x, y)  
  if map.isInsideGrid(xg, yg) then map.grid[xg][yg].pass = false end
end

function sim.removeCell(xg, yg)
  if map.isInsideGrid(xg, yg) then
    local grid = map.grid[xg][yg]
    if grid.cell then
        -- be carful with portals, they are linked
        if grid.cell.type == 'portal' then
          --remove link too
          if grid.cell.link then
            local linkedCell = map.grid[ grid.cell.link.gridPos[1] ][ grid.cell.link.gridPos[2] ]
            linkedCell.pass = true
            linkedCell.cell = nil
          end
        end        
        grid.cell = nil
      end
      grid.pass = true
  end
end

function sim.setCell( cellType, xworld, yworld)
  local xg, yg = map.worldToGrid( xworld, yworld)  
  if map.isInsideGrid(xg, yg) then
    --always remove existing first:
    -- 
    local grid = map.grid[xg][yg]
    
    if (cellType == 'block') or (cellType == 'obstacle') or (cellType == 'donotpass') then
      grid.pass = false
      grid.cell=nil
    elseif (cellType == 'grass') then
      grid.pass = true
      grid.cell = TCell.newGrass()
    elseif (cellType == 'food') and (grid.cell==nil or grid.cell.type ~= 'food') then
      grid.pass = true
      grid.cell = TCell.newFood()
    elseif (cellType == 'cave') then
      grid.pass = true
      grid.cell = TCell.newCave()
    elseif (cellType == 'ground') or (cellType == "remove") then
      --sim.removeCell(xg, yg)
      if grid.cell and grid.cell.type =='food' then
        if grid.cell.isFound==false then 
          cfg.foodNumbers=cfg.foodNumbers-1
        end
      end
      sim.removeCell(xg, yg)
    elseif (cellType == 'portal') then
      grid.pass = true
      grid.cell = TCell.newPortal()
      grid.cell.gridPos = {xg, yg} 
      grid.cell.posi = {xg * cfg.mapGridSize, yg * cfg.mapGridSize}
      
    end
  end    
end


return sim
