MeleeActionRock = class()

function MeleeActionRock:__init(ped)
    self.active = false
    self.name = "rock"
    self.ped = ped
    self.definition = MeleeActionDefinitions:Get(self.name)
end

function MeleeActionRock:StopDetecting()
    self.active = false
end

function MeleeActionRock:StopAnim()
    self.ped:StopAnim({
        animDict = self.definition.animDict,
        animName = self.definition.animName
    })
end

function MeleeActionRock:PlayAnim()
    self.ped:PlayAnim({
        animDict = self.definition.animDict,
        animName = self.definition.animName,
        flag = self.definition.animFlag,
        animTime = self.definition.animTime
    })
end

function MeleeActionRock:DetectHits()
    self.active = true

    Citizen.CreateThread(function()
        while self.active do
            self:DetectHitFrame()
            Wait(1)
        end
    end)

    Citizen.CreateThread(function()
        Wait(1000 * self.definition.duration)
        if not self.active then return end
        self:StopDetecting()
        self:StopAnim()
    end)
end

function MeleeActionRock:DetectHitFrame()
    local bone = PedBoneEnum.RightHand
    local start_ray_pos = self.ped:GetPedBonePositionPerformance(bone)

    local bone_rot = Vector3Math:RotationToDirection(self.ped:GetBoneRotation(bone))
    local end_ray_pos = start_ray_pos + bone_rot * self.definition.tool_length

    local ray = Physics:Raycast(start_ray_pos, end_ray_pos, nil, LocalPlayer:GetPed():GetEntityId())

    if ray.hit and ray.entity then
        self:HitSomething(ray)
    end

end

function MeleeActionRock:HitSomething(ray)

    local obj = ObjectManager:FindObjectByEntityId(ray.entity)
    if obj and obj:GetValue("IsResource") then
        
        if obj:GetValue("ResourceType") == ResourceType.Wood then
            local pfx = ParticleEffect({
                bank = "core",
                effect = "bul_wood_splinter",
                type = ParticleEffectTypes.Position,
                position = ray.position,
                scale = 1,
                rotation = vector3(0, 0, 0)
            })
        else
            local pfx = ParticleEffect({
                bank = "core",
                effect = "ent_dst_concrete_large",
                type = ParticleEffectTypes.Position,
                position = ray.position,
                scale = 1,
                rotation = vector3(0, 0, 0)
            })
        end

        self:StopDetecting()
        self:StopAnim()

        -- TODO: sync particles so other players can see and hear them
        Network:Send("Character/HitResource", {
            id = obj:GetValue("ResourceId"),
            type = obj:GetValue("ResourceType"),
            cell = obj:GetValue("Cell")
        })

    end

end