local AnticheatObject = class()

function AnticheatObject:__init()

    self.strikes = 0
    self.max_strikes = 3

    -- self:Loop()
end

function AnticheatObject:Loop()
    Citizen.CreateThread(function()
        while self.strikes < self.max_strikes do
            if self:CheckObjects() == false then
                self.strikes = self.strikes + 1
            end
            Wait(1000)
        end

        Network:Send('anticheat/cheating', {
            reason = "objects invalid"
        })
        RestartGame()
    end)
end

local entityEnumerator = {
    __gc = function(enum)
      if enum.destructor and enum.handle then
        enum.destructor(enum.handle)
      end
      enum.destructor = nil
      enum.handle = nil
    end
}

function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
      local iter, id = initFunc()
      if not id or id == 0 then
        disposeFunc(iter)
        return
      end
  
      local enum = {handle = iter, destructor = disposeFunc}
      setmetatable(enum, entityEnumerator)
  
      local next = true
      repeat
        coroutine.yield(id)
        next, id = moveFunc(iter)
      until not next
  
      enum.destructor, enum.handle = nil, nil
      disposeFunc(iter)
    end)
end

-- TODO: use GetGamePool instead
  
function EnumerateObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function AnticheatObject:CheckObjects()

    -- Make sure none of our objects were removed
    for _, object in pairs(Objects) do
        if not object:Exists() then
            return false
        end
    end

    -- Make sure no objects were spawned by me
    local invalid_objects = false
    local my_id = LocalPlayer:GetPlayerId()
    for object_id in EnumerateObjects() do
        if ObjectManager:FindObjectByEntityId(object_id) == nil then

            if NetworkGetEntityOwner(object_id) == my_id then
                -- It was spawned by me
                DeleteEntity(object_id)

                if DoesEntityExist(object_id) == false then
                    invalid_objects = true
                end
            end
        end
    end

    return not invalid_objects
end

local AnticheatObject = AnticheatObject()