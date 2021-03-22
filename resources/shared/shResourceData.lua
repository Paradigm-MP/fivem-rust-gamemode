ResourceType = 
{
    Wood = "wood",
    Stone = "stone"
}

function GetResourceTypeFromModel(model)
    if ResourceData[ResourceType.Wood][model] then
        return ResourceType.Wood
    elseif ResourceData[ResourceType.Stone][model] then
        return ResourceType.Stone
    end
end

function GetResourceData(model, type)
    return ResourceData[type][model]
end

local ResourceSizeConversions = 
{
    [ResourceType.Wood] = 50,
    [ResourceType.Stone] = 50
}

local ResourceLimits = 
{
    [ResourceType.Wood] = {min = 100, max = 1000},
    [ResourceType.Stone] = {min = 100, max = 1000}
}

ResourceYieldBounds = 
{
    [ResourceType.Wood] = {min = 15, max = 20},
    [ResourceType.Stone] = {min = 15, max = 20}
}

-- Gets the total amount of resource (items to give / health) for a given size of a resource
function GetResourceAmountFromSize(resource_type, size)
    return math.clamp(
        math.ceil(ResourceSizeConversions[resource_type] * size), 
        ResourceLimits[resource_type].min,
        ResourceLimits[resource_type].max)
end

ResourceData = 
{
    [ResourceType.Wood] = 
    {
        ["prop_tree_cedar_02"] = {size = 18.17258},
        ["prop_tree_cedar_04"] = {size = 18.58865},
        ["prop_tree_pine_02"] = {size = 18.40323},
        ["prop_bush_lrg_04b"] = {size = 22.83316},
        ["prop_palm_sm_01d"] = {size = 8.592731},
        ["prop_tree_eng_oak_01"] = {size = 14.62759},
        ["prop_tree_fallen_pine_01"] = {size = 188},
        ["prop_palm_med_01d"] = {size = 6.58915},
        ["prop_palm_med_01c"] = {size = 18.21685},
        ["prop_tree_stump_01"] = {size = 1.27289},
        ["prop_palm_med_01b"] = {size = 15.93361},
        ["prop_palm_sm_01f"] = {size = 10.13917},
        ["prop_desert_iron_01"] = {size = 5.837362},
        ["prop_tree_jacada_01"] = {size = 12.47741},
        ["prop_veg_crop_tr_01"] = {size = 4.999193},
        ["prop_tree_fallen_02"] = {size = 6.477365},
        ["prop_tree_maple_02"] = {size = 8.111059},
        ["prop_tree_fallen_01"] = {size = 7.509586},
        ["prop_palm_fan_03_c"] = {size = 11.67747},
        ["prop_tree_olive_01"] = {size = 15.59428},
        ["prop_tree_log_02"] = {size = 2.442637},
        ["prop_palm_fan_03_b"] = {size = 7.657213},
        ["prop_tree_log_01"] = {size = 2.993724},
        ["prop_palm_huge_01a"] = {size = 24.6088},
        ["prop_tree_oak_01"] = {size = 23.45202},
        ["prop_tree_lficus_05"] = {size = 12.88455},
        ["prop_tree_birch_04"] = {size = 9.880266},
        ["prop_tree_eucalip_01"] = {size = 25.18636},
        ["prop_tree_lficus_02"] = {size = 15.43476},
        ["prop_tree_cedar_s_04"] = {size = 9.389428},
        ["prop_tree_birch_03b"] = {size = 4.936234},
        ["prop_bush_lrg_02"] = {size = 5.053696},
        ["prop_bush_lrg_02b"] = {size = 6.207268},
        ["prop_palm_sm_01a"] = {size = 5.831257},
        ["prop_tree_cedar_s_02"] = {size = 3.219748},
        ["prop_tree_lficus_06"] = {size = 12.34419},
        ["prop_tree_cedar_s_01"] = {size = 6.380684},
        ["test_tree_forest_trunk_04"] = {size = 8.173439},
        ["prop_bush_lrg_04c"] = {size = 22.64746},
        ["test_tree_forest_trunk_01"] = {size = 55.69537},
        ["prop_tree_maple_03"] = {size = 6.13577},
        ["prop_w_r_cedar_01"] = {size = 14.72054},
        ["prop_tree_pine_01"] = {size = 18.90875},
        ["prop_palm_sm_01e"] = {size = 12.01424},
        ["prop_joshua_tree_01a"] = {size = 3.025159},
        ["prop_w_r_cedar_dead"] = {size = 12.39391},
        ["prop_rio_del_01"] = {size = 12.80367},
        ["prop_tree_mquite_01"] = {size = 4.70728},
        ["test_tree_cedar_trunk_001"] = {size = 18.58975},
        ["prop_tree_lficus_03"] = {size = 7.355336},
        ["prop_tree_cedar_03"] = {size = 19.97599},
        ["prop_palm_fan_03_d"] = {size = 14.14019},
        ["prop_palm_fan_02_a"] = {size = 4.77218},
        ["prop_palm_fan_04_d"] = {size = 13.28578},
        ["prop_plant_palm_01a"] = {size = 4.690416},
        ["prop_tree_jacada_02"] = {size = 9.851354},
        ["prop_bush_neat_01"] = {size = 2.586736},
        ["prop_bush_neat_02"] = {size = 1.678823},
        ["prop_bush_neat_08"] = {size = 2.951716},
        ["prop_tree_cedar_s_06"] = {size = 3.513742},
        ["prop_joshua_tree_01b"] = {size = 2.834897},
        ["prop_joshua_tree_01d"] = {size = 3.554843},
        ["prop_plant_palm_01c"] = {size = 4.690416},
        ["prop_tree_cedar_s_05"] = {size = 5.647628},
        ["prop_veg_crop_tr_02"] = {size = 5.58507},
        ["prop_tree_cypress_01"] = {size = 10.3946},
        ["prop_rus_olive"] = {size = 7.081912},
        ["prop_bush_lrg_04d"] = {size = 21.96561},
        ["prop_pot_plant_03a"] = {size = 1.6734},
        ["prop_rus_olive_wint"] = {size = 10.58612},
        ["prop_palm_med_01a"] = {size = 16.84248},
        ["prop_tree_birch_01"] = {size = 10.78932},
        ["prop_tree_birch_02"] = {size = 9.766795},
        ["prop_tree_birch_03"] = {size = 5.256915},
        ["prop_s_pine_dead_01"] = {size = 6.902693},
        ["prop_fan_palm_01a"] = {size = 8.97636},
        ["prop_cactus_01e"] = {size = 3.627706},
        ["prop_cactus_01b"] = {size = 2.634791},
        ["prop_cactus_01a"] = {size = 2.304941},
        ["prop_cactus_01c"] = {size = 2.230782},
        ["prop_cactus_02"] = {size = 1.126701},
        ["prop_cactus_03"] = {size = 1.348107},
        ["prop_joshua_tree_01c"] = {size = 2.811994},
        ["prop_joshua_tree_01e"] = {size = 2.848725},
        ["prop_joshua_tree_02a"] = {size = 3.541589},
        ["prop_joshua_tree_02b"] = {size = 3.192919},
        ["prop_joshua_tree_02c"] = {size = 3.350399},
        ["prop_joshua_tree_02d"] = {size = 4.183601},
        ["prop_joshua_tree_02e"] = {size = 4.366014},
    },
    [ResourceType.Stone] = 
    {
        ["cs_x_rublrga"] = {size = 6.246158},
        ["cs_x_rublrgb"] = {size = 4.635937},
        ["cs_x_rublrgc"] = {size = 4.514919},
        ["cs_x_rublrgd"] = {size = 4.251027},
        ["cs_x_rublrge"] = {size = 5.799537},
        ["cs_x_rubmeda"] = {size = 4.042703},
        ["cs_x_rubmedb"] = {size = 3.321812},
        ["cs_x_rubmedc"] = {size = 3.189837},
        ["cs_x_rubmedd"] = {size = 2.928938},
        ["cs_x_rubmede"] = {size = 3.884346},
        ["cs_x_rubsmla"] = {size = 2.306206},
        ["cs_x_rubsmlb"] = {size = 2.193625},
        ["cs_x_rubsmlc"] = {size = 1.746601},
        ["cs_x_rubsmld"] = {size = 1.816023},
        ["cs_x_rubsmle"] = {size = 2.503356},
        ["cs_x_rubweea"] = {size = 1.108653},
        ["cs_x_rubweec"] = {size = 1.204042},
        ["cs_x_rubweed"] = {size = 1.076829},
        ["cs_x_rubweee"] = {size = 1.29747},
        ["cs_x_weesmlb"] = {size = 1.066981},
        ["csx_coastbigroc01_"] = {size = 17.93706},
        ["csx_coastbigroc02_"] = {size = 16.27285},
        ["csx_coastbigroc03_"] = {size = 9.635671},
        ["csx_coastbigroc05_"] = {size = 8.853081},
        ["csx_coastboulder_00_"] = {size = 3.037567},
        ["csx_coastboulder_01_"] = {size = 4.294848},
        ["csx_coastboulder_02_"] = {size = 4.22802},
        ["csx_coastboulder_03_"] = {size = 5.94012},
        ["csx_coastboulder_04_"] = {size = 2.857995},
        ["csx_coastboulder_05_"] = {size = 4.349658},
        ["csx_coastboulder_06_"] = {size = 3.727948},
        ["csx_coastboulder_07_"] = {size = 5.661762},
        ["csx_coastrok1_"] = {size = 14.74695},
        ["csx_coastrok2_"] = {size = 13.17084},
        ["csx_coastrok3_"] = {size = 11.7409},
        ["csx_coastrok4_"] = {size = 14.04163},
        ["csx_rvrbldr_biga_"] = {size = 6.664025},
        ["csx_rvrbldr_bigb_"] = {size = 6.777154},
        ["csx_rvrbldr_bigc_"] = {size = 6.216278},
        ["csx_rvrbldr_bigd_"] = {size = 5.815881},
        ["csx_rvrbldr_bige_"] = {size = 5.698575},
        -- No underwater rocks for now
        -- ["csx_seabed_bldr1_"] = {size = 1},
        -- ["csx_seabed_bldr2_"] = {size = 1},
        -- ["csx_seabed_bldr3_"] = {size = 1},
        -- ["csx_seabed_bldr4_"] = {size = 1},
        -- ["csx_seabed_bldr5_"] = {size = 1},
        -- ["csx_seabed_bldr6_"] = {size = 1},
        -- ["csx_seabed_bldr7_"] = {size = 1},
        -- ["csx_seabed_bldr8_"] = {size = 1},
        -- ["csx_seabed_rock1_"] = {size = 1},
        -- ["csx_seabed_rock2_"] = {size = 1},
        -- ["csx_seabed_rock3_"] = {size = 1},
        -- ["csx_seabed_rock4_"] = {size = 1},
        -- ["csx_seabed_rock5_"] = {size = 1},
        -- ["csx_seabed_rock6_"] = {size = 1},
        -- ["csx_seabed_rock7_"] = {size = 1},
        -- ["csx_seabed_rock8_"] = {size = 1},
        ["csx_searocks_02"] = {size = 20.74312},
        ["csx_searocks_03"] = {size = 13.13297},
        ["csx_searocks_04"] = {size = 12.5157},
        ["csx_searocks_05"] = {size = 7.301435},
        ["csx_searocks_06"] = {size = 17.92336},
        ["csx_rvrbldr_smla_"] = {size = 1.228913},
        ["csx_rvrbldr_smlb_"] = {size = 1.345695},
        ["csx_rvrbldr_smlc_"] = {size = 1.351627},
        ["csx_rvrbldr_smld_"] = {size = 1.099575},
        ["csx_rvrbldr_smle_"] = {size = 1.61952},
        ["csx_rvrbldr_meda_"] = {size = 1.957785},
        ["csx_rvrbldr_medb_"] = {size = 2.141965},
        ["csx_rvrbldr_medc_"] = {size = 2.575549},
        ["csx_rvrbldr_medd_"] = {size = 1.700363},
        ["csx_rvrbldr_mede_"] = {size = 2.634997},
        ["csx_coastsmalrock_01_"] = {size = 1.197012},
        ["csx_coastsmalrock_02_"] = {size = 1.513368},
        ["csx_coastsmalrock_03_"] = {size = 1.904987},
        ["csx_coastsmalrock_04_"] = {size = 2.27271},
        ["csx_coastsmalrock_05_"] = {size = 1.980567},
        ["prop_rock_1_a"] = {size = 3.354561},
        ["prop_rock_1_b"] = {size = 3.432825},
        ["prop_rock_1_c"] = {size = 3.098585},
        ["prop_rock_1_d"] = {size = 2.11062},
        ["prop_rock_1_e"] = {size = 1.867126},
        ["prop_rock_1_f"] = {size = 1.98993},
        ["prop_rock_1_g"] = {size = 1.150736},
        ["prop_rock_1_h"] = {size = 1.252568},
        ["prop_rock_1_i"] = {size = 0.9961677},
        ["prop_rock_2_a"] = {size = 1.742865},
        ["prop_rock_2_c"] = {size = 2.779779},
        ["prop_rock_2_d"] = {size = 2.144284},
        ["prop_rock_2_f"] = {size = 1.585728},
        ["prop_rock_2_g"] = {size = 1.715357},
        ["prop_rock_3_a"] = {size = 3.339495},
        ["prop_rock_3_b"] = {size = 1.654079},
        ["prop_rock_3_c"] = {size = 1.251823},
        ["prop_rock_3_d"] = {size = 1.395751},
        ["prop_rock_3_e"] = {size = 1.669731},
        ["prop_rock_3_f"] = {size = 1.632865},
        ["prop_rock_3_g"] = {size = 1.180391},
        ["prop_rock_3_h"] = {size = 2.511062},
        ["prop_rock_3_i"] = {size = 2.518842},
        ["prop_rock_3_j"] = {size = 1.706509},
        ["prop_rock_4_a"] = {size = 1.368239},
        ["prop_rock_4_b"] = {size = 1.303461},
        ["prop_rock_4_big"] = {size = 2.315914},
        ["prop_rock_4_big2"] = {size = 2.582259},
        ["prop_rock_4_c"] = {size = 1.197503},
        ["prop_rock_4_c_2"] = {size = 1.197503},
        ["prop_rock_4_cl_1"] = {size = 1.433602},
        ["prop_rock_4_d"] = {size = 1.307735},
        ["prop_rock_4_e"] = {size = 1.066981},
        -- Too small to be worth it
        -- ["prop_rock_4_cl_2"] = {size = 0.5543264},
        -- ["prop_rock_5_a"] = {size = 0.6487355},
        -- ["prop_rock_5_b"] = {size = 0.5805035},
        -- ["prop_rock_5_c"] = {size = 0.5572306},
        -- ["prop_rock_5_d"] = {size = 0.5542198},
        -- ["prop_rock_5_e"] = {size = 0.336353},
        -- ["rock_4_cl_2_1"] = {size = 0.6020206},
        -- ["rock_4_cl_2_2"] = {size = 0.5584164},
        
        -- These are the big groups of rocks on some beaches.
        -- They don't place nicely.
        -- Removing them still leaves the collision behind, so
        -- it's better to keep them and have them simply not be
        -- harvestable. 
        -- ["ch1_01_beachrck_a"] = {size = 1},
        -- ["ch1_01_beachrck_b"] = {size = 1},
        -- ["ch1_01_beachrck_c"] = {size = 1},
        -- ["ch1_01_beachrck_d"] = {size = 1},
        -- ["ch1_01_beachrck_e"] = {size = 1},
        -- ["ch1_01_beachrck_f"] = {size = 1},
        -- ["ch1_01_beachrck_g"] = {size = 1},
        -- ["ch1_01_beachrck_h"] = {size = 1},
        -- ["ch1_01_beachrck_i"] = {size = 1},
        -- ["ch1_01_beachrck_j"] = {size = 1},
        -- ["ch1_01_beachrck_a_lod"] = {size = 1},
        -- ["ch1_01_beachrck_b_lod"] = {size = 1},
        -- ["ch1_01_beachrck_c_lod"] = {size = 1},
        -- ["ch1_01_beachrck_d_lod"] = {size = 1},
        -- ["ch1_01_beachrck_e_lod"] = {size = 1},
        -- ["ch1_01_beachrck_f_lod"] = {size = 1},
        -- ["ch1_01_beachrck_g_lod"] = {size = 1},
        -- ["ch1_01_beachrck_h_lod"] = {size = 1},
        -- ["ch1_01_beachrck_i_lod"] = {size = 1},
        -- ["ch1_01_beachrck_j_lod"] = {size = 1}
    }
}

-- Resources that should simply be removed from the game and never spawned
-- "Problematic" resources
NoSpawnResources = 
{
    ["ch1_01_beachrck_a"] = true,
    ["ch1_01_beachrck_b"] = true,
    ["ch1_01_beachrck_c"] = true,
    ["ch1_01_beachrck_d"] = true,
    ["ch1_01_beachrck_e"] = true,
    ["ch1_01_beachrck_f"] = true,
    ["ch1_01_beachrck_g"] = true,
    ["ch1_01_beachrck_h"] = true,
    ["ch1_01_beachrck_i"] = true,
    ["ch1_01_beachrck_j"] = true,
    ["ch1_01_beachrck_a_lod"] = true,
    ["ch1_01_beachrck_b_lod"] = true,
    ["ch1_01_beachrck_c_lod"] = true,
    ["ch1_01_beachrck_d_lod"] = true,
    ["ch1_01_beachrck_e_lod"] = true,
    ["ch1_01_beachrck_f_lod"] = true,
    ["ch1_01_beachrck_g_lod"] = true,
    ["ch1_01_beachrck_h_lod"] = true,
    ["ch1_01_beachrck_i_lod"] = true,
    ["ch1_01_beachrck_j_lod"] = true
}