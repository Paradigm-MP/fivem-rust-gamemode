import React, {useState, useEffect} from 'react';
import "../styles/item_info.scss"
import Item from "./Item"
import GetItemImage from "./constants/Images"
import InventorySections from "./constants/InventorySections"

export default class Hotbar extends React.Component {

    constructor (props)
    {
        super(props);

        this.drag_section = InventorySections.ItemInfo;
        this.slot = 0;
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
                <div className='item-info-container'>
                    <div className='description-container'>
                        <div className='description'>This is a test item description.</div>
                        <img src={GetItemImage(this.props.item_data.name)}></img>
                    </div>
                    <div className='info-actions-container'>
                        <div className='info-container'>
                            <div className='title'>Information</div>
                            <div className='content'></div>
                        </div>
                        <div className='actions-container'>
                            <div className='title'>Actions</div>
                            {/* Add buttons here */}
                        </div>
                        <div className='splitting-container'>
                            <div className='content-container'>
                                <div className='title'>
                                    <div className='title-left'>Splitting</div>
                                    <div className='title-right'>Set Amount &#38; Drag Icon</div>
                                </div>
                                <div className='slider-container'>
                                    <div className='slider'>
                                        <div className='amount-text'></div>
                                    </div>
                                </div>
                            </div>
                            <div className='drag-item-container'>
                                <Item 
                                {...this.props}
                                key={`itemslot_inv_${this.drag_section}_${this.slot}}`}
                                setHoveredSlotAndSection={this.props.setHoveredSlotAndSection}
                                itemMouseUp={this.itemMouseUp.bind(this)}
                                itemMouseDown={this.itemMouseDown.bind(this)}
                                slot={this.slot}
                                selected={this.slot == this.props.selectedSlot && this.props.selectedDragSection == this.drag_section}
                                drag_section={this.drag_section}
                                item_data={this.props.item_data}></Item>
                            </div>
                        </div>
                    </div>
                </div>
            </>
        )
    }
}