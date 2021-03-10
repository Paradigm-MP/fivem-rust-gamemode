export default class InvItem
{
    constructor (item)
    {
        if (
            typeof item == 'undefined' ||
            typeof item.uid == 'undefined' ||
            typeof item.name == 'undefined' ||
            typeof item.amount == 'undefined' ||
            typeof item.stacklimit == 'undefined' ||
            typeof item.durable == 'undefined')
        {
            console.error(`Failed to create InvItem from item: ${item}`);
        }

        this.uid = item.uid
        this.name = item.name
        this.amount = item.amount
        this.stacklimit = item.stacklimit
        this.durable = item.durable
        this.custom_data = item.custom_data || {}
    
        if (typeof item.durability != 'undefined')
        {
            if (this.amount > 1)
            {
                console.error("Failed to create InvItem: durability was given but item had more than one amount");
            }

            this.durability = item.durability;

            if (typeof item.max_durability != 'undefined')
            {
                this.max_durability = item.max_durability;
            }
            else
            {
                console.error("Failed to create InvItem: max_durability was not given when an item had durability");
            }
        }
    }
}