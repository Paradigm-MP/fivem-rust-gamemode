HUDDefaults = class()

function HUDDefaults:__init()
    Events:Subscribe("Render", self, self.Render)
end

function HUDDefaults:Render()
    -- TODO: call this once there is a custom inventory set up to change weapons
    -- because it disables the weapon wheel
    -- HUD:HideHudAndRadarThisFrame()
end

HUDDefaults = HUDDefaults()