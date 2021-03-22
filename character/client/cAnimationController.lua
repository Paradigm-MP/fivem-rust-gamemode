PedAnimationController = class()

function PedAnimationController:__init()
end

--[[
    Forces a ped to do an animation.

    args (in table):
        same as Ped:PlayAnim, plus:
        ped (Ped): ped to do the animation on
        
    If args.duration == -1, then the animation will resume
    if another animation plays and then finishes.

]]
function PedAnimationController:PlayAnim(args)

    if not args.ped:GetValue("ContinuousAnim") then
        args.ped:SetValue("ContinuousAnim", {active = false})
    end

    if not args.ped:GetValue("CurrentAnim") then
        args.ped:SetValue("CurrentAnim", {active = false})
    end

    local continuous_anim = args.ped:GetValue("ContinuousAnim")
    local current_anim = args.ped:GetValue("CurrentAnim")

    if args.duration == -1 then
        if continuous_anim.active then
            self:StopAnim({
                animDict = continuous_anim.animDict,
                animName = continuous_anim.animName,
                ped = args.ped
            })
            continuous_anim.active = false
        end

        args.ped:PlayAnim(args)
        args.active = true
        args.ped:SetValue("ContinuousAnim", args)

    else
        -- Currently playing another animation, so stop it
        if current_anim.active then
            if args.ped:IsPlayingAnimation(current_anim.animDict, current_anim.animName) then
                args.ped:StopAnim(current_anim)
            end
        end

        args.ped:PlayAnim(args)
        args.active = true
        args.ped:SetValue("CurrentAnim", args)

        -- Replay continuous anim after current anim finishes
        if continuous_anim.active then
            Citizen.CreateThread(function()
                Wait(args.duration or 1000)

                -- If there was another current anim played before this finished
                current_anim = args.ped:GetValue("CurrentAnim")
                if not current_anim.active
                or current_anim.animDict ~= args.animDict
                or current_anim.animName ~= args.animName then return end

                args.ped:SetValue("CurrentAnim", {active = false})

                continuous_anim = args.ped:GetValue("ContinuousAnim")
                if continuous_anim.active then
                    args.ped:PlayAnim(continuous_anim)
                end
            end)
        end
    end
end

--[[
    Stops an animation if it is currently being performed.

    args (in table):
        ped (Ped): ped to stop the animation on
        animDict: animDict to stop
        animName: animName to stop

]]
function PedAnimationController:StopAnim(args)
    local continuous_anim = args.ped:GetValue("ContinuousAnim")
    local current_anim = args.ped:GetValue("CurrentAnim")

    if current_anim.active
    and args.animDict == current_anim.animDict
    and args.animName == current_anim.animName then
        if args.ped:IsPlayingAnimation(args.animDict, args.animName) then
            args.ped:StopAnim(args)
        end
        
        args.ped:SetValue("CurrentAnim", {active = false})
        if continuous_anim.active then
            args.ped:PlayAnim(continuous_anim)
        end
    end

    if continuous_anim.active
    and args.animDict == continuous_anim.animDict
    and args.animName == continuous_anim.animName then
        if args.ped:IsPlayingAnimation(args.animDict, args.animName) then
            args.ped:StopAnim(args)
        end
        args.ped:SetValue("ContinuousAnim", {active = false})
    end
    
end

PedAnimationController = PedAnimationController()