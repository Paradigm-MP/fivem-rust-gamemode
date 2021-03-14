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

    -- If they have a lootbox open, it will be in self.inventories

    self.network_events = 
    {
        Network:Subscribe("InventoryUILoaded-" .. tostring(self.player:GetUniqueId()), self, self.InventoryUILoaded)
    }

end

function sPlayerInventory:AddItem(args)
    return self:AddStack({stack = sStack({contents = {args.item}}), index = args.index})
end

function sPlayerInventory:AddStack(args)
    local return_stack = self.inventories[InventoryTypeEnum.Main]:AddStack(args)

    if return_stack and return_stack:GetAmount() > 0 then
        return_stack = self.inventories[InventoryTypeEnum.Hotbar]:AddStack(args)

        if return_stack and return_stack:GetAmount() > 0 then
            return return_stack
        end
    end
end

function sPlayerInventory:DragItem(args)
    -- Invalid args
    if not args.from_section
    or not args.from_slot
    or not args.to_section
    or not args.to_slot then return end

    local from_inventory = self.inventories[args.from_section]
    local to_inventory = self.inventories[args.to_section]

    -- Inventory does not exist
    if not from_inventory
    or not to_inventory then return end

    -- Neither slot in the inventories has an item in it
    if not from_inventory.contents[args.from_slot]
    and not to_inventory.contents[args.to_slot] then return end

    -- Invalid slot index
    if args.from_slot > from_inventory.num_slots
    or args.from_slot < 0
    or args.to_slot > to_inventory.num_slots
    or args.to_slot < 0 then return end

    if from_inventory.id == to_inventory.id then
        -- Dragging within an inventory
        local from_item = from_inventory.contents[args.from_slot]
        from_inventory.contents[args.from_slot] = from_inventory.contents[args.to_slot]
        from_inventory.contents[args.to_slot] = from_item

        from_inventory:Sync({
            sync_swap = true,
            from = args.from_slot,
            to = args.to_slot
        })
    else
        -- Dragging from one inventory to another
        local from_item = from_inventory.contents[args.from_slot]
        from_inventory.contents[args.from_slot] = to_inventory.contents[args.to_slot]
        to_inventory.contents[args.to_slot] = from_item

        -- If the item exists, sync it, otherwise remove it
        if from_inventory.contents[args.from_slot] then
            from_inventory:Sync({
                sync_stack = true,
                index = args.from_slot,
                stack = from_inventory.contents[args.from_slot]
            })
        else
            from_inventory:Sync({
                sync_remove = true,
                index = args.from_slot
            })
        end

        -- If the item exists, sync it, otherwise remove it
        if to_inventory.contents[args.to_slot] then
            to_inventory:Sync({
                sync_stack = true,
                index = args.to_slot,
                stack = to_inventory.contents[args.to_slot]
            })
        else
            to_inventory:Sync({
                sync_remove = true,
                index = args.to_slot
            })
        end
    end
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