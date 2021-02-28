import React, {useState, useEffect} from 'react';
import "../styles/loot_view.scss"
import Item from "./Item"
import InventoryViewDragSections from "./constants/InventoryViewDragSections"

export default class LootView extends React.Component {

    constructor (props)
    {
        super(props);

        this.state = 
        {
            num_slots: 12
        }

        this.drag_section = InventoryViewDragSections.Loot;
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
                <div className='main-loot-container'>
                    <div className='title'>Loot</div>
                    <div className='items-container'>
                        {/* TODO: replace this generic array with the actual loot */}
                        {[...Array(this.state.num_slots)].map((value, index) => 
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
                                amount: Math.floor(Math.random() * 5), 
                                durable: true, 
                                durability: Math.random()
                            }}></Item>
                        })}
                    </div>
                    {/* Only show hotbar if it is the body of a player */}
                    {/* <div className='hotbar-container-outer'>
                        <Hotbar
                            {...this.props}
                        ></Hotbar>
                    </div> */}
                </div>

            </>
        )
    }
}