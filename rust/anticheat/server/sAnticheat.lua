Anticheat = class()

function Anticheat:__init()

    Network:Subscribe('anticheat/cheating', function(args) self:Cheating(args) end)
end

function Anticheat:Cheating(args)
    print(args.player:GetName() .. " was cheating for: " .. args.reason)
    args.player:Kick("Big brother is watching...")
end

Anticheat = Anticheat()