cItemDrops = class()

function cItemDrops:__init()

    self.drops = {}
    self.drop_model = 'prop_money_bag_01'

    self.pickup_timer = Timer()
    self.lookat_drop_net_id = -1

    Keymap:Register("e", "keyboard", "Pick Up Item", function(args)
        if args.down then
            self:TryToPickUpItem()
        end
    end)

    Citizen.CreateThread(function()
        while true do
            Wait(10)
            self:CheckForLookAtDrops()
        end
    end)

    Network:Subscribe("Inventory/DropStackSpawn", self, self.DropStackSpawn)
    Network:Subscribe("Inventory/DropStackSync", self, self.DropStackSync)
    Network:Subscribe("Inventory/DropStackCellSync", self, self.DropStackCellSync)
    Network:Subscribe("Inventory/RemoveDrop", self, self.DropStackRemove)
end

function cItemDrops:DropStackRemove(args)
    self.drops[args.net_id] = nil
end

function cItemDrops:TryToPickUpItem()
    if self.lookat_drop_net_id == -1 then return end
    if self.pickup_timer:GetMilliseconds() < 50 then return end

    local dropped_stack = self.drops[self.lookat_drop_net_id]
    if not dropped_stack then return end

    self.pickup_timer:Restart()
    Network:Send("Inventory/PickUpStack", {
        cell = dropped_stack.cell,
        id = dropped_stack.id
    })
end

function cItemDrops:UpdateLookAtDrop(net_id)

    local drop = self.drops[net_id]
    if not drop then self:HideLookAtIndicator() return end

    Inventory.ui:CallEvent("UpdateLookAtItem",
    {
        name = drop.name,
        amount = drop.amount,
        active = true
    })

    self.lookat_drop_net_id = net_id

    return true
end

function cItemDrops:HideLookAtIndicator()
    if self.lookat_drop_net_id == -1 then return end

    Inventory.ui:CallEvent("UpdateLookAtItem",
    {
        active = false
    })
    self.lookat_drop_net_id = -1
end

function cItemDrops:CheckForLookAtDrops()
    if not Inventory.ui then return end

    local ray = Physics:Raycast(Camera:GetPosition(), Camera:GetPosition() + Camera:GetRotation() * 2.25, -1, LocalPlayer:GetEntityId())

    if ray.hit and ray.entity ~= 0 then
        if not NetworkGetEntityIsNetworked(ray.entity) then self:HideLookAtIndicator() return end

        local net_id = NetworkGetNetworkIdFromEntity(ray.entity)
        if net_id == 0 then self:HideLookAtIndicator() return end

        local out_of_range = Vector3Math:Distance(ray.position, LocalPlayer:GetPosition()) > 2.25

        if (out_of_range or not self:UpdateLookAtDrop(net_id)) then
            self:HideLookAtIndicator()
        end
    else
        self:HideLookAtIndicator()
    end
end

function cItemDrops:DropStackCellSync(args)
    for id, drop in pairs(args) do
        self:DropStackSync(drop)
    end
end

function cItemDrops:DropStackSync(args)
    Citizen.CreateThread(function()
        self.drops[args.net_id] = args

        local ent_id = NetworkGetEntityFromNetworkId(args.net_id)

        local num_tries = 0
        while ent_id <= 0 and num_tries < 10 do
            Wait(500)
            ent_id = NetworkGetEntityFromNetworkId(args.net_id)
            num_tries = num_tries + 1
        end

        local object = ObjectManager:FindObjectByEntityId(ent_id) or Entity(ent_id)

        self.drops[args.net_id].object = object

        -- Disable collision on dropped items
        object:SetEntityNoCollisionEntity(LocalPlayer:GetEntityId(), false)
    end)
end

function cItemDrops:DropStackSpawn(args)
    Object({
        position = args.position,
        rotation = vector3(0, 0, 0),
        model = self.drop_model,
        kinematic = false,
        isNetwork = true,
        callback = function(obj)
            -- obj:PlaceOnGroundProperly()
            obj:SetEntityNoCollisionEntity(LocalPlayer:GetEntityId(), false)
            local force = Camera:GetRotation() * 2.5
            force = vector3(force.x, force.y, 2)
            obj:SetAsPersistent()

            obj:ApplyForce(
                ForceType.MaxForceRot2, 
                force, 
                vector3(0, 0, 0), 
                0, 
                false, 
                true, 
                true)
        end
    })
end

cItemDrops = cItemDrops()