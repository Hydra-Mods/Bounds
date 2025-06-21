local settings = {
   musicVolume = 1.0,
   sfxVolume = 1.0,
   muteMusic = false,
   muteSFX = false,
}

function settings.load()
   if love.filesystem.getInfo("user_settings.lua") then
      local chunk = love.filesystem.load("user_settings.lua")
      local loaded = chunk()
      if type(loaded) == "table" then
         for k, v in pairs(loaded) do
            settings[k] = v
         end
      end
   end
end

function settings.save()
   local data = "return " .. table.serialize(settings)
   love.filesystem.write("user_settings.lua", data)
end

function table.serialize(tbl)
   local str = "{\n"
   for k, v in pairs(tbl) do
      -- Ensure key is a valid string literal
      local key = string.format("[%q]", k)
      local value

      if type(v) == "string" then
         value = string.format("%q", v)
      elseif type(v) == "boolean" or type(v) == "number" then
         value = tostring(v)
      else
         value = "nil" -- fallback
      end

      str = str .. string.format("   %s = %s,\n", key, value)
   end
   return str .. "}"
end

return settings