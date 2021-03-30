cInventory = class()

function cInventory:__init()

    self.open = false
    self.player_inventories_loaded = 0
    self.total_player_inventories = 3
    self.hotbar_index = -1

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

    Events:Subscribe("Loadingscreen/Ready", self, self.LoadingscreenReady)
    Events:Subscribe("onResourceStop", self, self.onResourceStop)

    Network:Subscribe("InventoryUpdated", self, self.InventoryUpdated)

end

function cInventory:RegisterKeymaps()

    self.hotbar_scroll_timer = Timer()

    Keymap:Register("tab", "keyboard", "Inventory", function(args)
        if args.down then
            self:ToggleOpen()
        end
    end)

    Keymap:Register("IOM_WHEEL_UP", "mouse_wheel", "Hotbar Scroll Up", function(args)
        self:ScrollHotbar(-1)
    end)

    Keymap:Register("IOM_WHEEL_DOWN", "mouse_wheel", "Hotbar Scroll Down", function(args)
        self:ScrollHotbar(1)
    end)

    for i = 1, 6 do
        Keymap:Register(tostring(i), "keyboard", string.format("Hotbar %d", i), function(args)
            if args.down then
                self:SelectHotbar(i)
            end
        end)
    end

end

function cInventory:ScrollHotbar(change)
    if self.hotbar_scroll_timer:GetMilliseconds() < 20 then return end
    self.hotbar_scroll_timer:Restart()

    self.hotbar_index = self.hotbar_index + change
    if self.hotbar_index < 0 then self.hotbar_index = 5 end
    if self.hotbar_index > 5 then self.hotbar_index = 0 end
    
    Network:Send("Inventory/SelectHotbar", {index = self.hotbar_index})
    self.ui:CallEvent("Inventory/SelectHotbar", {index = self.hotbar_index})
end

function cInventory:SelectHotbar(index)
    if self.hotbar_index == index - 1 then
        self.hotbar_index = -1 -- Selecting a selected slot, so unselect it
    else
        self.hotbar_index = index - 1 -- Convert to 0 based index
    end

    Network:Send("Inventory/SelectHotbar", {index = self.hotbar_index})
    self.ui:CallEvent("Inventory/SelectHotbar", {index = self.hotbar_index})
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
        amount = 1,
        extra = true
    })
end

function cInventory:CloseInventory()
    
    self.ui:CallEvent('Close')
    self:RestrictActionsWhileInventoryOpen(false)

    UI:SetCursor(false)
    UI:SetFocus(false)
    UI:KeepInput(false)

    Filter:Clear({
        extra = true
    })
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

            self.ui:Subscribe("Inventory/DragItem", self, self.DragItem)
            self.ui:Subscribe("Inventory/SplitStack", self, self.SplitStack)
            self.ui:Subscribe("Inventory/DropStack", self, self.DropStack)
            self.ui:Subscribe("Inventory/DoAction", self, self.DoAction)

        end
    })
end

function cInventory:DoAction(args)
    Network:Send("Inventory/DoAction", args)
end

function cInventory:DropStack(args)
    Network:Send("Inventory/DropStack", args)
end

function cInventory:SplitStack(args)
    Network:Send("Inventory/SplitStack", args)
end

function cInventory:DragItem(args)
    Network:Send("Inventory/DragItem", args)
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

    if self.loaded then return end

    self.loaded = true
    self.ui:CallEvent("SetLocale", {locale = GetConvar("locale", "en-US")})
    self:RegisterKeymaps()

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