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
    }
}

Items_indexed = {}

for _, item_data in pairs(ItemData) do
    Items_indexed[item_data.name] = item_data
end