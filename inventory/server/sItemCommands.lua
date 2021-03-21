if IsTest then
    sItemCommands = class()

    function sItemCommands:__init()

        Events:Subscribe("ChatCommand", self, self.ChatCommand)
    end

    function sItemCommands:ChatCommand(args)
        local words = split(args.text, " ")
        if words[1] == "/item" and words[2] then
            local name = words[2]
            local amount = words[3] and tonumber(words[3]) or 1

            local item_data = Items_indexed[name]
            if not Items_indexed[name] then return end

            -- Only add 1 durable/equippable item at a time
            if item_data.durable or item_data.can_equip then
                amount = 1
            end

            local inventory = args.player:GetValue("Inventory")
            local item = sItem({
                name = name,
                amount = amount
            })
            
            inventory:GiveItem({
                item = item,
                no_drop = true
            })
        end
    end

    sItemCommands = sItemCommands()
end