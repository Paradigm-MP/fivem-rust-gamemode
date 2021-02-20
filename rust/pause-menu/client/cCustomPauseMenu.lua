CustomPauseMenu = class()

function CustomPauseMenu:__init()

    self.ui = UI:Create({name = "pause_menu", path = "pause-menu/client/html/index.html", visible = false})

    self.ui:Subscribe("OptionSelected", self, self.OptionSelected)

    self.open = false
    self.adventure_started = false

    Keymap:Register("escape", "keyboard", "PauseMenu_esc", function(args)
        if args.up then
            self:ToggleOpen()
        end
    end)

    Events:Subscribe("UIKeyPress", function(args)
        if args.type == "keyup" and args.key == 27 and (self.open or not self.adventure_started) then
            self:ToggleOpen()
        end
    end)

    -- Disable default pause menu
    Citizen.CreateThread(function()
        while true do
            SetPauseMenuActive(false)
            Wait(0)
        end
    end)

    Events:Subscribe("StartAdventure", self, self.StartAdventure)
end

function CustomPauseMenu:StartAdventure()
    self.adventure_started = true
end

function CustomPauseMenu:OptionSelected(args)
    
end

function CustomPauseMenu:ToggleOpen()
    self.open = not self.open

    UI:SetCursor(self.open)
    UI:SetFocus(self.open)

    if self.open then
        self.ui:Show()
        self.ui:BringToFront()
        Filter:Apply({
            name = "hud_def_blur",
            amount = 1,
            extra = true
        })
    else
        self.ui:Hide()
        Filter:Clear({
            extra = true
        })
    end

end

CustomPauseMenu = CustomPauseMenu()