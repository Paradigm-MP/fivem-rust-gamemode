// Add new images for items here

const item_images = {
    ["DEFAULT"]: "images/default.png",
    ["ITEM_ROCK"]: "rock.png"
}

function GetItemImage(item_name)
{
    return item_images[item_name] || item_images["DEFAULT"];
}

export default GetItemImage