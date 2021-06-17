MeleeActionRock = class()

function MeleeActionRock:__init(ped, cb)
    self.active = false
    self.name = "rock"
    self.ped = ped
    self.definition = MeleeActionDefinitions:Get(self.name)
    self.callback = cb
end

function MeleeActionRock:StopDetecting()
    self.active = false
end

function MeleeActionRock:StopAnim()
    PedAnimationController:StopAnim({
        animDict = self.definition.animDict,
        animName = self.definition.animName,
        ped = self.ped
    })
end

function MeleeActionRock:PlayAnim()
    PedAnimationController:PlayAnim({
        animDict = self.definition.animDict,
        animName = self.definition.animName,
        flag = self.definition.animFlag,
        animTime = self.definition.animTime,
        duration = self.definition.duration,
        ped = self.ped
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
        Wait(self.definition.duration)
        if self.callback then self.callback() end
        if not self.active then return end
        self:StopAnim()
        self:StopDetecting()
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
                scale = 1
            })
        elseif obj:GetValue("ResourceType") == ResourceType.Stone then
            local pfx = ParticleEffect({
                bank = "core",
                effect = "ent_dst_concrete_large",
                type = ParticleEffectTypes.Position,
                position = ray.position,
                scale = 1
            })
        elseif obj:GetValue("ResourceType") == ResourceType.Metal then
            local pfx = ParticleEffect({
                bank = "core",
                effect = "ent_dst_concrete_large", -- Ideally use ent_dst_metal_frag, but it doesn't have any sound
                type = ParticleEffectTypes.Position,
                position = ray.position,
                scale = 1
            })
        elseif obj:GetValue("ResourceType") == ResourceType.Barrel then
            local pfx = ParticleEffect({
                bank = "core",
                effect = "ent_dst_concrete_large", -- Ideally use ent_dst_metal_frag, but it doesn't have any sound
                type = ParticleEffectTypes.Position,
                position = ray.position,
                scale = 1
            })
        end

        self:StopDetecting()

        Network:Send("Character/HitResource", {
            id = obj:GetValue("ResourceId"),
            type = obj:GetValue("ResourceType"),
            cell = obj:GetValue("Cell"),
            hit_position = {x = ray.position.x, y = ray.position.y, z = ray.position.z}
        })

    end

end