sResourceManager = class()

function sResourceManager:__init()

    -- Resources on a per-cell basis
    self.resources = {}
    self.resource_id_pool = IdPool()

    -- Cell size for all resource streaming
    self.cell_size = 64

    Events:Subscribe('ModulesLoaded', self, self.ModulesLoaded)
    Events:Subscribe('Cells/PlayerCellUpdate' .. tostring(self.cell_size), self, self.PlayerCellUpdate)

    Network:Subscribe("Character/HitResource", self, self.CharacterHitResource)

end

function sResourceManager:GetResourceYield(resource_type, health)
    return math.ceil(
        math.min(health, math.random(ResourceYieldBounds[resource_type].min, ResourceYieldBounds[resource_type].max)))
end

function sResourceManager:CharacterHitResource(args)
    if not args.id
    or not args.type
    or not args.cell
    or not args.cell.x
    or not args.cell.y then return end

    VerifyCellExists(self.resources, args.cell)
    local resource = self.resources[args.cell.x][args.cell.y][args.id]

    if not resource then return end
    if resource.health <= 0 then return end
    if resource.type ~= args.type then return end

    local equipped_item_name = args.player:GetValue("EquippedItem")
    if not equipped_item_name then return end

    local player_pos = args.player:GetPosition()
    local resource_pos = vector3(resource.posX, resource.posY, resource.posZ)

    if Vector3Math:Distance(player_pos, resource_pos) > 5 then return end
    
    -- Barrel resources are handled separately
    if resource.type == ResourceType.Barrel then
        args.resource = resource
        self:CharacterHitBarrel(args)
        return 
    end

    local yield = math.ceil(self:GetResourceYield(resource.type, resource.health) * (1 - ResourceCompleteBonus))

    -- TODO: check player tool and check player cooldown (cannot harvest too quickly)
    -- TODO: damage player tool

    resource.health = math.max(0, resource.health - yield)
    self.resources[args.cell.x][args.cell.y][resource.id] = resource

    -- Resource was destroyed
    if resource.health <= resource.max_health * ResourceCompleteBonus then
        -- Remove resource and respawn later
        Network:Broadcast("ResourceManager/SyncDestroyed", {
            cell = {x = args.cell.x, y = args.cell.y},
            id = resource.id
        })

        yield = yield + math.ceil(resource.max_health * ResourceCompleteBonus)
        
        self.resources[args.cell.x][args.cell.y][resource.id] = nil
        -- TODO: respawn later
    end

    local item_yield = math.max(1, math.ceil(yield * RustConfig.ResourceGatherMultiplier))

    if resource.type == ResourceType.Wood then

        local inventory = args.player:GetValue("Inventory")
        local item = sItem({
            name = "wood",
            amount = item_yield
        })
        inventory:GiveItem({
            item = item
        })


        local nearby_players = sItemDrops:GetNearbyPlayers(args.cell)
        nearby_players[args.player:GetUniqueId()] = nil -- Do not send to this player
        Network:Send("Resources/ParticleEffect", nearby_players, {
            bank = "core",
            effect = "bul_wood_splinter",
            position = args.hit_position,
            scale = 1
        })

    elseif resource.type == ResourceType.Stone then
        
        local inventory = args.player:GetValue("Inventory")
        local item = sItem({
            name = "stone",
            amount = item_yield
        })
        inventory:GiveItem({
            item = item
        })

        local nearby_players = sItemDrops:GetNearbyPlayers(args.cell)
        nearby_players[args.player:GetUniqueId()] = nil -- Do not send to this player
        Network:Send("Resources/ParticleEffect", nearby_players, {
            bank = "core",
            effect = "ent_dst_concrete_large",
            position = args.hit_position,
            scale = 1
        })
        
    elseif resource.type == ResourceType.Metal then
        
        local inventory = args.player:GetValue("Inventory")
        local item = sItem({
            name = "metal_fragments",
            amount = item_yield
        })
        inventory:GiveItem({
            item = item
        })

        local nearby_players = sItemDrops:GetNearbyPlayers(args.cell)
        nearby_players[args.player:GetUniqueId()] = nil -- Do not send to this player
        Network:Send("Resources/ParticleEffect", nearby_players, {
            bank = "core",
            effect = "liquid_splash_gloopy",
            position = args.hit_position,
            scale = 1
        })
    end

end

function sResourceManager:CharacterHitBarrel(args)
     
    local equipped_item_name = args.player:GetValue("EquippedItem")
    if not equipped_item_name then return end

    local damage = GetWeaponBarrelDamage(equipped_item_name)
    
    if damage == 0 then return end
    
    args.resource.health = math.max(0, args.resource.health - damage)
    self.resources[args.cell.x][args.cell.y][args.resource.id] = args.resource

    -- Barrel was destroyed
    if args.resource.health == 0 then
        -- Remove resource and respawn later
        Network:Broadcast("ResourceManager/SyncDestroyed", {
            cell = {x = args.cell.x, y = args.cell.y},
            id = args.resource.id
        })

        self.resources[args.cell.x][args.cell.y][args.resource.id] = nil
        -- TODO: respawn later
        
        args.resource.position = vector3(args.resource.posX, args.resource.posY, args.resource.posZ)
        Events:Fire("ResourceManager/BarrelDestroyed", args)
    end

    
end

function sResourceManager:ModulesLoaded()

    -- Generate cell data if it does not exist
    local path = string.format("./resources/%s/resources/server/resource_data/generated.txt", GetCurrentResourceName())
    if not fs_exists(path) then
        Citizen.CreateThread(function()
            Wait(3000)
            print(string.format("%s\n-------------------------------------------------\n%s", Colors.Console.Yellow, Colors.Console.Default))
            print(string.format("%sGenerated cell data does not exist. Generating now.%s", Colors.Console.Yellow, Colors.Console.Default))
            print(string.format("%sThis is a normal step when running the server for the first time.%s", Colors.Console.Yellow, Colors.Console.Default))
            print(string.format("%sThis will take a few minutes. Please keep the server open until it completes.%s", Colors.Console.Yellow, Colors.Console.Default))
            print(string.format("%sTo regenerate cell data later, delete %sgenerated.txt%s in resource_data.%s", Colors.Console.Yellow, Colors.Console.LightBlue, Colors.Console.Yellow, Colors.Console.Default))
            print(string.format("%s\n-------------------------------------------------\n%s", Colors.Console.Yellow, Colors.Console.Default))
            Wait(10000)
            print(string.format("%sBeginning cell generation process...%s", Colors.Console.Yellow, Colors.Console.Default))
            Wait(2000)
            self:GenerateCellFiles(self.cell_size)
        end)
    end
end

--[[
    old_cell = current_cell,
    old_adjacent = old_adjacent,
    cell = cell,
    adjacent = new_adjacent,
    updated = updated
]]
function sResourceManager:PlayerCellUpdate(args)

    Citizen.CreateThread(function()

        local resources = {}
        
        -- Get all resources in updated calls and send to player
        for _, cell in pairs(args.updated) do

            if not self.resources[cell.x] or not self.resources[cell.x][cell.y] then
                -- Cell has not been loaded in, so load it
                VerifyCellExists(self.resources, cell)
                self:LoadCellResources(cell)
                Wait(1)
            end

            VerifyCellExists(resources, cell)
            resources[cell.x][cell.y] = self.resources[cell.x][cell.y]

        end

        Network:Send('ResourceManager/SyncCells', args.player, resources)
    end)
end

function sResourceManager:LoadCellResources(cell)
    local data = JsonUtils:LoadJSON(string.format("resources/server/resource_data/cells/%d_%d_%d.json", self.cell_size, cell.x, cell.y))
    if data then

        local indexed_data = {}

        -- All resources start at 100% health
        for _, resource in pairs(data) do
            resource.id = self.resource_id_pool:GetNextId()
            resource.type = GetResourceTypeFromModel(resource.model)
            if not resource.type then
                error("Failed to get resource type for " .. tostring(resource.model))
            end
            resource.no_spawn = NoSpawnResources[resource.model]
            resource.max_health = GetResourceAmountFromSize(resource.type, GetResourceData(resource.model, resource.type).size or 0)
            resource.health = resource.max_health
            indexed_data[resource.id] = resource
        end

        self.resources[cell.x][cell.y] = indexed_data
    end
end


-----------------------------------------------------------------
--[[
    Below this are cell generation functions
    You shouldn't need to use these unless you want to
    modify cell sizes or change default map objects into
    resources that can be collected.

    This function generates all the cell json seen in
    resource_data/cells using the raw data in 
    resource_data/raw

    To add more raw data, use codewalker to search for the object using World
    Search and export it.

    This shouldn't be used often

    Cell size is a number from shCells - 64, 128, 256, 512, 1024

]]
function sResourceManager:GenerateCellFiles(cell_size)

    local t = Timer()

    -- Only used for json cell generation
    self.raw_resources = {}

    for resource_type, _ in pairs(ResourceData) do
        self.raw_resources[resource_type] = {}
    end

    self:LoadAllResourcesFromFile(function()
        Citizen.CreateThread(function()
            -- [X][Y] = list of resources in the cell
            local cell_resources = {}

            for resource_type, _ in pairs(self.raw_resources) do
                local total_resources = 0
                for resource_name, resource_data in pairs(self.raw_resources[resource_type]) do
                    local total = count_table(resource_data)
                    local actual = 0
                    local resource_hashes = {} -- Hash by position to check for duplicates
                    print(string.format("Parsing %d resources in %s/%s...", total, resource_type, resource_name))
                    for _, resource in pairs(resource_data) do
                        local pos = vector3(tonumber(resource.PositionX), tonumber(resource.PositionY), tonumber(resource.PositionZ))
                        local cell = GetCell(pos, cell_size)

                        -- rot is 7 decimals, pos is 4 decimals
                        VerifyCellExists(cell_resources, cell)

                        local key = tostring(pos)
                        if not resource_hashes[key] then
                            resource_hashes[key] = true
                            table.insert(cell_resources[cell.x][cell.y], {
                                model = resource.ArchetypeName,
                                posX = tonumber(resource.PositionX),
                                posY = tonumber(resource.PositionY),
                                posZ = tonumber(resource.PositionZ),
                                rotX = tonumber(resource.RotationX),
                                rotY = tonumber(resource.RotationY),
                                rotZ = tonumber(resource.RotationZ),
                                rotW = tonumber(resource.RotationW)
                            })
                            actual = actual + 1
                        end

                        if _ % 1000 == 0 then
                            Wait(1)
                            print(string.format("Parsed %d/%d (actual: %d) in %s/%s", _, total, actual, resource_type, resource_name))
                        end
                    end

                    total_resources = total_resources + actual
                    print(string.format("Finished parsing %d resources in %s/%s", actual, resource_type, resource_name))
                end

                print(string.format("Parsed %d %s (real count)", total_resources, resource_type))
            end

            print(string.format("Finished parsing data. Writing to files now..."))

            Wait(1000)

            for x, _ in pairs(cell_resources) do
                for y, _ in pairs(cell_resources[x]) do
                    JsonUtils:SaveJSON(cell_resources[x][y], string.format("resources/server/resource_data/cells/%d_%d_%d.json", cell_size, x, y))
                    print(string.format("Wrote %d_%d_%d.json", cell_size, x, y))
                end
                Wait(1)
            end

            SaveResourceFile(GetCurrentResourceName(), "resources/server/resource_data/generated.txt", 
                string.format("Generated on %s\nDeleting this file will regenerate cell data on next server restart", os.date("%Y-%m-%d %H-%M-%S")))

            print(string.format("Finished writing cells to files in %.2f seconds.", t:GetSeconds()))

        end)
    end)

end

function sResourceManager:LoadAllResourcesFromFile(callback)

    Citizen.CreateThread(function()
        self:LoadResourcesFromFile(ResourceType.Wood)
        self:LoadResourcesFromFile(ResourceType.Stone)
        self:LoadResourcesFromFile(ResourceType.Metal)
        self:LoadResourcesFromFile(ResourceType.Barrel)

        if callback then callback() end
    end)
end

function sResourceManager:LoadResourcesFromFile(resource_type)

    print(string.format("[resources] Loading all %s from file...", resource_type))
    local processed_resource_files = 0
    local total_resource_files = count_table(ResourceData[resource_type])

    for resource_name, resource_data in pairs(ResourceData[resource_type]) do
        processed_resource_files = processed_resource_files + 1
        local data = CSV:Parse(string.format("resources/server/resource_data/raw/%s/Entities_%s.txt", resource_type, resource_name), 10)
        self.raw_resources[resource_type][resource_name] = data
        
        if processed_resource_files % 10 == 0 then
            print(string.format("[resources] Loaded %s [%d/%d]",
                resource_type, processed_resource_files, total_resource_files))
        end
        Wait(10)
    end

    print(string.format("[resources] Finished loading all %s (%d/%d) from file.", resource_type, processed_resource_files, total_resource_files))
end

sResourceManager = sResourceManager()