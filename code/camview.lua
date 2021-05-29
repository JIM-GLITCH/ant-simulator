local cfg = require('code.simconfig')

local cam = {}

cam.translation = {x=0, y=0}
cam.zoomOrigin = {x = 0, y = 0}
cam.scale ={x = 1, y = 1}        -- this is the scale of world
cam.contentScale = 1             -- this is the scale of the app due to screen change in resolution

function cam.screenToWorld(x, y)
  return 
    ( (x - cam.translation.x ) /cam.scale.x / cam.contentScale ), 
    ( (y - cam.translation.y ) /cam.scale.y / cam.contentScale )
end

function cam.screenToGrid(x, y)
    return 
    math.floor( ( (x - cam.translation.x ) /cam.scale.x / cam.contentScale ) / cfg.mapGridSize ), 
    math.floor( ( (y - cam.translation.y ) /cam.scale.y / cam.contentScale ) / cfg.mapGridSize )
end

-- zoom in out the world
function cam.zoom( inc )
  local oldsx = cam.scale.x
  local oldsy = cam.scale.y
  cam.scale.x = cam.scale.x + inc
  cam.scale.y = cam.scale.y + inc
  -- check the zooming limits
  if cam.scale.x <0.5 then
    cam.scale.x = 0.5
    cam.scale.y = 0.5
  elseif cam.scale.x > cfg.zoomMaxScale then
    cam.scale.x = cfg.zoomMaxScale
    cam.scale.y = cfg.zoomMaxScale
  end 
  
  --"Pinning" the zoom to occur having cam.zoomOrigin as the center 
  local dx = cam.translation.x - cam.zoomOrigin.x
  local dy = cam.translation.y - cam.zoomOrigin.y  
  cam.translation.x = cam.zoomOrigin.x + dx * ( cam.scale.x / oldsx )
  cam.translation.y = cam.zoomOrigin.y + dy * ( cam.scale.y / oldsy )
  
end

return cam