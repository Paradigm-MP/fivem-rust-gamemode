ItemData = 
{
    {
        name = "rock",
        stacklimit = 1,
        durable = true,
        max_durability = 200
    },
    {
        name = "wood",
        stacklimit = 1000
    },
    {
        name = "stone",
        stacklimit = 1000
    },
    {
        name = "stone_hatchet",
        stacklimit = 1,
        durable = true,
        max_durability = 200
    },
    {
        name = "apple",
        stacklimit = 10,
        attributes = {
            ["healing"] = 5,
            ["calories"] = 15,
            ["hydration"] = 5
        },
        actions = {
            ["eat"] = true
        }
    },
    {
        name = "mushroom",
        stacklimit = 10,
        attributes = {
            ["instant_health"] = 3,
            ["calories"] = 15,
            ["hydration"] = 5
        },
        actions = {
            ["eat"] = true
        }
    }
}

-- body bag: bkr_prop_duffel_bag_01a.ydr
-- item bag: prop_money_bag_01.ydr
-- sleeping bag: prop_skid_sleepbag_1.ydr

DroppedItemModel = "prop_money_bag_01"


Items_indexed = {}

for _, item_data in pairs(ItemData) do
    Items_indexed[item_data.name] = item_data
end