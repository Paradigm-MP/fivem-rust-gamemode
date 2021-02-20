Trees = class()

function Trees:__init()

    self.marker = Marker({
        type = MarkerTypes.DebugSphere,
        position = vector3(0,0,0),
        direction = vector3(0,0,0),
        rotation = vector3(0,0,0),
        scale = vector3(0.1,0.1,0.1),
        color = Colors.Red
    })

    Events:Subscribe("Render", self, self.TreeCheck)

    -- Events:Subscribe('Loadingscreen/Ready', self, self.LoadingScreenReady)

end

function Trees:TreeCheck()
    local ray = Physics:Raycast(Camera:GetPosition(), Camera:GetPosition() + Camera:GetRotation() * 100, nil, LocalPlayer:GetPed():GetEntity())
    -- output_table(ray)

    self.marker.position = ray.position

    if ray.entity ~= 0 
    and DoesEntityExist(ray.entity)
    and ObjectManager:FindObjectByEntityId(ray.entity) == nil then

        -- GetEntityModel fails on CBuildings

        SetEntityAsMissionEntity(ray.entity, true, true)
        DeleteEntity(ray.entity)
        Wait(1)
    end
end

Trees = Trees()