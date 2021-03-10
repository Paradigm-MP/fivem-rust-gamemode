cInventory = class()

function cInventory:__init()

    self.open = false
    self.player_inventories_loaded = 0
    self.total_player_inventories = 3

    self.restricted_actions = 
    {
        [Control.LookLeftRight] = true,
        [Control.LookUpDown] = true,
        [Control.LookUpOnly] = true,
        [Control.LookDownOnly] = true,
        [Control.LookLeftOnly] = true,
        [Control.LookRightOnly] = true,
        [Control.LookBehind] = true,
        [Control.VehicleLookBehind] = true,
        [Control.LookLeft] = true,
        [Control.LookRight] = true,
        [Control.LookUp] = true,
        [Control.LookDown] = true,
        [Control.VehicleLookLeft] = true,
        [Control.VehicleLookRight] = true,
        [Control.VehicleDriveLook] = true,
        [Control.VehicleDriveLook2] = true
    }

    Keymap:Register("tab", "keyboard", "Inventory", function(args)
        if args.down then
            self:ToggleOpen()
        end
    end)

    Events:Subscribe("Loadingscreen/Ready", self, self.LoadingscreenReady)
    Events:Subscribe("onResourceStop", self, self.onResourceStop)

    Network:Subscribe("InventoryUpdated", self, self.InventoryUpdated)

end

function cInventory:IsOpen()
    return self.open
end

function cInventory:RestrictActionsWhileInventoryOpen(restricted)
    for control, _ in pairs(self.restricted_actions) do
        LocalPlayer:RestrictAction(control, restricted)
    end
end

function cInventory:ToggleOpen()
    self.open = not self.open

    if self.open then
        self:OpenInventory()
    else
        self:CloseInventory()
    end
end

function cInventory:onResourceStop(resource_name)
    if GetCurrentResourceName() == resource_name then
        Filter:Clear()
    end
end

function cInventory:OpenInventory()
    if not self.ui then return end

    self:RestrictActionsWhileInventoryOpen(true)

    self.ui:CallEvent('Open')
    self.ui:BringToFront()

    UI:SetCursor(true)
    UI:SetFocus(true)
    UI:KeepInput(true)

    Filter:Apply({
        name = "hud_def_blur",
        amount = 1
    })
end

function cInventory:CloseInventory()
    
    self.ui:CallEvent('Close')
    self:RestrictActionsWhileInventoryOpen(false)

    UI:SetCursor(false)
    UI:SetFocus(false)
    UI:KeepInput(false)

    Filter:Clear()
end

function cInventory:LoadingscreenReady()
    Events:Fire("Loadingscreen/Add", {
        name = "inventory_ui",
        callback = function()

            Events:Fire("Loadingscreen/Update", {
                name = "Inventory UI"
            })

            self.ui = UI:Create({
                name = "inventory", 
                path = "inventory/client/ui/index.html",
                visible = false
            })

            self.ui:SendToBack()
            self.ui:Subscribe("Ready", self, self.UIReady)
            self.ui:Subscribe("Close", self, self.CloseInventory)

        end
    })
end

function cInventory:InventoryUpdated(args)

    self.ui:CallEvent("InventoryUpdated", args)
    
    if args.action == "full" then
        -- Loading the inventory for the first time

        if self.player_inventories_loaded < 3 then
            self.player_inventories_loaded = self.player_inventories_loaded + 1
            
            Events:Fire("Loadingscreen/Update", {
                name = string.format("Inventory (%d/%d)", 
                    self.player_inventories_loaded,
                    self.total_player_inventories)
            })

            -- Finished loading inventories
            if self.player_inventories_loaded == self.total_player_inventories then
                Events:Fire("Loadingscreen/Remove", {
                    name = "inventory_init_sync"
                })
                
                self:FinishedLoadingInventories()
            end

        end

    end

end

-- Called after initial sync of player inventories finishes
function cInventory:FinishedLoadingInventories()
    self.ui:Show()
end

function cInventory:UIReady()

    Citizen.CreateThread(function()

        Wait(1000)

        Network:Send("InventoryUILoaded-" .. tostring(LocalPlayer:GetUniqueId()))

        Events:Fire("Loadingscreen/Add", {
            name = "inventory_init_sync",
            callback = function()
    
                Events:Fire("Loadingscreen/Update", {
                    name = string.format("Inventory (%d/%d)", 
                        self.player_inventories_loaded,
                        self.total_player_inventories)
                })
    
            end
        })

        Events:Fire("Loadingscreen/Remove", {
            name = "inventory_ui"
        })

    end)

end



Inventory = cInventory()