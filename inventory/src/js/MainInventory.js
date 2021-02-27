import React, {useState, useEffect} from 'react';
import "../styles/main_inventory.scss"
import "./Hotbar"
import Item from "./Item"
import Hotbar from './Hotbar';
import InventoryViewDragSections from "./constants/InventoryViewDragSections"

export default class MainInventory extends React.Component {

    constructor (props)
    {
        super(props);
        this.state = 
        {
            selected_slot: -1
        }

        // Number of inventory slots. You probably shouldn't change this.
        // It's also not part of the state, so if you do change it, you
        // should only do it once or add it to the state.
        this.num_inv_slots = 24;
        this.drag_section = InventoryViewDragSections.Main;
    }

    selectSlot (slot)
    {
        this.setState({selected_slot: slot == this.state.selected_slot ? -1 : slot})
    }

    itemMouseUp (event, slot)
    {
        this.props.stopDraggingItem(event, slot);
    }

    itemMouseDown (event, slot)
    {
        this.selectSlot(slot);

        this.props.startDraggingItem(event, slot, this.drag_section);
    }

    render () {
        return (
            <>
                <div className='main-inventory-container'>
                    <div className='title'>Inventory</div>
                    <div className='inventory-items-container'>
                        {[...Array(this.num_inv_slots)].map((value, index) => 
                        {
                            return <Item 
                            key={`itemslot_main_inv_${index}`}
                            itemMouseUp={this.itemMouseUp.bind(this)}
                            itemMouseDown={this.itemMouseDown.bind(this)}
                            slot={index}
                            selected={index == this.state.selected_slot}
                            item_data={{
                                name: "Rock", 
                                amount: Math.floor(Math.random() * 1000), 
                                durable: true, 
                                durability: 0.7
                            }}></Item>
                        })}
                    </div>
                    <div className='hotbar-container-outer'>
                        <Hotbar></Hotbar>
                    </div>
                </div>

            </>
        )
    }
}