cInventory = class()

function cInventory:__init()

    Events:Subscribe("Loadingscreen/Ready", self, self.LoadingscreenReady)

end

function cInventory:LoadingscreenReady()
    Events:Fire("Loadingscreen/Add", {
        name = "inventory_ui",
        callback = function()

            Events:Fire("Loadingscreen/Update", {
                name = "Inventory"
            })

            self.ui = UI:Create({
                name = "inventory", 
                path = "inventory/client/ui/index.html",
                visible = false
            })

            self.ui:SendToBack()
            self.ui:Subscribe("Ready", self, self.UIReady)

        end
    })
end

function cInventory:UIReady()

    Citizen.CreateThread(function()

        Wait(1000)

        Events:Fire("Loadingscreen/Remove", {
            name = "inventory_ui"
        })

        self.ui:Show()

        UI:SetCursor(true)
        UI:SetFocus(true)

    end)

    -- TODO: Bring UI to front once loaded fully, after loadscreen ends
end



Inventory = cInventory()