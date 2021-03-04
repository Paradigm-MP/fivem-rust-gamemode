import React, {useState, useEffect} from 'react';
import "../styles/character_view.scss"
import Item from "./Item"
import InventorySections from "./constants/InventorySections"

export default class CharacterView extends React.Component {

    constructor (props)
    {
        super(props);

        this.num_slots = 7;
        this.drag_section = InventorySections.Character;
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
                <div className='main-character-container'>
                    <div className='items-container'>
                        {[...Array(this.num_slots)].map((value, index) => 
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
                </div>

            </>
        )
    }
}