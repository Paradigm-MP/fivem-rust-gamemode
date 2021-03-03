import React, {useState, useEffect} from 'react';
import "../styles/main_inventory.scss"
import "./Hotbar"
import Item from "./Item"
import Hotbar from './Hotbar';
import InventorySections from "./constants/InventorySections"

export default class MainInventory extends React.Component {

    constructor (props)
    {
        super(props);
        // Number of inventory slots. You probably shouldn't change this.
        // It's also not part of the state, so if you do change it, you
        // should only do it once or add it to the state.
        this.num_inv_slots = 24;
        this.drag_section = InventorySections.Main;
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
                <div className='main-inventory-container'>
                    <div className='title'>Inventory</div>
                    <div className='inventory-items-container'>
                        {/* TODO: replace this generic array with the actual inventory */}
                        {[...Array(this.num_inv_slots)].map((value, index) => 
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
                            item_data={this.props.contents[index]}></Item>
                        })}
                    </div>
                    <div className='hotbar-container-outer'>
                        <Hotbar
                            {...this.props}
                        ></Hotbar>
                    </div>
                </div>

            </>
        )
    }
}