local explosions = require("explosions")

local triggers = {
   current = nil,
   timer = 0,
   index = 1,
}

function triggers.set(waves)
   triggers.current = waves
   triggers.timer = 0
   triggers.index = 1
   explosions.clear()
end

function triggers.update(dt)
   if not triggers.current or #triggers.current == 0 then return end

   triggers.timer = triggers.timer + dt

   local wave = triggers.current[triggers.index]
   local waveDelay = wave.Delay or 1

   if triggers.timer >= waveDelay then
      for _, exp in ipairs(wave) do
		if type(exp) == "table" and #exp >= 5 then
		   local x, y, r, g, b = exp[1], exp[2], exp[3], exp[4], exp[5]
		   local setIndex = exp[6] -- optional
		   explosions.spawn(x, y, {r, g, b}, setIndex)
		end
      end

      triggers.index = triggers.index + 1
      if triggers.index > #triggers.current then
         triggers.index = 1
      end

      triggers.timer = 0
   end
end

return triggers