import InvItem from "./InvItem"

export default class InvStack
{
    constructor (stack)
    {
        if (Object.keys(stack).length == 0 ||
            typeof stack.contents == 'undefined' ||
            typeof stack.uid == 'undefined')
        {
            console.error(`Unable to create InvStack from stack: ${stack}`)
        }

        this.contents = stack.contents;
        this.uid = stack.uid;

        for (let i = 0; i < this.contents.length; i++)
        {
            this.contents[i] = new InvItem(this.contents[i]);
        }
    }

    getAmount()
    {
        return (this.contents.length == 1 || this.isStackable()) ? 
            this.contents[i].getAmount() :
            this.contents.length;
    }

    isStackable()
    {
        return this.contents[0].durable;
    }
}