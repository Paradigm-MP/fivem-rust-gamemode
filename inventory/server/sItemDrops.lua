sItemDrops = class()

function sItemDrops:__init()

    self.drops = {} -- [x][y][id] = {...}
    self.drop_id_pool = IdPool()
    self.cell_size = 64
    self.player_cells = {}

    self.drop_timeout = 1000 * 60 * 5 -- Drops expire in 5 minutes or if no one is around

    Events:Subscribe("entityCreated", self, self.EntityCreated)
    Events:Subscribe("ClientModulesLoaded", self, self.ClientModulesLoaded)
    Events:Subscribe("Cells/PlayerCellUpdate" .. tostring(self.cell_size), self, self.PlayerCellUpdate)

    Network:Subscribe("Inventory/PickUpStack", self, self.PickUpStack)

end

function sItemDrops:PickUpStack(args)
    if not args.cell 
    or not args.cell.x
    or not args.cell.y
    or not args.id then return end

    if not self.drops[args.cell.x]
    or not self.drops[args.cell.x][args.cell.y] then return end

    local drop = self.drops[args.cell.x][args.cell.y][args.id]
    if not drop then return end

    if not drop.entity:Exists() then return end
    if Vector3Math:Distance(drop.entity:GetPosition(), args.player:GetPosition()) > 3 then return end

    local player_inventory = args.player:GetValue("Inventory")
    if not player_inventory then return end

    local stack = drop.stack
    self:RemoveDrop(args.cell, args.id)

    local return_stack = player_inventory:AddStack({stack = stack})
    if return_stack and return_stack:GetAmount() > 0 then
        self:DropStack({
            player = args.player,
            stack = return_stack
        })
    end
end

-- Syncs to all players in the given cell or in adjacent cells
function sItemDrops:SyncToAdjacentPlayers(cell, args)
    local adjacent_players = {}

    local adjacent_cells = GetAdjacentCells(cell)

    for _, adj_cell in pairs(adjacent_cells) do
        if self.player_cells[adj_cell.x]
        and self.player_cells[adj_cell.x][adj_cell.y] then
            for id, player in pairs(self.player_cells[adj_cell.x][adj_cell.y]) do
                adjacent_players[id] = player
            end
        end
    end

    Network:Send("Inventory/DropStackSync", adjacent_players, args)

end

function sItemDrops:RemoveFromCellTableIfExists(cell_table, cell, id)
    if cell_table[cell.x] 
    and cell_table[cell.x][cell.y] then
        cell_table[cell.x][cell.y][id] = nil

        if count_table(cell_table[cell.x][cell.y]) == 0 then
            cell_table[cell.x][cell.y] = nil

            if count_table(cell_table[cell.x]) == 0 then
                cell_table[cell.x] = nil
            end
        end
    end
end

function sItemDrops:RemoveDrop(cell, id)

    -- Delete entity if it exists
    if self.drops[cell.x] 
    and self.drops[cell.x][cell.y]
    and self.drops[cell.x][cell.y][id] then
        if self.drops[cell.x][cell.y][id].entity:Exists() then
            Network:Broadcast("Inventory/RemoveDrop", {net_id = self.drops[cell.x][cell.y][id].entity:GetNetworkId()})
            self.drops[cell.x][cell.y][id].entity:Remove()
        end
    end

    self:RemoveFromCellTableIfExists(self.drops, cell, id)
end

function sItemDrops:PlayerCellUpdate(args)
    self:RemoveFromCellTableIfExists(self.player_cells, args.old_cell, args.player:GetUniqueId())

    VerifyCellExists(self.player_cells, args.cell)
    self.player_cells[args.cell.x][args.cell.y][args.player:GetUniqueId()] = args.player

    local drops_to_sync = {}
    
    -- Sync all nearby drops to player
    for _, cell in pairs(args.updated) do
        if self.drops[cell.x]
        and self.drops[cell.x][cell.y] then
            for id, drop in pairs(self.drops[cell.x][cell.y]) do
                drops_to_sync[id] = {
                    id = id,
                    net_id = drop.entity:GetNetworkId(),
                    name = drop.stack:GetProperty("name"),
                    amount = drop.stack:GetAmount(),
                    cell = cell
                }
            end
        end
    end

    Network:Send("Inventory/DropStackCellSync", args.player, drops_to_sync)

end

function sItemDrops:ClientModulesLoaded(args)
    args.player:SetValue("DroppingStacks", {})
end

function sItemDrops:EntityCreated(entity_id)

    local entity = Entity(entity_id)
    local player = sPlayers:GetById(entity:GetNetworkOwner())

    local dropping_items = player:GetValue("DroppingStacks")
    if count_table(dropping_items) == 0 then return end

    local dropping_item = table.remove(dropping_items, 1)
    local pos = entity:GetPosition()
    local cell = GetCell(pos, self.cell_size)

    if entity:GetType() == EntityTypeEnum.Object
    and entity:GetModel() == GetHashKey(DroppedItemModel)
    and Vector3Math:Distance(pos, dropping_item.position) < 1 then
        local dropping_stack = 
        {
            stack = dropping_item.stack, 
            entity = entity
        }

        VerifyCellExists(self.drops, cell)
        self.drops[cell.x][cell.y][dropping_item.id] = dropping_stack

        -- Sync to players in nearby cells
        self:SyncToAdjacentPlayers(cell, {
            id = dropping_item.id,
            net_id = dropping_stack.entity:GetNetworkId(),
            name = dropping_stack.stack:GetProperty("name"),
            amount = dropping_stack.stack:GetAmount(),
            cell = cell
        })

        Citizen.CreateThread(function()
            Wait(self.drop_timeout)
            self:RemoveDrop(cell, dropping_item.id)
        end)
    end

end

--[[
    Called when a player drops a stack of items.

    args (in table):
        player: player who is dropping the item
        stack: stack of items to drop
]]
function sItemDrops:DropStack(args)

    -- TODO: find nearby drops of the same type and combine them, if possible.
    -- ex. two drops of 200 wood should be combined to 1 drop of 400 wood
    if not args.stack or not args.player then return end

    local player_pos = args.player:GetPosition()
    local cell = GetCell(player_pos, self.cell_size)

    local id = self.drop_id_pool:GetNextId()
    local player_dropping = args.player:GetValue("DroppingStacks")
    table.insert(player_dropping, {
        id = id,
        cell = cell,
        stack = args.stack,
        position = player_pos
    })
    args.player:SetValue("DroppingStacks", player_dropping)

    -- Allow the player to spawn the entity through anticheat
    Anticheat:AllowPlayerEntitySpawn({
        player = args.player, 
        model = DroppedItemModel,
        type = EntityTypeEnum.Object
    })

    Network:Send("Inventory/DropStackSpawn", args.player, {position = player_pos})

end

--[[
    Called when a player drops a stack of items

    args (in table):
        player: player who is dropping the item
        index: index of the stack to drop 
        section: InventoryTypeEnum of the inventory section it is being dropped from
]]
function sItemDrops:PlayerDropStack(args)

    local player_inventory = args.player:GetValue("Inventory")
    if not player_inventory then return end

    local from_inventory = player_inventory.inventories[args.section]
    if not from_inventory then return end
    if from_inventory.type == InventoryTypeEnum.ItemInfo then return end

    local stack = from_inventory.contents[args.index]
    if not stack then return end

    -- Remove stack from inventory
    from_inventory.contents[args.index] = nil
    from_inventory:Sync({sync_remove = true, index = args.index})

    self:DropStack({
        player = args.player,
        stack = stack
    })
    
    player_inventory:UpdateEquippedItem()
end

sItemDrops = sItemDrops()