cInventory = class()

function cInventory:__init()

    self.ui = UI:Create({
        name = "inventory", 
        path = "inventory/client/ui/index.html",
        visible = false
    })

    self.ui:SendToBack()

    self.ui:Subscribe("Ready", self, self.UIReady)

end

function cInventory:UIReady()
    self.ui:Show()

    -- TODO: Bring UI to front once loaded fully, after loadscreen ends
end



Inventory = cInventory()