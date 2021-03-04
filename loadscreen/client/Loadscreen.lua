Loadscreen = class()

-- Loadscreen class for use after initial load
function Loadscreen:__init()
    self.ui = UI:Create({name = "Loadscreen", path = "loadscreen/client/html/index.html"})

    UI:SetFocus(true)
    UI:SetCursor(true)

    LocalPlayer:Freeze()
    Camera:DetachFromPlayer()
    Camera:SetPosition(vector3(0, 0, 500))

    self.ui:Subscribe('Ready', self, self.UIReady)

    self.loading_functions = {}

    Events:Subscribe('Loadingscreen/Add', self, self.Add)
    Events:Subscribe('Loadingscreen/Remove', self, self.Remove)
    Events:Subscribe('Loadingscreen/Update', self, self.Update)
end

function Loadscreen:UIReady()
    ShutdownLoadingScreenNui()
    Events:Fire("Loadingscreen/Ready")
end

function Loadscreen:FinishLoading()
    Events:Fire('Loadingscreen/Finished')
    self.ui:Hide()
    UI:SetFocus(false)
    UI:SetCursor(false)
end

function Loadscreen:Add(args)
    table.insert(self.loading_functions, args)

    if count_table(self.loading_functions) == 1 then
        output_table(self.loading_functions[1])
        self.loading_functions[1].callback()
    end
end

function Loadscreen:Remove(args)
    for index, data in pairs(self.loading_functions) do
        if data.name == args.name then
            table.remove(self.loading_functions, index)
            break
        end
    end

    if count_table(self.loading_functions) > 0 then
        self.loading_functions[1].callback()
    else
        self:FinishLoading()
    end
end

function Loadscreen:Update(args)
    self.ui:CallEvent('Update', args)
end

Loadscreen = Loadscreen()