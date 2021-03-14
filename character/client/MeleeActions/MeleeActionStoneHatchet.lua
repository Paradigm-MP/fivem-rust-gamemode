MeleeActionStoneHatchet = class()

function MeleeActionStoneHatchet:__init(ped)
    self.active = false
    self.ped = ped
end

function MeleeActionStoneHatchet:StopDetecting()
    self.active = false
end

function MeleeActionStoneHatchet:DetectHits()
    self.active = true

    Citizen.CreateThread(function()
        while self.active do
            self:DetectHitFrame()
            Wait(1)
        end
    end)
end

function MeleeActionStoneHatchet:DetectHitFrame()
    local bone = PedBoneEnum.RightHand
    local start_ray_pos = self.ped:GetPedBonePositionPerformance(bone)

    local bone_rot = Vector3Math:RotationToDirection(self.ped:GetBoneRotation(bone))
    local end_ray_pos = start_ray_pos + bone_rot * 0.5

    -- local forward_ray = Physics:Raycast(Camera:GetPosition(), Camera:GetPosition() + Camera:GetRotation() * 100, nil, LocalPlayer:GetPed():GetEntity())
    -- Render:DrawText(
    --     Render:WorldToScreen(forward_ray.position), 
    --     Vector3Math:Distance(forward_ray.position, Camera:GetPosition()), 
    --     Colors.Red, 1, 
    --     true)

    local ray = Physics:Raycast(start_ray_pos, end_ray_pos, nil, LocalPlayer:GetPed():GetEntity())

    if ray.hit and ray.entity then
        self:HitSomething(ray)
    end

end

function MeleeActionStoneHatchet:HitSomething(ray)

    local obj = ObjectManager:FindObjectByEntityId(ray.entity)
    if obj and obj:GetValue("IsResource") then
        
        self.ped:StopAnim({
            animDict = "anim@melee@machete@streamed_core@",
            animName = "plyr_walking_attack_a"
        })

        local pfx = ParticleEffect({
            bank = "core",
            effect = "bul_wood_splinter",
            type = ParticleEffectTypes.Position,
            position = ray.position,
            scale = 1,
            rotation = vector3(0, 0, 0)
        })

        self.active = false

        Network:Send("Character/HitResource", {
            id = obj:GetValue("ResourceId"),
            type = obj:GetValue("ResourceType"),
            cell = obj:GetValue("Cell")
        })

    end

end