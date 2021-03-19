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
    if not drop then return end

    Inventory.ui:CallEvent("UpdateLookAtItem",
    {
        name = drop.name,
        amount = drop.amount,
        active = true
    })

    self.lookat_drop_net_id = net_id

    return true
end

function cItemDrops:CheckForLookAtDrops()
    if not Inventory.ui then return end

    local ray = Physics:Raycast(Camera:GetPosition(), Camera:GetPosition() + Camera:GetRotation() * 2.25, -1, LocalPlayer:GetEntityId())

    if ray.hit and ray.entity ~= 0 then
        if not NetworkGetEntityIsNetworked(ray.entity) then return end

        local net_id = NetworkGetNetworkIdFromEntity(ray.entity)
        if net_id == 0 then return end

        local out_of_range = Vector3Math:Distance(ray.position, LocalPlayer:GetPosition()) > 2.25

        if (out_of_range or not self:UpdateLookAtDrop(net_id)) and net_id ~= self.lookat_drop_net_id then
            Inventory.ui:CallEvent("UpdateLookAtItem",
            {
                active = false
            })
            self.lookat_drop_net_id = -1
        end
    elseif not ray.hit and self.lookat_drop_net_id > -1 then
        Inventory.ui:CallEvent("UpdateLookAtItem",
        {
            active = false
        })
        self.lookat_drop_net_id = -1
    end
end

function cItemDrops:DropStackSync(args)
    self.drops[args.net_id] = args
    self.drops[args.net_id].object = ObjectManager:FindObjectByEntityId(NetworkGetEntityFromNetworkId(args.net_id))

    -- Disable collision on dropped items
    self.drops[args.net_id].object:SetEntityNoCollisionEntity(LocalPlayer:GetEntityId(), false)
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