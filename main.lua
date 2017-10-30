colorHead = {200,20,30}
colorBody = {40,120,70}
colorFood = {60,200,0}
widthSegment = 8
heightSegment = 8
radiusSegment = 4

function update()
  return t % 10 == 0
end

function gotFood()
    if head.x==food.x and head.y==food.y then
        return true
    end
end

function setFood()
    food.x=math.random(0, love.graphics.getWidth()/8-1)
    food.y=math.random(0, love.graphics.getHeight()/8-1)
    for i,v in pairs(snake) do
        if v.x==food.x and v.y==food.y then
            setFood()
        end
    end
end


-- load start
function love.load()
  gameState = 1
  
  t=0 --time
  
  score=0
  --ersten drei Körperteile der Snake
  snake={
    {x=15,y=8, color = colorBody}, --tail
    {x=14,y=8, color = colorBody}, --neck
    {x=13,y=8, color = colorHead}, --head
  }
  --Ablage des Futters
  food={x=25,y=25}

  --Richtung der Snake
  dirs={
  [0]={x= 0,y=-1}, --up
  [1]={x= 0,y= 1}, --down
  [2]={x=-1,y= 0}, --left
  [3]={x= 1,y= 0} --right
  }


  dir=dirs[0]
end -- load end

--##############################################################################

-- update start
function love.update(dt)
  t = t + 1
  
  head = snake [#snake]   -- Kopf ist immer am Ende der Tabelle     
  neck = snake [#snake-1] -- der Nacken ist in der vorletzten Spalte

  for i, v in pairs(snake) do
    if i~=#snake and v.x == head.x and v.y == head.y then
        gameState = 2
    end
  end
  

  if update() then
    head.color = colorBody
    table.insert(snake, #snake+1, {x=(head.x+dir.x)%(love.graphics.getWidth()/8), y=(head.y+dir.y)%(love.graphics.getHeight()/8), color = colorHead})
    if not gotFood() then
      table.remove(snake,1)
    else
      radiusSegment = radiusSegment * 1.1
      score = score + 1      
      setFood() 
    end
  end
  
  local last_dir = dir
  if love.keyboard.isDown ("up") then dir = dirs[0] end
  if love.keyboard.isDown ("down") then dir = dirs[1] end
  if love.keyboard.isDown ("left") then dir = dirs[2] end
  if love.keyboard.isDown ("right") then dir = dirs[3] end
  
  if love.keyboard.isDown ("escape") then love.event.push ("quit") end
  
  if head.x + dir.x == neck.x and head.y + dir.y == neck.y then
    dir = last_dir
  end

end -- update end

--##############################################################################

-- draw start
function love.draw()

  if gameState == 1 then
      for i,v in pairs(snake) do
          love.graphics.setColor (unpack(v.color))
          --love.graphics.rectangle ("fill",v.x*8,v.y*heightSegment,widthSegment,heightSegment)
          love.graphics.circle ("fill", v.x * 8, v.y * 8, radiusSegment)
      end
      love.graphics.setColor (unpack(colorFood))
      --love.graphics.rectangle ("fill",food.x*8,food.y*heightSegment,widthSegment,heightSegment)
      love.graphics.circle ("fill", food.x * 8, food.y * 8, radiusSegment)
      love.graphics.setColor (255,255,255)
      love.graphics.print("Punkte: "..score)
      local t2 = t/60
      love.graphics.print("Zeit: "..string.format("%.0f", t2), 250, 0)
  end
  
  if gameState == 2 then
    love.graphics.printf("GAME OVER    Punkt: "..score, 0, love.graphics.getHeight()/2,love.graphics.getWidth(),"center")
    --love.graphics.printf(
  end
end -- draw end

