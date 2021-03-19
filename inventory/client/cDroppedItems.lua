cItemDrops = class()

function cItemDrops:__init()

    self.drops = {}
    self.drop_model = 'prop_money_bag_01'

    Network:Subscribe("Inventory/DropStackSpawn", self, self.DropStackSpawn)
    Network:Subscribe("Inventory/DropStackSync", self, self.DropStackSync)
end

function cItemDrops:DropStackSync(args)
    self.drops[args.id] = args
    self.drops[args.id].object = ObjectManager:FindObjectByEntityId(NetworkGetEntityFromNetworkId(args.net_id))
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