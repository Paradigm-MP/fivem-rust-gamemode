cResourceManager = class()

function cResourceManager:__init()

    self.resources = {}

    for resource_type, _ in pairs(ResourceData) do
        self.resources[resource_type] = {}
    end

    -- Events:Subscribe('Loadingscreen/Ready', self, self.LoadingScreenReady)
    Network:Subscribe('ResourceManager/SyncCells', self, self.SyncCells)

end

function cResourceManager:SyncCells(args)
    for x, _ in pairs(args) do
        for y, _ in pairs(args[x]) do
            local cell = {x = x, y = y}
            VerifyCellExists(self.resources, cell)

            self.resources[cell.x][cell.y] = args[x][y]

            for _, resource in pairs(args[x][y]) do
                CreateModelHide(resource.posX, resource.posY, resource.posZ, 0.1, GetHashKey(resource.model), false)

                if resource.health > 0 then
                    resource.object = Object({
                        model = resource.model,
                        position = vector3(resource.posX, resource.posY, resource.posZ),
                        quaternion = quat(resource.rotW, resource.rotX, resource.rotY, resource.rotZ),
                        -- kinematic = true,
                        isNetwork = false
                    })
                end
            end
        end
    end
end

cResourceManager = cResourceManager()