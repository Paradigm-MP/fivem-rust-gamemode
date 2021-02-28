import React, {useState, useEffect} from 'react';
import "../styles/hotbar.scss"
import Item from "./Item"
import InventoryViewDragSections from "./constants/InventoryViewDragSections"

export default class Hotbar extends React.Component {

    constructor (props)
    {
        super(props);

        this.num_hotbar_slots = 6;
        this.drag_section = InventoryViewDragSections.Hotbar;
    }

    itemMouseUp (event, slot)
    {
        
    }

    itemMouseDown (event, slot)
    {
        this.props.selectSlot(slot, this.drag_section);
        this.props.startDraggingItem(event, slot, this.drag_section);
    }

    render () {
        return (
            <>
                <div className='hotbar-container'>
                    {[...Array(this.num_hotbar_slots)].map((value, index) => 
                        {
                        return <Item 
                        {...this.props}
                        key={`itemslot_inv_${this.drag_section}_${index}`}
                        setHoveredSlotAndSection={this.props.setHoveredSlotAndSection}
                        itemMouseUp={this.itemMouseUp.bind(this)}
                        itemMouseDown={this.itemMouseDown.bind(this)}
                        slot={index}
                        selected={index == this.props.selectedSlot && this.props.selectedDragSection == this.drag_section}
                        drag_section={this.drag_section}
                        item_data={{
                            name: "Rock", 
                            amount: Math.floor(Math.random() * 1000), 
                            durable: true, 
                            durability: 0.7
                        }}></Item>
                    })}
                </div>
            </>
        )
    }
}