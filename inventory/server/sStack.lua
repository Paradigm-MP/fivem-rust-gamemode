sStack = class()

function sStack:__init(args)
    if not args.contents or #args.contents == 0 then
        error("sStack:__init failed: contents is empty")
    end

    self.uid = args.uid or UID:GetNew()
    self.contents = args.contents
    
    self:UpdateProperties()
end

function sStack:GetProperty(property)
    return self.properties[property]
end

function sStack:GetAmount()
    return (#self.contents == 0 or not self.contents[1] or self:IsStackable()) and 
        #self.contents or 
        self.contents[1].amount
end

-- Returns if this stack has multiple items with different properties, 
-- like multiple items with durabilities, as opposed to just 500 wood
-- where all the items are the same so it appears as just one item in
-- stack.contents
function sStack:IsStackable()
    return self:GetProperty("durable")
end

function sStack:UpdateProperties()
    self.properties = 
    {
        name = self.contents[1].name,
        amount = self.contents[1].amount,
        stacklimit = self.contents[1].stacklimit,
        durable = self.contents[1].durable,
        durability = self.contents[1].durability,
        max_durability = self.contents[1].max_durability,
        can_equip = self.contents[1].can_equip,
        equip_type = self.contents[1].equip_type
    }
end

function sStack:AddStack(_stack)

    local stack = _stack:Copy()

    if not self:CanStack(stack.contents[1]) then
        error("sStack:AddStack failed: the stack cannot be added to the stack")
    end

    if self:GetAmount() >= self:GetProperty("stacklimit") then
        return stack
    end

    while stack:GetAmount() > 0 and self:GetAmount() < self:GetProperty("stacklimit") do

        if stack:GetAmount() > 1 then
            self:AddItem(stack:Split(1).contents[1])
        else
            self:AddItem(stack.contents[1])
            stack:RemoveItem(stack.contents[1])
        end

    end

    if stack:GetAmount() > 0 then
        return stack
    end

end

-- Adds an item to the stack. Returns any items that could not fit into the stack
function sStack:AddItem(_item)

    local item = _item:Copy()

    if not self:CanStack(item) then
        error("sStack:AddItem failed: the item cannot be added to the stack")
    end

    if self:GetAmount() >= self:GetProperty("stacklimit") then
        return item
    end

    -- Adding an item with durability, which means it is a single item
    if self:IsStackable() or count_table(self.contents) == 0 then
        table.insert(self.contents, item)
    else
        local amount_to_add = math.min(item.amount, self:GetProperty("stacklimit") - self:GetAmount())
        item.amount = item.amount - amount_to_add

        self.contents[1].amount = self.contents[1].amount + amount_to_add

        if item.amount > 0 then
            return item
        end
    end

end

function sStack:RemoveStack(_stack)

    local stack = _stack:Copy()
    local removed_stack = {}

    while stack:GetAmount() > 0 and self:GetAmount() > 0 do
        table.insert(removed_stack, self:RemoveItem(stack:RemoveItem(nil, nil, true)))
    end

    removed_stack = count_table(removed_stack) > 0 and sStack({contents = removed_stack}) or nil

    return stack, removed_stack

end

-- Removes an item from the stack, and returns it if index is specified
function sStack:RemoveItem(_item, index, only_one)

    if index ~= nil then

        if not self.contents[index] then
            error(string.format("sStack:RemoveItem failed: the specified index %s does not exist in the contents", index))
        end

        return table.remove(self.contents, index)
    end

    if only_one then

        if self:IsStackable() then -- If there are durable or equippable items in here
            return table.remove(self.contents, 1)
        else
            local copy = self.contents[1]:Copy()
            copy.amount = 1
            self.contents[1].amount = self.contents[1].amount - 1
            return copy
        end
    end

    local item = _item:Copy()

    if not self:CanStack(item) then
        error("sStack:RemoveItem failed: the item cannot be removed from the stack")
    end

    if item.amount > self:GetAmount() then
        error("sStack:RemoveItem failed: the amount you are trying to remove is greater than the total amount in the stack")
    end

    if not self:IsStackable() then
        self.contents[1].amount = self.contents[1].amount - math.min(item.amount, self:GetAmount())
        item.amount = item.amount - math.min(item.amount, self:GetAmount())
        return item.amount > 0 and item or nil
    else
        -- Remove by uid
        for i = 1, self:GetAmount() do
            if self.contents[i].uid == item.uid then
                return table.remove(self.contents, i)
            end
        end

        -- Otherwise, just remove the first one
        return table.remove(self.contents, 1)
    end

    if item then
        error("sStack:RemoveItem failed: something went wrong and the item failed to remove")
    end

end

-- Shifts the items in the stack
function sStack:Shift()
    table.insert(self.contents, 1, table.remove(self.contents, #self.contents));
end

-- Splits a stack into two stacks based on the amount specified and returns the new stack
function sStack:Split(amount)

    if amount < 1 or amount > self:GetAmount() then return end
    if amount == self:GetAmount() then return self end

    local removed_items = {}

    if count_table(self.contents) > 1 then
        for i = 1, amount do
            table.insert(removed_items, table.remove(self.contents, 1))
        end
    else
        self.contents[1].amount = self.contents[1].amount - amount
        local copy = self.contents[1]:Copy()
        copy.uid = UID:GetNew() -- Regenerate uid
        copy.amount = amount
        table.insert(removed_items, copy)
    end

    return sStack({contents = removed_items})

end

-- Checks if this stack is the exact same as another stack
function sStack:Equals(stack)

    for index, item in ipairs(self.contents) do 
        if not item:Equals(stack[index]) then
            return false
        end
    end

    return true

end

function sStack:Copy()
    return sStack(self)
end

-- Returns whether or not an item can be stacked on this stack
function sStack:CanStack(item)

    return 
        item.name == self:GetProperty("name") and
        item.stacklimit == self:GetProperty("stacklimit") and
        item.durable == self:GetProperty("durable")

end

function sStack:GetSyncObject()

    local data = {contents = {}, uid = self.uid}

    for k,v in pairs(self.contents) do
        data.contents[k] = v:GetSyncObject()
    end

    return data

end

function sStack:ToString()
    local str = "\t"
    for k,v in pairs(self.contents) do
        str = str .. v:ToString() .. "\n\t"
    end
    return str
end