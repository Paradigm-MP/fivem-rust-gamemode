Anticheat = class()

function Anticheat:__init()

    Network:Subscribe('anticheat/cheating', function(args) self:Cheating(args) end)

    Events:Subscribe("entityCreating", self, self.EntityCreating)
    Events:Subscribe("respawnPlayerPedEvent", self, self.RespawnPlayerPedEvent)
    Events:Subscribe("ClientModulesLoaded", self, self.ClientModulesLoaded)

end

-- Called when a player spawns/respawns
function Anticheat:RespawnPlayerPedEvent(player_id, content)

    -- Check if a player is allowed to respawn and if they respawned with the correct data
    local player = sPlayers:GetById(player_id)
    -- Player does not exist
    if not player then
        DropPlayer(player_id, "Spawning failed. Please try again later.")
        -- TODO: print player info on kick / log to discord
        return
    end

    local spawn_args = player:GetValue("AllowedSpawnArgs")
    -- Player is not allowed to spawn
    if not spawn_args then
        DropPlayer(player_id, "Spawning failed. Please try again later.")
        return
    end

    -- Player spawned too far from their spawn point
    if Vector3Math:Distance(vector3(content.posX, content.posY, content.posZ), spawn_args.position) > 2 then
        DropPlayer(player_id, "Spawning failed. Please try again later.")
        return
    end

    -- Invalid player model
    -- Disabled for now because hashes do not seem to match
    -- if GetEntityModel(player:GetPed()) ~= GetHashKey(spawn_args.model) then
    --     DropPlayer(player_id, "Spawning failed. Please try again later.")
    --     return
    -- end

    -- Player is already spawned
    if player:GetValue("Spawned") then
        DropPlayer(player_id, "Spawning failed. Please try again later.")
        return
    end

    -- Clear spawn args after spawning
    player:SetValue("AllowedSpawnArgs", nil)
    player:SetValue("Spawned", true)
end

--[[
    Allows a player to spawn a specific type of entity with a model.

    args (in table):
        player: (Player) player who is to be allowed
        type: (EntityTypeEnum) type of entity to allow spawning
        model: (string) string of model to allow spawning 

]]
function Anticheat:AllowPlayerEntitySpawn(args)
    local allowed_entity_spawns = args.player:GetValue("AllowedEntitySpawns")
    if not allowed_entity_spawns then return end
    args.model = GetHashKey(args.model)

    if allowed_entity_spawns[args.type][args.model] then
        allowed_entity_spawns[args.type][args.model] = allowed_entity_spawns[args.type][args.model] + 1
    else
        allowed_entity_spawns[args.type][args.model] = 1
    end

    args.player:SetValue("AllowedEntitySpawns", allowed_entity_spawns)
end

--[[
    Finishes allowing a player to spawn a specific type of entity with a model.
    Call this after the player has finished spawning the object.

    args (in table):
        player: (Player) player who is to be allowed
        type: (EntityTypeEnum) type of entity to allow spawning
        model: (string) string of model to allow spawning 

]]
function Anticheat:FinishPlayerEntitySpawn(args)
    local allowed_entity_spawns = args.player:GetValue("AllowedEntitySpawns")
    if not allowed_entity_spawns 
    or not allowed_entity_spawns[args.type]
    or not allowed_entity_spawns[args.type][args.model] then return end

    allowed_entity_spawns[args.type][args.model] = allowed_entity_spawns[args.type][args.model] - 1

    if allowed_entity_spawns[args.type][args.model] <= 0 then
        allowed_entity_spawns[args.type][args.model] = nil
    end

    args.player:SetValue("AllowedEntitySpawns", allowed_entity_spawns)
end

--[[
    Checks if a player is allowed to spawn a specific type of entity with a model.

    args (in table):
        player: (Player) player who is to be allowed
        type: (EntityTypeEnum) type of entity to allow spawning
        model: (string) string of model to allow spawning 

]]
function Anticheat:CanPlayerEntitySpawn(args)
    local allowed_entity_spawns = args.player:GetValue("AllowedEntitySpawns")
    if not allowed_entity_spawns then return false end
    return allowed_entity_spawns and allowed_entity_spawns[args.type] and allowed_entity_spawns[args.type][args.model] ~= nil
end

function Anticheat:ClientModulesLoaded(args)
    local entity_spawns = 
    {
        [EntityTypeEnum.Ped] = {},
        [EntityTypeEnum.Vehicle] = {},
        [EntityTypeEnum.Object] = {},
    }

    args.player:SetValue("AllowedEntitySpawns", entity_spawns)
end

function Anticheat:EntityCreating(entity_id)
    -- Potentially replace with NetworkGetFirstEntityOwner https://github.com/citizenfx/fivem/pull/669
    local entity = Entity(entity_id)
    local _player = sPlayers:GetById(entity:GetNetworkOwner())
    local _type = entity:GetType()
    local _model = entity:GetModel()

    -- No associated player found
    if not _player then
        CancelEvent()
        return
    end

    -- Player is not allowed to spawn this
    if not self:CanPlayerEntitySpawn({player = _player, type = _type, model = _model}) then
        CancelEvent()
        return
    end

    -- Fire event for all other modules to handle the event
    local return_values = Events:Fire("EntityCreating", {entity = entity, player = _player, type = _type, model = _model})

    -- If any event returned false, then cancel the entity creation
    for _, return_value in pairs(return_values) do
        if return_value == false then
            CancelEvent()
            break
        end
    end

    -- Finish the spawn
    self:FinishPlayerEntitySpawn({player = _player, type = _type, model = _model})

end

function Anticheat:Cheating(args)
    print(args.player:GetName() .. " was cheating for: " .. args.reason)
    args.player:Kick("Big brother is watching...")
end

Anticheat = Anticheat()