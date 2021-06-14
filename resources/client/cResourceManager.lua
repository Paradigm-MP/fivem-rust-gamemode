cResourceManager = class()

function cResourceManager:__init()

    self.resources = {}

    Network:Subscribe('ResourceManager/SyncCells', self, self.SyncCells)
    Network:Subscribe('ResourceManager/SyncDestroyed', self, self.SyncDestroyed)
    Network:Subscribe('Resources/ParticleEffect', self, self.ParticleEffect)
    
end

function cResourceManager:ParticleEffect(args)
    ParticleEffect({
        bank = args.bank,
        effect = args.effect,
        type = ParticleEffectTypes.Position,
        position = args.position,
        scale = args.scale
    })
end

function cResourceManager:SyncDestroyed(args)
    if self.resources[args.cell.x]
    and self.resources[args.cell.x][args.cell.y]
    and self.resources[args.cell.x][args.cell.y][args.id] then
        local object = self.resources[args.cell.x][args.cell.y][args.id].object
        if not object then return end
        object:Destroy()
        self.resources[args.cell.x][args.cell.y][args.id].object = nil
    end
end

function cResourceManager:SyncCells(args)
    for x, _ in pairs(args) do
        for y, _ in pairs(args[x]) do
            local cell = {x = x, y = y}
            VerifyCellExists(self.resources, cell)

            for _, resource in pairs(args[x][y]) do

                if self.resources[cell.x][cell.y][resource.id]
                and self.resources[cell.x][cell.y][resource.id].object then
                    self.resources[cell.x][cell.y][resource.id].object:Remove()
                    self.resources[cell.x][cell.y][resource.id] = nil
                end

                CreateModelHide(resource.posX, resource.posY, resource.posZ, 0.1, GetHashKey(resource.model), false)
                resource.cell = cell
                self.resources[cell.x][cell.y][resource.id] = resource

                if resource.health > 0 and not resource.no_spawn then
                    resource.object = Object({
                        model = resource.model,
                        position = vector3(resource.posX, resource.posY, resource.posZ),
                        quaternion = quat(resource.rotW, resource.rotX, resource.rotY, resource.rotZ),
                        kinematic = true,
                        isNetwork = false
                    })

                    resource.object:SetValue("IsResource", true)
                    resource.object:SetValue("ResourceId", resource.id)
                    resource.object:SetValue("ResourceType", resource.type)
                    resource.object:SetValue("Cell", cell)
                end
            end
        end
    end
end

cResourceManager = cResourceManager()