-- Removes all clothes from mp_m_freemode_01 model
function Ped:RemoveAllClothes()
    -- Top
    SetPedComponentVariation(self.ped_id, 
        11,
        15, 
        0,
        0
    )

    -- Undershirt
    SetPedComponentVariation(self.ped_id, 
        8,
        15, 
        0,
        0
    )

    -- Shirt
    SetPedComponentVariation(self.ped_id, 
        3,
        15, 
        0,
        0
    )

    -- Pants
    SetPedComponentVariation(self.ped_id, 
        4,
        21, 
        0,
        0
    )

    -- Feet
    SetPedComponentVariation(self.ped_id, 
        6,
        34, 
        0,
        0
    )
end