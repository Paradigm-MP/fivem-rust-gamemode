sDiscordRichPresence = class()

function sDiscordRichPresence:__init()
    Events:Subscribe("ClientModulesLoaded", self, self.ClientModulesLoaded)
end

function sDiscordRichPresence:ClientModulesLoaded(args)
    Network:Send("discord-rich-presence/send_max_clients", args.player, {max = GetConvar("sv_maxclients")})
end

sDiscordRichPresence = sDiscordRichPresence()