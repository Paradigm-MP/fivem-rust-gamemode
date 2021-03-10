sPlayerInventoryConfig = class()

function sPlayerInventoryConfig:__init()

    self.default_slots = 
    {
        [InventoryTypeEnum.Main] = 24,
        [InventoryTypeEnum.Hotbar] = 6,
        [InventoryTypeEnum.Character] = 7
    }

end

sPlayerInventoryConfig = sPlayerInventoryConfig()