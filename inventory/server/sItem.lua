sItem = class()

function sItem:__init(args)

    if 
    not args or 
    not args.name or 
    not args.amount or 
    args.amount < 1 or
    not args.stacklimit 
    then
        error(debug.traceback("sItem:__init failed: missing a key piece of information"))
    end

    self.uid = args.uid or UID:GetNew()
    self.name = args.name
    self.amount = args.amount
    self.stacklimit = args.stacklimit
    self.durable = args.durable
    self.custom_data = args.custom_data or {}

    self:GetCustomData()

    if args.durability then

        if args.amount > 1 then
            error(debug.traceback("sItem:__init failed: durability was given but item had more than one amount"))
        end

        self.durability = math.floor(args.durability)

        if args.max_durability then
            self.max_durability = args.max_durability
        else
            error(debug.traceback("sItem:__init failed: max_durability was not given when an item had durability"))
        end
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