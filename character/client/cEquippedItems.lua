cEquippedItems = class()

-- General class manager for equipped items that aren't guns
function cEquippedItems:__init()

    -- List of players and equipped items
    self.equipped_items = {}

    Events:Subscribe("PlayerNetworkValueChanged", self, self.PlayerNetworkValueChanged)

    Citizen.CreateThread(function()
        while true do
            Wait(1000)
            self:CheckForEquippedItemVisuals()
        end
    end)

end

function cEquippedItems:PlayerNetworkValueChanged(args)
    Citizen.CreateThread(function()
        Wait(10)
        -- Wait for SetValue to finish, then do this
        if args.name == "EquippedItem" then
            local visuals = self.equipped_items[args.player:GetUniqueId()]
            if visuals then
                visuals:Update()
            else
                self:CheckPlayerVisuals(args.player, args.player:GetPed())
            end
        end
    end)
end

function cEquippedItems:CheckForEquippedItemVisuals()

    for id, visuals in pairs(self.equipped_items) do
        if not visuals.ped:Exists() then
            visuals:Remove()
            self.equipped_items[id] = nil
        else
            visuals:Update()
        end
    end

    local players = cPlayers:GetPlayers()
    for id, player in pairs(players) do
        if not self.equipped_items[id] then
            local ped = player:GetPed()
            if ped:Exists() then
                self:CheckPlayerVisuals(player, ped)
            end
        end
    end
end

function cEquippedItems:CheckPlayerVisuals(player, ped)
    local equipped_item_name = player:GetValue("EquippedItem")
    if equipped_item_name then
        self.equipped_items[player:GetUniqueId()] = PlayerVisuals(player)
    end
end

cEquippedItems = cEquippedItems()