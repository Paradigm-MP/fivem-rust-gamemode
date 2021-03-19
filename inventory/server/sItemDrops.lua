sItemDrops = class()

function sItemDrops:__init()

    self.drops = {}
    self.drop_id_pool = IdPool()
    self.cell_size = 64

    self.drop_timeout = 1000 * 60 * 5 -- Drops expire in 5 minutes or if no one is around

    Events:Subscribe("entityCreated", self, self.EntityCreated)
    Events:Subscribe("ClientModulesLoaded", self, self.ClientModulesLoaded)

end

function sItemDrops:ClientModulesLoaded(args)
    args.player:SetValue("DroppingStacks", {})
end

function sItemDrops:EntityCreated(entity)

    local _source = NetworkGetEntityOwner(entity)
    local player = sPlayers:GetById(_source)
    local _type = GetEntityType(entity)
    local _model = GetEntityModel(entity)

    local dropping_items = player:GetValue("DroppingStacks")
    if count_table(dropping_items) == 0 then return end

    local dropping_item = table.remove(dropping_items, 1)
    local pos = GetEntityCoords(entity)

    if _type == EntityTypeEnum.Object
    and _model == GetHashKey(DroppedItemModel)
    and Vector3Math:Distance(pos, dropping_item.position) < 1 then
        self.drops[dropping_item.id] = {stack = dropping_item.stack, net_id = NetworkGetNetworkIdFromEntity(entity)}

        -- TODO: also sync stack on player enter cell (and reorganize stack layout in self.drops)
        Network:Broadcast("Inventory/DropStackSync", {
            id = dropping_item.id,
            net_id = self.drops[dropping_item.id].net_id,
            name = self.drops[dropping_item.id].stack:GetProperty("name"),
            amount = self.drops[dropping_item.id].stack:GetAmount()
        })
    end

end

-- Called when a player drops a stack of items
--[[
    Called when a player drops a stack of items

    args (in table):
        player: player who is dropping the item
        index: index of the stack to drop 
        section: InventoryTypeEnum of the inventory section it is being dropped from
]]
function sItemDrops:DropStack(args)

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

    local player_pos = args.player:GetPosition()
    local cell = GetCell(player_pos, self.cell_size)
    VerifyCellExists(self.drops, cell)

    local id = self.drop_id_pool:GetNextId()
    local player_dropping = args.player:GetValue("DroppingStacks")
    table.insert(player_dropping, {
        id = id,
        cell = cell,
        stack = stack,
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

sItemDrops = sItemDrops()