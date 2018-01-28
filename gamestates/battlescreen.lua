--- LIBRARIES
local Color = require "libs.colors"
local Gamestate = require "libs.hump.gamestate"
local Terminal = require "libs.terminal"
local Dictionary = require "libs.dictionary"
local TranslationGame = require "gamestates.translationgame"
local Enemy = require "libs.entities.enemy"
local Player = require "libs.entities.player"
local HUD = require "libs.entities.hud"

--- INSTANTIATION
local BattleScreen = {}

local image = love.graphics.newImage("media/images/plains.jpg")

--- Constants
local INITIAL_PLAYER = {
  hp = 50, atk = 4
}
local HUD_PADDING = 10
local HUD_HEIGHT = 150
local HUD_WIDTH = 780
FONT = love.graphics.newFont("media/fonts/consola.ttf", 50)
size50 = love.graphics.newFont(50)

--- initializes the class or whatever
--- x and y are in terms of tiles, not actual positions on screen
function BattleScreen:enter()
  CURRENT_GAMESTATE = "battlescreen"
  love.keyboard.setKeyRepeat(true)
  
  self.currentEnemy = 0
  self.currentDamage = 0
  
  translationGame = TranslationGame(self)
  
  local stranger1 = Enemy(200, "Stranger")
  local stranger2 = Enemy(450, "Stranger")
  self.enemy_list = {stranger1, stranger2}
  
  self.player = Player(INITIAL_PLAYER.hp, INITIAL_PLAYER.atk)
  
  self.hud = HUD(self.enemy_list, HUD_WIDTH, HUD_HEIGHT, HUD_PADDING, self.player)
end


--- Draws the Level to the screen.
function BattleScreen:draw() 
  love.graphics.draw(image, 0, 0, nil)
  self.hud:draw()
  self.player:draw()
  for i, v in ipairs(self.enemy_list) do
    if not self.enemy_list[i]:isDead()then
      self.enemy_list[i]:draw()
    end
  end
  translationGame:getWords("tag","ceb", 1)
  translationGame:setLang("tag")
  translationGame:draw()
end

--- Updates every frame.
-- @param dt The delta time or time since the last frame
function BattleScreen:update(dt) 
  self.hud:update(dt)
  -- hud:getAction() returns a table with values that are parsed to get an action
  playerCommand = self.hud:getAction()
  translationGame:update(dt)
  
  if(playerCommand[1] == "attack" and not self.player:isDead() and not self.hud:hasQueue()) then
    if not self.enemy_list[playerCommand[2]]:isDead()then
      translationGame:display()
      
      message1 = "You attack " .. self.enemy_list[playerCommand[2]].name .. "! ..."
      self.hud:queueMessage(message1)
      
      self.currentEnemy=  playerCommand[2]
      
      
    
      if(self.enemy_list[playerCommand[2]]:isDead()) then
        self.hud:queueMessage(self.enemy_list[playerCommand[2]].name.. " is defeated!")
      end
      
      for i, v in ipairs(self.enemy_list) do
        
        message1 = v.name .. " attacks!"
        message2 = v.name .. " deals "  .. self.player:dealDamage() .. " damage! ..."
        
        self.hud:queueMessage(message1)
        self.hud:queueMessage(message2)
        
        self:battle(v, self.player)
        print(self.player:getHP())
      end
      
      self.enemy_list[playerCommand[2]]:draw()
      self.hud:completeAction()
    end
  end
end

function BattleScreen:battle(a, b)
  b:takeDamage(a:dealDamage())
end

function BattleScreen:keypressed(key)
  if(CURRENT_GAMESTATE == "translationgame") then
    translationGame:keypressed(key)
  elseif(key ~= "escape" and CURRENT_GAMESTATE == "battlescreen") then
    self.hud:keypressed(key)
  end
end

function love.textinput(t)
  if(CURRENT_GAMESTATE == "translationgame") then
    translationGame:textinput(t)
  end
end

return BattleScreen