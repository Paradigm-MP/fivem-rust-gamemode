sPlayerInventory = class()

function sPlayerInventory:__init(player)

    self.player = player

    -- Player inventories
    -- Adjust true/false to toggle loading of that inventory type
    -- True/false will be replaced with actual inventory instance on load
    self.inventories =
    {
        [InventoryTypeEnum.Main] = true,
        [InventoryTypeEnum.Hotbar] = true,
        [InventoryTypeEnum.Character] = true
    }

    self:LoadInventories()

end

function sPlayerInventory:SaveInventory(inventory_type)
    
    local key = string.format("inventory_%s", tostring(inventory_type))

    local contents = self.inventories[inventory_type]:GetSyncObject()

    self.player:StoreValue({
        key = key,
        value = json.encode(contents, {indent = true}),
        callback = function()
            print("Finished sPlayerInventory:SaveInventory")
        end
    })
end

function sPlayerInventory:LoadInventories()
    print("Start sPlayerInventory:LoadInventories")

    for inventory_type, enabled in pairs(self.inventories) do
        if enabled then
            self.inventories[inventory_type] = self:LoadInventory(inventory_type)
        end
    end

    print("Finished sPlayerInventory:LoadInventories")
end

function sPlayerInventory:LoadInventory(inventory_type)

    local key = string.format("inventory_%s", tostring(inventory_type))

    -- TODO: investigate if async is better
    local contents = self.player:GetStoredValue({
        key = key,
        synchronous = true
    })

    return sInventory({
        id = sInventoryManager:GetNewInventoryId(),
        contents = contents or {},
        num_slots = sPlayerInventoryConfig.default_slots[inventory_type]
    })

end