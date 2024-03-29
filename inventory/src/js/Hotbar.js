import React, {useState, useEffect} from 'react';
import "../styles/hotbar.scss"
import Item from "./Item"
import InventorySections from "./constants/InventorySections"

export default class Hotbar extends React.Component {

    constructor (props)
    {
        super(props);

        this.num_hotbar_slots = 6;
        this.drag_section = InventorySections.Hotbar;
    }

    itemMouseUp (event, slot)
    {
        this.props.selectSlot(slot, this.drag_section);
    }

    itemMouseDown (event, slot)
    {
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
                        selected={(index == this.props.selectedSlot && this.props.selectedDragSection == this.drag_section) || index == this.props.equipped_hotbar_slot}
                        drag_section={this.drag_section}
                        stack={this.props.contents_hotbar[index]}></Item>
                    })}
                </div>
            </>
        )
    }
}