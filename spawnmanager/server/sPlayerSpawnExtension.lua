
--[[
    Spawns/respawns a player

    args (in table):
        position (vector3): position to spawn the player at
        model (string): model string for the player to have
]]

function Player:Spawn(args)

    -- Allow the player to spawn through anticheat
    self:SetValue("AllowedSpawnArgs", {
        position = args.position,
        model = args.model
    })

    -- Tell the player to spawn
    Network:Send("Player/Spawn", self, {
        position = args.position,
        model = args.model
    })

end