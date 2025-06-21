local settingsscreen = {}

local gamestate = require("gamestate")
local audio = require("audio")
local settings = require("settings")
local nineslice = require("nineslice")

-- Fonts and layout
local headingFont = love.graphics.newFont("Assets/Orbitron-Bold.ttf", 48)
local buttonFont = love.graphics.newFont("Assets/Orbitron-Bold.ttf", 24)
local uiBoxImage = love.graphics.newImage("Assets/UI_box.png")

local buttonWidth, buttonHeight = 240, 48
local buttonSpacing = 20
local activeSlider = nil

-- Slider state for music and sfx
local sliders = {
   music = {
      width = 240,
      height = 16,
      y = 0,
   },
   sfx = {
      width = 240,
      height = 16,
      y = 0,
   }
}

-- Buttons
local buttons = {
   {
      label = function() return audio.muted.music and "Unmute Music" or "Mute Music" end,
      action = function()
         audio.toggleMuteMusic()
         settings.save()
		 audio.playSFX("Click")
      end
   },
   {
      label = function() return audio.muted.sfx and "Unmute SFX" or "Mute SFX" end,
      action = function()
         audio.toggleMuteSFX()
         settings.save()
		 audio.playSFX("Click")
      end
   },
   {
      label = "Back",
      action = function()
         gamestate.returnToPreviousState()
		 audio.playSFX("Click")
      end
   }
}

local function clamp(val, min, max)
   return math.max(min, math.min(max, val))
end

function settingsscreen.mousepressed(x, y, button)
   if button == 1 then
	   for name, s in pairs(sliders) do
		  local sx = love.graphics.getWidth() / 2 - s.width / 2
		  local sy = s.y
		  if x >= sx and x <= sx + s.width and y >= sy - 8 and y <= sy + s.height + 8 then
			 activeSlider = name -- set which slider is being dragged
			 local percent = clamp((x - sx) / s.width, 0, 1)

			 if name == "music" then
				audio.setMusicVolume(percent)
				settings.musicVolume = percent
			 elseif name == "sfx" then
				audio.setSFXVolume(percent)
				settings.sfxVolume = percent
			 end

			 settings.save()
			 return
		  end
	   end

      for i, b in ipairs(buttons) do
         local bx = getButtonX()
         local by = getButtonY(i)
         if x >= bx and x <= bx + buttonWidth and y >= by and y <= by + buttonHeight then
            b.action()
            break
         end
      end
   end
end

function settingsscreen.mousereleased(x, y, button)
   if button == 1 then
      activeSlider = nil
   end
end

function settingsscreen.mousemoved(x, y, dx, dy)
   if activeSlider then
      local slider = sliders[activeSlider]
      local sx = love.graphics.getWidth() / 2 - slider.width / 2
      local percent = clamp((x - sx) / slider.width, 0, 1)

      if activeSlider == "music" then
         audio.setMusicVolume(percent)
         settings.musicVolume = percent
      elseif activeSlider == "sfx" then
         audio.setSFXVolume(percent)
         settings.sfxVolume = percent
      end

      settings.save()
   end
end

function settingsscreen.draw()
   love.graphics.clear(0.05, 0.07, 0.15)
   local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()

   -- Position sliders
   sliders.music.y = screenH * 0.28
   sliders.sfx.y = screenH * 0.38

   -- Title
   love.graphics.setFont(headingFont)
   love.graphics.setColor(0.6, 0.9, 1)
   love.graphics.printf("Settings", 0, 80, screenW, "center")

   -- Draw Sliders
   love.graphics.setFont(buttonFont)

   for name, slider in pairs(sliders) do
      local label = name == "music" and "Music Volume" or "SFX Volume"
      local value = name == "music" and audio.volume.music or audio.volume.sfx
      local percent = math.floor(value * 100 + 0.5)
      local y = slider.y
      local x = screenW / 2 - slider.width / 2
      local knobX = x + value * slider.width

      love.graphics.setColor(0.6, 0.9, 1)
      love.graphics.printf(label, 0, y - 28, screenW, "center")
      love.graphics.printf(percent .. "%", x + slider.width + 20, y - 4, 80, "left")

      love.graphics.setColor(1, 1, 1)
      love.graphics.rectangle("fill", x, y + 6, slider.width, 4)

      love.graphics.setColor(0.8, 0.9, 1)
      love.graphics.rectangle("fill", knobX - 6, y, 12, slider.height)
   end

   -- Buttons
   local mx, my = love.mouse.getPosition()
   for i, b in ipairs(buttons) do
      local bx = getButtonX()
      local by = getButtonY(i)
      local isHovered = mx >= bx and mx <= bx + buttonWidth and my >= by and my <= by + buttonHeight

      love.graphics.setColor(1, 1, 1)
      nineslice.draw(uiBoxImage, bx, by, buttonWidth, buttonHeight)

      local text = type(b.label) == "function" and b.label() or b.label
      local color = isHovered and {1, 1, 0.8} or {0.8, 0.9, 1}
      love.graphics.setColor(color)
      love.graphics.printf(text, bx, by + 8, buttonWidth, "center")
   end

   love.graphics.setColor(1, 1, 1)
end

function settingsscreen.keypressed(key)
   if key == "escape" then
      gamestate.setState("titlescreen")
   end
end

function getButtonX()
   return love.graphics.getWidth() / 2 - buttonWidth / 2
end

function getButtonY(index)
   return love.graphics.getHeight() * 0.50 + (index - 1) * (buttonHeight + buttonSpacing)
end

return settingsscreen