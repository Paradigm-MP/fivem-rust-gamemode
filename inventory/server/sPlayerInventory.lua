sPlayerInventory = class()

function sPlayerInventory:__init(player)

    self.player = player
    self.action_timer = Timer()

    -- Player inventories
    -- Adjust true/false to toggle loading of that inventory type
    -- True/false will be replaced with actual inventory instance on load
    self.inventories =
    {
        [InventoryTypeEnum.Main] = true,
        [InventoryTypeEnum.Hotbar] = true,
        [InventoryTypeEnum.Character] = true
    }

    self.hotbar_index = -1

    -- If they have a lootbox open, it will be in self.inventories

    self.network_events = 
    {
        Network:Subscribe("InventoryUILoaded-" .. tostring(self.player:GetUniqueId()), self, self.InventoryUILoaded)
    }

end

--[[
    Gives an item to a player. If the player cannot hold it, the
    item will drop on the ground.

    Use argument no_drop = true to prevent the item from going on ground.
    It will simply not be added if there is no room.

]]
function sPlayerInventory:GiveItem(args)
    self:GiveStack({stack = sStack({contents = {args.item}}), index = args.index, player = args.player})
end

--[[
    Gives an stack to a player. If the player cannot hold it, the
    stack will drop on the ground.

    Use argument no_drop = true to prevent the stack from going on ground.
    It will simply not be added if there is no room.

]]
function sPlayerInventory:GiveStack(args)
    local return_stack = self:AddStack(args)

    if return_stack and args.no_drop ~= true then
        sItemDrops:DropStack({
            player = self.player,
            stack = return_stack
        })
    end
end

function sPlayerInventory:DoAction(args)
    -- Only can do one action per second
    if self.action_timer:GetSeconds() < 1 then return end
    self.action_timer:Restart()

    if not args.index
    or not args.section
    or not args.amount
    or args.amount < 1
    or not args.action then return end

    args.amount = math.ceil(args.amount)

    local inventory = self.inventories[args.section]
    if not inventory then return end

    local stack = inventory.contents[args.index]
    if not stack then return end
    if args.amount > stack:GetAmount() then return end

    local first_item = stack.contents[1]

    -- If the action is not drop (all items have that action), then check if it has the action requested
    if args.action ~= "drop" and not first_item.actions[args.action] then return end

    -- Amount of items to work on
    local total_amount = stack:GetAmount()
    local split_stack = stack:Split(args.amount)
    if not split_stack then return end

    if split_stack:GetAmount() == total_amount then
        stack = nil
    end

    -- Now perform the action, letting another module handle it
    -- A module can return false to remove the stack (split), or
    -- return a stack to replace the existing stack with it
    -- For example, eating an item would remove the top item of the stack
    -- and return the modified stack
    local return_table = Events:Fire("Inventory/DoAction", {
        player = args.player,
        action = args.action,
        amount = amount,
        stack = split_stack
    })

    -- Event was not handled, so don't do anything
    if count_table(return_table) == 0 then return end

    -- After handling, get the return stack as either nil or a stack
    local return_stack = return_table[1] ~= false and return_table[1] or stack
    if return_table[1] ~= false and return_table[1] ~= nil and stack then
        return_stack = stack:AddStack(return_table[1])
    end

    inventory.contents[args.index] = return_stack

    -- Sync based on if the stack was removed or modified
    if not return_stack then
        inventory:Sync({sync_remove = true, index = args.index})
    else
        inventory:Sync({sync_stack = true, index = args.index, stack = return_stack})
    end

end

function sPlayerInventory:SelectHotbar(args)
    if not args.index then return end
    if args.index < -1 or args.index > 5 then return end

    self.hotbar_index = args.index

    -- TODO: equip/unequip item based on index

    -- Small stone
    -- proc_mntn_stone01
    if self.hotbar_index == -1 then
        args.player:SetNetworkValue("EquippedItem", nil)
    else
        local stack = self.inventories[InventoryTypeEnum.Hotbar].contents[self.hotbar_index]

        if stack then
            args.player:SetNetworkValue("EquippedItem", stack:GetProperty("name"))
        end
    end
end

function sPlayerInventory:AddItem(args)
    return self:AddStack({stack = sStack({contents = {args.item}}), index = args.index})
end

function sPlayerInventory:AddStack(args)
    local return_stack = self.inventories[InventoryTypeEnum.Hotbar]:AddStack(args)

    if return_stack and return_stack:GetAmount() > 0 then
        return_stack = self.inventories[InventoryTypeEnum.Main]:AddStack(args)

        if return_stack and return_stack:GetAmount() > 0 then
            return return_stack
        end
    end
end

function sPlayerInventory:SplitStack(args)
    if not args.to_section
    or not args.base_section
    or not args.index
    or not args.base_index
    or not args.amount then return end
    if args.to_section ~= InventoryTypeEnum.Main and args.to_section ~= InventoryTypeEnum.Hotbar then return end
    if args.amount < 1 then return end

    local base_inventory = self.inventories[args.base_section]
    local to_inventory = self.inventories[args.to_section]

    if not base_inventory
    or not to_inventory then return end

    local base_stack = base_inventory.contents[args.base_index]
    local to_stack = to_inventory.contents[args.index]

    if not base_stack
    or to_stack then return end

    if args.amount >= base_stack:GetAmount() then return end

    local split_stack = base_stack:Split(args.amount)
    base_inventory.contents[args.base_index] = base_stack
    base_inventory:Sync({index = args.base_index, stack = base_stack, sync_stack = true})

    local return_stack = to_inventory:AddStack({
        stack = split_stack,
        index = args.index
    })

    if return_stack then
        base_inventory:AddStack({stack = return_stack})
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

    local from_stack = from_inventory.contents[args.from_slot]
    local to_stack = to_inventory.contents[args.to_slot]

    -- Trying to drag a non-equippable item to the character section
    if to_inventory.type == InventoryTypeEnum.Character
    and not from_stack:GetProperty("can_equip") then return end

    -- Dragging same type of items on top of each other - try to combine them
    if from_stack and to_stack 
    and from_stack:GetProperty("name") == to_stack:GetProperty("name") then

        local from_stack_amount = from_stack:GetAmount()
        local return_stack = to_stack:AddStack(from_stack)

        -- Combined at least one item in the stacks, so don't swap and just return after syncing
        if not return_stack or return_stack:GetAmount() ~= from_stack_amount then

            from_inventory.contents[args.from_slot] = return_stack
            to_inventory.contents[args.to_slot] = to_stack

            if not return_stack then
                from_inventory:Sync({
                    sync_remove = true,
                    index = args.from_slot
                })
            else
                from_inventory:Sync({
                    sync_stack = true,
                    index = args.from_slot,
                    stack = from_inventory.contents[args.from_slot]
                })    
            end

            to_inventory:Sync({
                sync_stack = true,
                index = args.to_slot,
                stack = to_inventory.contents[args.to_slot]
            })

            return
        end

    end

    -- Swapping two items in inventories
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

        end
    })

end