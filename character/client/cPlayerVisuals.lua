PlayerVisuals = class()

function PlayerVisuals:__init(player)
    self.player = player
    self.ped = self.player:GetPed()
    self.equipped_item_name = self.player:GetValue("EquippedItem")
    self:Create()
end

function PlayerVisuals:Create()
    local visual_data = PlayerVisualsList:Get(self.equipped_item_name)
    if not visual_data then return end

    self.object = Object({
        model = visual_data.model,
        position = self.ped:GetPosition(),
        kinematic = true,
        isNetwork = false,
        callback = function(object)
            object:AttachToEntity({
                entity = self.ped,
                bone_enum = visual_data.bone,
                position = visual_data.offset,
                rotation = visual_data.rotation,
                collision = true,
                isPed = true,
                fixedRot = true
            })
        end
    })

    -- Play idle animation if it exists
    if visual_data.idle and LocalPlayer:IsPlayer(self.player) then
        local anim_copy = shallow_copy(visual_data.idle)
        anim_copy.ped = self.ped
        PedAnimationController:PlayAnim(anim_copy)
    end
end

-- Check for new updates to equipped visuals
function PlayerVisuals:Update()
    local equipped_item_name = self.player:GetValue("EquippedItem")
    if equipped_item_name ~= self.equipped_item_name then
        self:Remove()
        self.equipped_item_name = equipped_item_name
        self:Create()
    end
end

function PlayerVisuals:Remove()
    if self.object and self.object:Exists() then
        self.object:Destroy()
    end
    
    local visual_data = PlayerVisualsList:Get(self.equipped_item_name)
    if visual_data and visual_data.idle and LocalPlayer:IsPlayer(self.player) then
        local anim_copy = shallow_copy(visual_data.idle)
        anim_copy.ped = self.ped
        PedAnimationController:StopAnim(anim_copy)
    end
end