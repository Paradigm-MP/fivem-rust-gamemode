SurvivalHUD = class()

function SurvivalHUD:__init()


    Events:Subscribe("LocalPlayerHealthChanged", self, self.LocalPlayerHealthChanged)
end

function SurvivalHUD:LocalPlayerHealthChanged(args)
    Citizen.CreateThread(function()
        while not Inventory.loaded do
            Wait(100)
        end

        Inventory.ui:CallEvent("Inventory/SurvivalHUD/UpdateHealth", {
            health = args.health / LocalPlayer:GetPed():GetMaxHealth()
        })
    end)
end

SurvivalHUD = SurvivalHUD()