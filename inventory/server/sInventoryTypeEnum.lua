InventoryTypeEnum = class(Enum)


function InventoryTypeEnum:__init()
    self:EnumInit()

    -- Enum values
    self.Main = 1
    self.Hotbar = 2
    self.Character = 3
    self.Loot = 4
    self.ItemInfo = 5

end

InventoryTypeEnum = InventoryTypeEnum()