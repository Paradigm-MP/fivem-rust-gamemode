ui_page 'oof/client/ui/index.html'

loadscreen 'loadscreen/client/html/index.html'
loadscreen_manual_shutdown 'yes'

client_scripts {
    -- oof module, nothing should precede this module
    'oof/shared/game/IsFiveM.lua',
    'oof/shared/lua-overloads/*.lua',
    'oof/shared/lua-additions/*.lua',
    'oof/shared/object-oriented/class.lua', -- no class instances on initial frame before this file
    'oof/shared/object-oriented/shGetterSetter.lua', -- getter_setter, getter_setter_encrypted
    'oof/shared/object-oriented/shObjectOrientedUtilities.lua', -- is_class_instance
    'oof/shared/standalone-data-structures/*', -- Enum, IdPool
    'oof/shared/math/*.lua',
    '**/shared/enums/*Enum.lua', -- load all Enums
    '**/client/enums/*Enum.lua',
    'oof/shared/events/*.lua', -- Events class
    'oof/client/network/*.lua', -- Network class
    'oof/shared/value-storage/*.lua', -- ValueStorage class
    'oof/client/typecheck/*.lua', -- TypeCheck class
    'oof/client/asset-requester/*.lua',
    'oof/shared/timer/*.lua', -- Timer class
    'oof/shared/xml/*.lua', -- XML class
    'oof/shared/csv/*.lua', -- CSV class
    'oof/client/entity/*.lua', -- Entity class
    'oof/client/player/cPlayer.lua',
    'oof/client/player/cPlayers.lua',
    'oof/client/player/cPlayerManager.lua',
    'oof/client/ped/*.lua', -- Ped class
    'oof/client/physics/*.lua',
    'oof/client/localplayer/*.lua', -- LocalPlayer class
    'oof/shared/color/*.lua',
    'oof/client/render/*.lua',
    'oof/client/camera/*.lua', -- Camera class
    'oof/client/blip/*.lua', -- Blip class
    'oof/client/object/*.lua', -- Object, ObjectManager classes
    'oof/client/screen-effects/*.lua', -- ScreenEffects class
    'oof/client/world/*.lua',
    'oof/client/sound/*.lua', -- Sound class
    'oof/client/light/*.lua', -- Light class
    'oof/client/particle-effect/*.lua', -- ParticleEffect class
    'oof/client/anim-post-fx/*.lua', -- AnimPostFX class
    'oof/client/volume/*.lua', -- Volume class
    'oof/client/explosion/*.lua', -- Explosion class
    'oof/client/pause-menu/*.lua', -- PauseMenu class
    'oof/client/hud/*.lua', -- HUD class
    'oof/client/keypress/*.lua',
    'oof/client/prompt/*.lua', -- Prompt class
    'oof/client/map/*.lua', -- Imap/Ipl class
    'oof/client/marker/*.lua', -- Marker class
    'oof/client/water/*.lua', -- Water class
    'oof/client/apitest.lua',
    -- ui
    'oof/client/ui/ui.lua',
    'oof/client/localplayer_behaviors/*.lua',
    'oof/client/weapons/*.lua',
    -- events module
    'events/client/cDefaultEvents.lua',
    'events/shared/shTick.lua',
    -- blackscreen
    'blackscreen/client/BlackScreen.lua',
    -- sounds
    'sounds/client/Sounds.lua',
    -- chat
    'chat/shared/shChatUtility.lua',
    'chat/client/cChat.lua',
    -- object editor
    'object-editor/client/cObjectEditor.lua',
    -- anticheat
    'anticheat/client/*.lua',

    -- Gamemode scripts
    'config/shared/*.lua',

    'loadscreen/client/*.lua',

    'spawnmanager/client/*.lua',

    'cells/shared/*.lua',
    'cells/client/*.lua',

    'resources/shared/*.lua',
    'resources/client/*.lua',

    'environment/client/*.lua',
    'character/client/**/*.lua',
    
    'info/client/*.lua',
    'discord-rich-presence/client/*.lua',

    'inventory/client/*.lua',
    'inventory/shared/*.lua',

    -- LOAD LAST
    'oof/shared/object-oriented/LOAD_ABSOLUTELY_LAST.lua'
}

server_scripts {
    -- api module, nothing should precede this module
    'oof/shared/game/IsFiveM.lua',
    'oof/server/sConfig.lua',
    'oof/shared/lua-overloads/*.lua',
    'oof/shared/lua-additions/*.lua',
    'oof/shared/object-oriented/class.lua', -- no class instances on initial frame before this file
    'oof/shared/object-oriented/shGetterSetter.lua',
    'oof/shared/object-oriented/shObjectOrientedUtilities.lua', -- is_class_instance
    'oof/shared/math/*.lua',
    'oof/shared/standalone-data-structures/*', -- Enum, IdPool
    '**/shared/enums/*Enum.lua', -- load all the enums from all the modules
    '**/server/enums/*Enum.lua',
    'oof/shared/color/*.lua',
    'oof/shared/events/*.lua', -- Events class
    'oof/server/network/*.lua', -- Network class
    'oof/server/json/*.lua', -- JsonOOF, JsonUtils classes
    'oof/server/fs-additions/*.lua', -- Directory/file exists helper functions
    -- mysql enabler
    'oof/server/mysql-async/MySQLAsync.net.dll',
    'oof/server/mysql-async/lib/init.lua',
    'oof/server/mysql-async/lib/MySQL.lua',
    -- mysql wrapper
    'oof/server/mysql/MySQL.lua',
    'oof/server/key-value-store/*.lua',
    'oof/shared/value-storage/*.lua', -- ValueStorage class
    'oof/shared/timer/*.lua', -- Timer class
    'oof/shared/xml/*.lua', -- XML class
    'oof/shared/csv/*.lua', -- CSV class
    'oof/server/player/sPlayer.lua', -- Player class
    'oof/server/player/sPlayers.lua', -- Players class
    'oof/server/player/sPlayerManager.lua', -- PlayerManager class
    'oof/server/entity/sEntity.lua', -- Entity class
    'oof/server/ped/sPed.lua', -- Ped class
    'oof/server/world/*.lua', -- World class
    -- events module
    'events/server/sDefaultEvents.lua',
    'events/shared/shTick.lua',
    -- chat
    'chat/server/config.lua',
    'chat/shared/shChatUtility.lua',
    'chat/server/sChat.lua',
    -- object-editor
    'object-editor/server/sObjectEditor.lua',
    -- anticheat
    'anticheat/server/*.lua',

    -- Gamemode modules
    'config/shared/*.lua',
    
    'cells/shared/*.lua',
    'cells/server/*.lua',

    'spawnmanager/server/*.lua',

    'inventory/server/*.lua',
    'inventory/shared/*.lua',

    'resources/shared/*.lua',
    'resources/server/resource_data/**/*',
    'resources/server/*.lua',

    'info/server/*.lua',
    'discord-rich-presence/server/*.lua',
    
    'oof/shared/object-oriented/LOAD_ABSOLUTELY_LAST.lua'
}

files {
    -- general ui
    'oof/client/ui/reset.css',
    'oof/client/ui/jquery.js',
    'oof/client/ui/events.js',
    'oof/client/ui/index.html',
    -- loadscreen module
    'loadscreen/client/html/*',
    -- blackscreen
    'blackscreen/client/html/index.html',
    'blackscreen/client/html/style.css',
    'blackscreen/client/html/script.js',
    -- sounds
    'sounds/client/ui/*',
    'sounds/client/ui/sounds/*.ogg',
    -- chat
    'chat/client/ui/index.html',
    'chat/client/ui/script.js',
    'chat/client/ui/style.css',

    -- Gamemode files
    'resources/shared/**/*',

    'inventory/client/ui/*',
    'inventory/client/ui/images/*',
    'inventory/client/ui/images/rust/*',

    -- Streaming
    'stream/**/*.ytyp',
    'stream/**/*.ydr',
}

data_file 'DLC_ITYP_REQUEST' 'stream/**/*.ytyp'

fx_version 'adamant'
games { 'rdr3', 'gta5' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'