sInventoryManager = class()

--[[
    General manager class for all types of inventories.
]]
function sInventoryManager:__init()

    self.player_inventories = {}

    self.inventory_id_pool = IdPool()

    Events:Subscribe("ClientModulesLoaded", self, self.ClientModulesLoaded)

    Network:Subscribe("Inventory/DragItem", self, self.DragItem)

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