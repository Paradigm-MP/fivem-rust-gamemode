// Add new images for items here

const item_images = {
    ["DEFAULT"]:            "images/default.png",
    ["TRANSPARENT"]:        "images/transparent.png",
    // ["Rock"]:               "images/rock.png"
}

function GetItemImage(item_name)
{
    return (typeof item_name != 'undefined') ? (item_images[item_name] || item_images["DEFAULT"]) : item_images["TRANSPARENT"];
}

export default GetItemImage