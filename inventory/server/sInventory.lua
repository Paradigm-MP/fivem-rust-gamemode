sInventory = class()

--[[
    General inventory class for players, containers, loot, etc.
]]
function sInventory:__init(args)

    self.id = args.id
    self.num_slots = args.num_slots -- Number of slots in the inventory
    self.contents = args.contents or {} -- Contents of the inventory
    self.type = args.type -- Inventory type

    for i = 0, math.random(4) do
        if self.type == InventoryTypeEnum.Main then
            self.contents[i] = sStack({
                contents = {
                    sItem({
                        name = "rock",
                        amount = 1,
                        stacklimit = 1,
                        durable = true,
                        durability = math.random() * 100,
                        max_durability = 100
                    }),
                }
            })
        else
            self.contents[i] = sStack({
                contents = {
                    sItem({
                        name = "rock",
                        amount = math.random(1000),
                        stacklimit = 1000,
                        durable = false
                    }),
                }
            })
        end
    end

    -- Functionality for admins to spectate any inventory
    self.invsee = {}

    self.players_opened = {} -- [player id]: player, list of players who we should sync this to

    -- All events to interface with this inventory
    self.events = {}

    -- All network events
    self.network_events = {}
    -- table.insert(self.network_events, Network:Subscribe("Inventory/Shift" .. self.id, self, self.ShiftStack))
    -- table.insert(self.network_events, Network:Subscribe("Inventory/Use" .. self.id, self, self.UseItem))
    -- table.insert(self.network_events, Network:Subscribe("Inventory/Drop" .. self.id, self, self.DropStack))
    -- table.insert(self.network_events, Network:Subscribe("Inventory/Split" .. self.id, self, self.SplitStack))
    -- table.insert(self.network_events, Network:Subscribe("Inventory/Swap" .. self.id, self, self.SwapStack))

end

function sInventory:AddPlayerOpened(player)
    self.players_opened[player:GetUniqueId()] = player
end

function sInventory:RemovePlayerOpened(player)
    self.players_opened[player:GetUniqueId()] = nil
end

-- Returns whether a player can do anything on the contents of this inventory
function sInventory:CanPlayerPerformOperations(player)
    if not self.players_opened[player:GetUniqueId()]
    and not self.invsee[player:GetUniqueId()] then 
        return false
    end

    -- TODO: check more things, like load status, health, alive, access, etc

    return true
end

function sInventory:ShiftStack(args, player)

    if not self:CanPlayerPerformOperations(player) then return end
    if not args.index then return end
    if not not self.contents[args.index] then return end

    self.contents[args.index]:Shift()
    self:Sync({index = args.index, stack = self.contents[args.index], sync_stack = true})

end

-- TODO: potentially replace with UseAction or similar to account for all actions on any item
function sInventory:UseItem(args, player)

    if not self:CanPlayerPerformOperations(player) then return end
    if not args.index then return end
    if not self.contents[args.index] then return end
    if not self.contents[args.index]:GetProperty("can_use") then return end

    local copy = self.contents[args.index].contents[1]:Copy()
    copy.amount = 1

    Events:Fire("Inventory/UseItem", 
        {player = self.player, item = copy:GetSyncObject(), index = args.index})

end

function sInventory:FindIndexFromUID(uid)
    
    for index, stack in pairs(self.contents) do
        if stack.uid == uid then
            return index
        end
    end

    return 0
end

function sInventory:DropStack(args, player)

    if not self:CanPlayerPerformOperations(player) then return end

    args.index = self:FindIndexFromUID(args.uid) -- Get new new index from UID

    if not self.contents[args.index] then return end
    if not args.amount or args.amount < 1 then return end

    if not tonumber(tostring(args.amount)) then
        args.amount = 1
    end

    local stack = self.contents[args.index]

    if not stack then return end
    if args.amount > stack:GetAmount() then return end

    if player:InVehicle() then return end

    local dropping_in_stash = false
    local current_lootbox_data = player:GetValue("CurrentLootbox")
    local stash = nil

    if current_lootbox_data then

        local current_lootbox = LootCells.Loot[current_lootbox_data.cell.x][current_lootbox_data.cell.y][current_lootbox_data.uid]

        if current_lootbox and current_lootbox.active and current_lootbox.is_stash then

            stash = current_lootbox.stash
            
            if stash and stash:CanPlayerOpen(player) then
                dropping_in_stash = true
            end
        end
    end

    -- Always will drop the entire stack
    self:RemoveStack({stack = stack:Copy(), index = args.index})
    
    -- TODO: drop on ground or add to other inventory that it was dragged to

end

function sInventory:AddItem(args)
    return self:AddStack({stack = sStack({contents = {args.item}}), index = args.index})
end

function sInventory:ModifyItemCustomDataRemote(args)

    if args.player ~= self.player then
        error(debug.traceback("sInventory:ModifyItemCustomDataRemote failed: player does not match"))
        return
    end

    for index, stack in pairs(self.contents) do

        for _, item in pairs(stack.contents) do

            if item.uid == args.item.uid then

                item.custom_data = args.custom_data
                self:Sync({index = index, stack = stack, sync_stack = true})

                return

            end

        end

    end


end

function sInventory:ModifyDurabilityRemote(args)

    for index, stack in pairs(self.contents) do

        for _, item in pairs(stack.contents) do

            if item.uid == args.item.uid then

                if args.item.durability > 0 then
                    item.durability = args.item.durability
                    self:Sync({index = index, stack = stack, sync_stack = true})
                else
                    self:OnItemBreak(item:Copy())
                    self:RemoveItem({item = item, index = index, remove_by_uid = true})
                end

                return

            end

        end

    end

end

-- Called when an item runs out of durability and breaks
function sInventory:OnItemBreak(item)
    -- Chat:Send(self.player, string.format("%s ran out of durability and broke!", item.name), Color.Red)

    -- Add interactions here when thigns break
end

function sInventory:GetNumOfItem(item_name)

    local item = Items_indexed[item_name]
    if not item then
        print("Failed to sInventory:GetNumOfItem because item was invalid")
        return
    end

    local count = 0
    for index, stack in pairs(self.contents) do
        if stack:GetProperty("name") == item.name then
            count = count + stack:GetAmount()
        end
    end

    return count

end

-- Adds a stack to the inventory, and will try to add it to specified index if possible
-- Will also try to add it to an empty inventory space if new_space is true
-- Syncs automatically
function sInventory:AddStack(args)

    local item_data = Items_indexed[args.stack:GetProperty("name")]
    local max_items_added = args.stack:GetAmount()

    if item_data.max_held then
        -- If you can only hold a certain amount of this item

        local num_of_this_item = self:GetNumOfItem(args.stack:GetProperty("name"))

        max_items_added = math.max(item_data.max_held - num_of_this_item, 0)

        if num_of_this_item >= item_data.max_held then
            Chat:Send(self.player, 
                string.format("You can only hold %d %s at a time!", item_data.max_held, args.stack:GetProperty("name")), Color.Red)
            return args.stack
        end

    end

    -- No items to add
    if max_items_added == 0 then
        return args.stack
    end

    -- Try to stack it in a specific place
    if args.index then

        local istack = self.contents[args.index]

        -- Nothing exists in the slot, so just add it
        if not istack then
            self.contents[args.index] = args.stack
            self:Sync({index = args.index, stack = self.contents[args.index], sync_stack = true})
            return
        end

        if istack
        and (istack:GetProperty("name") ~= args.stack:GetProperty("name")
            or istack:GetAmount() == istack:GetProperty("stacklimit")) then
            return args.stack
        end 

        local return_item = istack:AddItem(args.stack:RemoveItem(nil, 1))

        if return_item then
            args.stack:AddItem(return_item)
        end

        self:Sync({index = args.index, stack = istack, sync_stack = true})

        if args.stack:GetAmount() > 0 then
            -- Chat:Send(self.player, string.format("%s category is full!", cat), Color.Red)
            return args.stack
        else
            return
        end

    end

    -- Loop through stacks and see if we can stack the item(s)
    if not args.new_space then

        for i = 0, self.num_slots - 1 do
            local istack = self.contents[i]

            if istack and i ~= args.avoid_index then

                -- First, try to stack it with existing stacks of the same item
                while args.stack:GetProperty("name") == istack:GetProperty("name")
                and istack:GetAmount() < istack:GetProperty("stacklimit")
                and args.stack:GetAmount() > 0
                and max_items_added > 0 do

                    local return_item = istack:AddItem(args.stack:RemoveItem(nil, 1))
                    max_items_added = max_items_added - 1

                    if return_item then
                        args.stack:AddItem(return_item)
                    end

                    self:Sync({index = i, stack = istack, sync_stack = true})

                end

            end

        end

    end

    -- Still have some left, so check empty spaces now
    while args.stack:GetAmount() > 0 and self:HaveEmptySpaces() and max_items_added > 0 do

        -- TODO: fix this to loop through all spaces instead and find the empty space
        for i = 0, self.num_slots - 1 do
            if args.stack:GetAmount() > 0 and not self.contents[i] then
                self.contents[i] = args.stack:Copy()
                args.stack.contents = {} -- Clear stack contents
                self:Sync({index = i, stack = self.contents[i], sync_stack = true})
                max_items_added = max_items_added - 1
            end
        end
    
    end

    if args.stack:GetAmount() > 0 and max_items_added == 0 then
        return args.stack
    end

    if args.stack:GetAmount() > 0 then
        -- Chat:Send(self.player, string.format("%s category is full!", cat), Color.Red)
        return args.stack
    end

end

-- Returns whether or not there is at least one empty space in the inventory
function sInventory:HaveEmptySpaces()
    return count_table(self.contents) < self.num_slots
end

function sInventory:RemoveStack(args)

    if args.index and not self.contents[args.index] then return end

    if args.index and self.contents[args.index]:GetProperty("name") == args.stack:GetProperty("name") then

        -- If we are not removing the entire stack
        if args.stack:GetAmount() < self.contents[args.index]:GetAmount() then

            local leftover_stack, removed_stack = self.contents[args.index]:RemoveStack(args.stack)

            if leftover_stack and leftover_stack:GetAmount() > 0 then
                print("**Unable to remove some items!**")
                print(string.format("Player: %s [%s]", tostring(self.player:GetUniqueId())))
                print(leftover_stack:ToString())
                print(debug.traceback())
            end

            self:Sync({index = args.index, stack = self.contents[args.index], sync_stack = true})

        else

            -- If we are not removing the last item
            if args.index < count_table(self.contents) then
                -- TODO: fix category sync
                self:Sync({sync_cat = true, cat = cat}) -- Category sync for less network requests
            else
                self.contents[args.index] = nil
                stack = nil
                self:Sync({index = args.index, sync_remove = true})
            end

        end

    else

        -- Remove by stack uid
        for _index, _stack in pairs(self.contents) do

            if _stack.uid == args.stack.uid then
                
                self:CheckIfStackHasOneEquippedThenUnequip(self.contents[_index])

                if _index < count_table(self.contents) then
                    -- TODO: fix this
                    self:Sync({sync_cat = true, cat = cat})
                else
                    self.contents[_index] = nil
                    args.stack = nil
                    self:Sync({index = _index, sync_remove = true})
                end

                break
            end

        end

        if not args.stack then return end

        if args.stack:GetAmount() == 1 then
            -- Only removing one item, so look for uid
            local item = args.stack.contents[1]

            -- Check for matching item uids in stacks
            for index, stack in pairs(self.contents) do

                for item_index, _item in pairs(stack.contents) do

                    if item.uid == _item.uid then
                        
                        stack:RemoveItem(item)
                        args.stack:RemoveItem(item)

                        -- Removed entire stack
                        if stack:GetAmount() == 0 then

                            -- If we are not removing the last item
                            if index < count_table(self.contents) then
                                -- TODO: fix this
                                self:Sync({sync_cat = true, cat = cat}) -- Category sync for less network requests
                            else
                                self.contents[index] = nil
                                stack = nil
                                self:Sync({index = index, sync_remove = true})
                            end

                            return

                        else

                            self.contents[index] = stack
                            self:Sync({index = index, stack = self.contents[index], sync_stack = true})

                        end

                        args.stack = nil

                    end

                end

            end
        end

        if not args.stack then return end

        -- If we are just subtracting items, not by uid or index
        local name = args.stack:GetProperty("name")

        for i, check_stack in pairs(self.contents) do
    
            if check_stack and check_stack:GetProperty("name") == name then

                local return_stack = check_stack:RemoveStack(args.stack)

                if check_stack:GetAmount() == 0 then
                    
                    self:CheckIfStackHasOneEquippedThenUnequip(self.contents[cat][i])

                    if i < count_table(self.contents[cat]) then
                        -- TODO: fix this
                        self:Sync({sync_cat = true, cat = cat})
                    else
                        self.contents[i] = nil
                        self:Sync({index = i, sync_remove = true})
                    end

                end

                -- Got more items to remove, so keep going
                if return_stack and return_stack:GetAmount() > 0 then
                    args.stack = return_stack
                else -- Otherwise break, we are done

                    if self.contents[i] and self.contents[i]:GetAmount() > 0 then
                        self:Sync({index = i, sync_stack = true, stack = self.contents[i]})
                    end

                    args.stack = nil
                    break
                end

            end

        end

    end

end

function sInventory:RemoveItem(args)
    args.stack = sStack({contents = {args.item}})
    self:RemoveStack(args)
end

function sInventory:ModifyStack(stack, index)
    self.contents[index] = stack
    self:Sync({index = index, stack = stack, sync_stack = true})
end

-- Syncs inventory to all players who have it open
-- Specify args.player to sync to one specific player
function sInventory:Sync(args)

    local all_players_to_sync = shallow_copy(self.players_opened)
    for id, player in pairs(self.invsee) do
        all_players_to_sync[id] = player
    end

    local sync_target = args.player or all_players_to_sync

    if args.sync_full then -- Sync entire inventory
        Network:Send("InventoryUpdated", all_players_to_sync,  
            {action = "full", data = self:GetSyncObject()})
    elseif args.sync_stack then -- Sync a single stack
        Network:Send("InventoryUpdated", all_players_to_sync,  
            {action = "update", stack = args.stack:GetSyncObject(), section = self.type, index = args.index})
    elseif args.sync_remove then -- Sync the removal of a stack
        Network:Send("InventoryUpdated", all_players_to_sync,  
            {action = "remove", section = self.type, index = args.index})
    elseif args.sync_swap then -- Syncs the swap of two items
        Network:Send("InventoryUpdated", all_players_to_sync,  
            {action = "swap", section = self.type, from = args.from, to = args.to})
    end

end

function sInventory:Unload()

    self:UpdateDB()

    for k,v in pairs(self.events) do
        Events:Unsubscribe(v)
    end

    for k,v in pairs(self.network_events) do
        Network:Unsubscribe(v)
    end

    self.player = nil
    self.contents = nil
    self.events = nil
    self.network_events = nil
    self = nil

end

-- Use for initial sync AND player:GetValue("Inventory")
function sInventory:GetSyncObject()

    local data = {}

    for k,v in pairs(self.contents) do
        local sync_object = v:GetSyncObject()
        sync_object.index = k
        table.insert(data, sync_object)
    end

    return {contents = data, id = self.id, num_slots = self.num_slots, type = self.type}

end

function splitstr2(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end