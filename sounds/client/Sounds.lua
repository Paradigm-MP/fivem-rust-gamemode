Sounds = class()

function Sounds:__init()
    self.ui = UI:Create({name = "soundui", path = "sounds/client/ui/index.html", visible = false})
end

-- Must specify: args.name and args.volume (0-1)
function Sounds:PlaySound(args)
    self.ui:CallEvent('sounds/play_sound', args)
end

Sounds = Sounds()