local audio = {
	music = nil,
	sounds = {},
	volume = {
		music = 1.0,
		sfx = 1.0,
	},
	muted = {
		music = false,
		sfx = false
	}
}

local settings = require("settings")

local musicTracks = {
	"01 - Interstellar",
	"02 - Plasma Storm",
	"03 - Temple of Madness",
	"04 - Horsehead Nebula",
	"05 - Forgotten Station",
	"06 - Hope on the Horizon",
	"07 - Electric Firework",
	"08 - Synth Kobra",
	"09 - Spiral of Plasma",
}

local function clamp(val, min, max)
	return math.max(min, math.min(max, val))
end

function audio.load()
	-- Load settings into audio state
	audio.volume.music = clamp(settings.musicVolume or 1.0, 0, 1)
	audio.volume.sfx = settings.sfxVolume or 1.0
	audio.muted.music = settings.muteMusic or false
	audio.muted.sfx = settings.muteSFX or false

	-- Pick a random track
	local randomTrackName = musicTracks[math.random(1, #musicTracks)]
	local trackPath = "Assets/Audio/" .. randomTrackName .. ".ogg"

	-- Load and configure music
	audio.music = love.audio.newSource(trackPath, "stream")
	audio.music:setLooping(true)

	local scaledVol = audio.muted.music and 0 or (audio.volume.music * 0.25)
	audio.music:setVolume(scaledVol)

	-- Load sounds
	audio.sounds["Click"] = love.audio.newSource("Assets/Audio/Click.wav", "static")
	audio.sounds["checkpoint"] = love.audio.newSource("Assets/Audio/beep.mp3", "static")

	-- Apply initial SFX volume
	for _, sfx in pairs(audio.sounds) do
		local sfxVol = audio.muted.sfx and 0 or audio.volume.sfx
		sfx:setVolume(sfxVol)
	end
end

function audio.playMusic()
	if audio.music and not audio.music:isPlaying() then
		audio.music:play()
	end
end

function audio.stopMusic()
	if audio.music then
		audio.music:stop()
	end
end

function audio.duckMusic()
	if audio.music and not audio.muted.music then
		audio.music:setVolume(audio.volume.music * 0.25 * 0.25)
	end
end

function audio.restoreMusic()
	if audio.music and not audio.muted.music then
		audio.music:setVolume(audio.volume.music * 0.25)
	end
end

function audio.setMusicVolume(vol)
	audio.volume.music = clamp(vol, 0, 1)
	settings.musicVolume = audio.volume.music
	local scaledVol = audio.muted.music and 0 or (audio.volume.music * 0.25)
	if audio.music then
		audio.music:setVolume(scaledVol)
	end
end

function audio.setSFXVolume(vol)
	audio.volume.sfx = vol
	settings.sfxVolume = vol
	for _, sfx in pairs(audio.sounds) do
		local actualVol = audio.muted.sfx and 0 or vol
		sfx:setVolume(actualVol)
	end
end

function audio.toggleMuteMusic()
	audio.muted.music = not audio.muted.music
	settings.muteMusic = audio.muted.music
	audio.setMusicVolume(audio.volume.music)
end

function audio.toggleMuteSFX()
	audio.muted.sfx = not audio.muted.sfx
	settings.muteSFX = audio.muted.sfx
	audio.setSFXVolume(audio.volume.sfx)
end

function audio.playSFX(name)
	local sfx = audio.sounds[name]
	if sfx and not audio.muted.sfx then
		sfx:stop()
		sfx:setVolume(audio.volume.sfx)
		sfx:play()
	end
end

return audio