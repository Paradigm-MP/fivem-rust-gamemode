-- Removes all clothes from mp_m_freemode_01 model
function Ped:RemoveAllClothes()
    -- Top
    self:SetComponentVariation(
        11,
        15, 
        0,
        0
    )

    -- Undershirt
    self:SetComponentVariation(
        8,
        15, 
        0,
        0
    )

    -- Shirt
    self:SetComponentVariation(
        3,
        15, 
        0,
        0
    )

    -- Pants
    self:SetComponentVariation(
        4,
        21, 
        0,
        0
    )

    -- Feet
    self:SetComponentVariation(
        6,
        34, 
        0,
        0
    )
end