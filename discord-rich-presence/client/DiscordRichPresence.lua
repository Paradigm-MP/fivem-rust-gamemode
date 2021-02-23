cDiscordRichPresence = class()

function cDiscordRichPresence:__init()
    Network:Subscribe("discord-rich-presence/send_max_clients", self, self.SetMaxClients)
end

function cDiscordRichPresence:SetMaxClients(args)
    self.max_clients = args.max

    self:StartUpdateLoop()
end

function cDiscordRichPresence:StartUpdateLoop()
    Citizen.CreateThread(function()
        while true do
            -- Credit for original snippet: https://forum.cfx.re/t/how-to-updated-discord-rich-presence-custom-image/157686

            --This is the Application ID (Replace this with your own)
            SetDiscordAppId(813503345918345216)

            --Here you will have to put the image name for the "large" icon.
            SetDiscordRichPresenceAsset('rust_logo')
            
            SetRichPresence(string.format("%d/%d Players", count_table(GetActivePlayers()), self.max_clients))

            --Here you can add hover text for the "large" icon.
            SetDiscordRichPresenceAssetText('FiveM Rust (Survival)')
        
            -- For server owners: remove/edit these lines below to advertise your own discord server

            --Here you will have to put the image name for the "small" icon.
            SetDiscordRichPresenceAssetSmall('paradigm_logo')

            --Here you can add hover text for the "small" icon.
            SetDiscordRichPresenceAssetSmallText('Join us at discord.paradigm.mp')

            --It updates every one minute just in case.
            Citizen.Wait(60000)
        end
    end)
end

cDiscordRichPresence = cDiscordRichPresence()