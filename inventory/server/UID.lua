UID = class()

function UID:__init()
    self.id_pool = IdPool()
end

function UID:GetNew()
    return self.id_pool:GetNextId()
end

UID = UID()