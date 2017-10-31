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
      b = love.math.random(1,3)
        if b == 1 then
          love.audio.play(burp1)
        elseif b == 2 then
          love.audio.play(burp2)
        else
          love.audio.play(burp3)
        end
        return true
    end
end

function setFood()
    a = food.x
    b = food.y 
    food.x = love.math.random(0, love.graphics.getWidth()/8-1)
    food.y = love.math.random(0, love.graphics.getHeight()/8-1)
    for i,v in pairs(snake) do
        if v.x==food.x and v.y==food.y then
            setFood()
        end
    end
end

function init() -- beherbergt Grundeinstellungen
  t = 0 --time
  score = 0
  --ersten drei Körperteile der Snake
  snake = {
    {x = 15, y = 8, color = colorBody}, --tail
    {x = 14, y = 8, color = colorBody}, --neck
    {x = 13, y = 8, color = colorHead}, --head
  }
  --Ablage des Futters
  food = {x = 25, y = 25}
  a = food.x  -- stores values for particle emit
  b = food.y  -- stores values for particle emit
  --Richtung der Snake
  dirs={
      [0]={x= 0,y=-1}, --up
      [1]={x= 0,y= 1}, --down
      [2]={x=-1,y= 0}, --left
      [3]={x= 1,y= 0} --right
      }
  dir=dirs[0]
  gameState = 1
end 

-- load start
function love.load()
 burp1 = love.audio.newSource("assets/eat1.wav")
 burp2 = love.audio.newSource("assets/eat2.wav")
 burp3 = love.audio.newSource("assets/eat3.wav")
 gameMusic = love.audio.newSource("assets/game.mp3")
 deathMusic = love.audio.newSource("assets/death.mp3")

 init() -- lädt Grundeinstellungen zum Spiel

-- Partikelsystem Setup
 local particleImg = love.graphics.newImage("assets/particle.png")
 pSystem = love.graphics.newParticleSystem(particleImg, 32)
 pSystem:setParticleLifetime(0.6,1.5)
 pSystem:setLinearAcceleration(-30, -30, 30, 30)
 pSystem:setSpeed(0)
 pSystem:setRotation(10,20)

end -- load end

--##############################################################################

-- update start
function love.update(dt)
  t = t + 1
  
  head = snake [#snake]   -- Kopf ist immer am Ende der Tabelle     
  neck = snake [#snake-1] -- der Nacken ist in der vorletzten Spalte

  pSystem:update(dt)

  for i, v in pairs(snake) do
    if i~=#snake and v.x == head.x and v.y == head.y then
        gameState = 3
    end
  end
  
  if gameState == 3 then
        love.audio.stop(gameMusic)
        love.audio.play(deathMusic)
  elseif gameState == 2 then
        love.audio.stop(deathMusic)
        love.audio.play(gameMusic)
  end

  if update() then
    head.color = colorBody
    table.insert(snake, #snake+1, {x=(head.x+dir.x)%(love.graphics.getWidth()/8), y=(head.y+dir.y)%(love.graphics.getHeight()/8), color = colorHead})
    if not gotFood() then
      table.remove(snake,1)
    else
      score = score + 1   
      particleCreate()   --Aktiviert das Ausstoßen der Partikel
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
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("NIMMERSATT - by Möhrchie and Steffen", 10, love.graphics.getWidth()/3) 
    love.graphics.print("Press ENTER to grow and consume yourself!", 30, (love.graphics.getWidth()/3)+20)
      if love.keyboard.isDown("return") then
        gameState = 2
      end
  end

  if gameState == 2 then
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
  

  love.graphics.draw(pSystem, a * 8, b * 8) -- Definiert den Ort der ausgestoßenen Partikel

  function particleCreate() -- Partikelausstoß (Anzahl)
    pSystem:emit(32)
  end

  if gameState == 3 then
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("GAME OVER    Punkte: "..score, 30, (love.graphics.getWidth()/3)+20)
    love.graphics.setColor(255, 0, 0)
    love.graphics.printf("Press ENTER to die again!", 0, love.graphics.getHeight()/2,love.graphics.getWidth(),"center")
      if love.keyboard.isDown("return") then
        init() -- reset der Grundeinstellungen
      end
    --love.graphics.printf(
  end

end -- draw end

