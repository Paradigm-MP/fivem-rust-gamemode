sItem = class()

function sItem:__init(args)

    if 
    not args or 
    not args.name or 
    not args.amount or 
    args.amount < 1
    then
        error(debug.traceback("sItem:__init failed: missing a key piece of information"))
    end

    local default_data = deepcopy(Items_indexed[args.name])
    if not default_data then
        error(debug.traceback("sItem:__init failed: could not find default data for " .. args.name))
    end

    self.uid = args.uid or UID:GetNew()
    self.name = args.name
    self.amount = args.amount
    self.can_equip = args.can_equip or default_data.can_equip -- Determines if it can go in the Character inventory section
    self.equip_type = args.equip_type or default_data.equip_type -- Type of equipped item in the Character section
    self.stacklimit = args.stacklimit or default_data.stacklimit
    self.durable = args.durable or default_data.durable
    self.attributes = args.attributes and shallow_copy(args.attributes) or default_data.attributes
    self.actions = args.actions and shallow_copy(args.actions) or default_data.actions
    self.custom_data = args.custom_data and shallow_copy(args.custom_data) or {}

    if self.can_equip and not self.equip_type then
        error(debug.traceback("sItem:__init failed: can_equip was true but no equip_type was given for " .. self.name))
    end

    if self.amount > self.stacklimit then
        error(debug.traceback("sItem:__init failed: amount was greater than stack limit"))
    end

    self:GetCustomData()

    if self.durable then

        if self.amount > 1 then
            error(debug.traceback("sItem:__init failed: durability was given but item had more than one amount"))
        end

        self.max_durability = args.max_durability or default_data.max_durability
        self.durability = math.floor(args.durability or self.max_durability)

    end

end

-- Gets custom data if there is any
function sItem:GetCustomData()

	-- Additional custom data will be added here

end

function sItem:Equals(item)

    return
        self.name == item.name and
        self.amount == item.amount and
        self.stacklimit == item.stacklimit and
        self.durable == item.durable and
        self.durability == item.durability and
        self:EqualsCustomData(item)

end

function sItem:EqualsCustomData(item)

    for property, data in ipairs(self.custom_data) do 
        if self.custom_data[property] ~= item.custom_data[property] then
            return false
        end
    end

    return true

end

-- Returns a copy of this item
function sItem:Copy()
    return sItem(self)
end

function sItem:GetSyncObject()

    return {
        uid = self.uid,
        name = self.name,
        amount = self.amount,
        stacklimit = self.stacklimit,
        durable = self.durable,
        durability = self.durability,
        max_durability = self.max_durability,
        actions = self.actions,
        attributes = self.attributes,
        custom_data = self.custom_data
    }

end

function sItem:ToString()

    local msg = self.name .. " [x" .. self.amount .. "] "
    .. "SL: " .. self.stacklimit .. " Dura: " .. tostring(self.durability) .. "/" .. tostring(self.max_durability)

    if count_table(self.custom_data) > 0 then
        msg = msg .. " "
        for key, value in pairs(self.custom_data) do
            msg = msg .. tostring(key) .. ": " .. tostring(value) .. " "
        end
    end

    return msg

end