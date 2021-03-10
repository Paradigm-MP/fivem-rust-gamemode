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

    self.network_events = 
    {
        Network:Subscribe("InventoryUILoaded-" .. tostring(self.player:GetUniqueId()), self, self.InventoryUILoaded)
    }

end

-- Called when the player's UI finishes loading
function sPlayerInventory:InventoryUILoaded(args)
    
    -- Player does not match this inventory
    if args.player:GetUniqueId() ~= self.player:GetUniqueId() then return end

    self:LoadInventories()

end

-- Sync all player inventories on initial load
function sPlayerInventory:SyncInventories()

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
    for inventory_type, enabled in pairs(self.inventories) do
        if enabled then
            -- Load and sync inventory to player
            self:LoadInventory(inventory_type)
        end
    end
end

function sPlayerInventory:LoadInventory(inventory_type)

    print("sPlayerInventory:LoadInventory " .. tostring(inventory_type))
    local key = string.format("inventory_%s", tostring(inventory_type))

    self.player:GetStoredValue({
        key = key,
        callback = function(contents)
                    
            self.inventories[inventory_type] = sInventory({
                id = sInventoryManager:GetNewInventoryId(),
                contents = contents,
                num_slots = sPlayerInventoryConfig.default_slots[inventory_type],
                type = inventory_type
            })

            self.inventories[inventory_type]:AddPlayerOpened(self.player)
            self.inventories[inventory_type]:Sync({
                sync_full = true,
                player = self.player
            })

            print("Loaded and synced inventory to player")

        end
    })

end