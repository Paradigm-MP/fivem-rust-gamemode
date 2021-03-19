sInventoryManager = class()

--[[
    General manager class for all types of inventories.
]]
function sInventoryManager:__init()

    self.player_inventories = {}

    self.inventory_id_pool = IdPool()

    Events:Subscribe("ClientModulesLoaded", self, self.ClientModulesLoaded)

    Network:Subscribe("Inventory/DragItem", self, self.DragItem)
    Network:Subscribe("Inventory/SplitStack", self, self.SplitStack)
    Network:Subscribe("Inventory/DropStack", self, self.DropStack)
    Network:Subscribe("Inventory/SelectHotbar", self, self.SelectHotbar)

end

function sInventoryManager:DropStack(args)
    sItemDrops:PlayerDropStack(args)
end

function sInventoryManager:SelectHotbar(args)
    local player_inventory = args.player:GetValue("Inventory")
    if not player_inventory then return end
    player_inventory:SelectHotbar(args)
end

function sInventoryManager:SplitStack(args)
    local player_inventory = args.player:GetValue("Inventory")
    if not player_inventory then return end
    player_inventory:SplitStack(args)
end

function sInventoryManager:DragItem(args)
    local player_inventory = args.player:GetValue("Inventory")
    if not player_inventory then return end
    player_inventory:DragItem(args)
end

function sInventoryManager:ClientModulesLoaded(args)
    local player_inventory = sPlayerInventory(args.player)
    args.player:SetValue("Inventory", player_inventory)

end

function sInventoryManager:GetNewInventoryId()
    return self.inventory_id_pool:GetNextId()
end

sInventoryManager = sInventoryManager()