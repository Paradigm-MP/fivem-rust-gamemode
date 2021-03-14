import React, {useState, useEffect} from 'react';
import "../styles/item_info.scss"
import Item from "./Item"
import GetItemImage from "./constants/Images"
import InventorySections from "./constants/InventorySections"
import $ from "jquery";

export default class ItemInfo extends React.Component {

    constructor (props)
    {
        super(props);

        this.state = 
        {
            current_slot: -1,
            current_section: InventorySections.Main,
            dragging: false,
            start_slider_x: 0,
            slider_width: 0
        }

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

    // Helper function to ensure this still works if no item data is passed in
    getItem(stack)
    {
        return (typeof stack != 'undefined') ? stack.contents[0] : {};
    }

    getDisplayItemData()
    {
        const stack = JSON.parse(JSON.stringify(this.props.stack));
        stack.contents[0].durable = false;
        stack.contents[0].amount = this.props.split_amount;
        return stack;
    }

    onComponentMountOrUpdate()
    {
        if (this.props.selectedSlot != this.state.current_slot ||
            this.props.selectedDragSection != this.state.current_section)
        {
            this.setState({
                current_slot: this.props.selectedSlot,
                current_section: this.props.selectedDragSection
            })

            this.props.setSplitAmount(Math.ceil(this.getItem(this.props.stack).amount / 2))
        }
    }

    componentDidUpdate()
    {
        this.onComponentMountOrUpdate();
    }

    componentDidMount ()
    {
        this.onComponentMountOrUpdate();
    }

    onMouseDown (event)
    {
        const $elem = $('div.item-info-container div.slider-container')
        this.setState({
            dragging: true,
            start_slider_x: $elem.offset().left,
            slider_width: $elem.width()
        })

        // Update it on a small delay to update next frame
        setTimeout(() => {
            this.updateSlider(event);
        }, 10);
    }
    
    onMouseUp (event)
    {
        this.setState({
            dragging: false
        })
    }

    onMouseMove (event)
    {
        if (!this.state.dragging) {return;}

        if (!this.props.mouse_down)
        {
            this.setState({
                dragging: false
            })
            return;
        }

        this.updateSlider(event);
    }

    updateSlider (event)
    {
        let percent = (event.clientX - this.state.start_slider_x) / this.state.slider_width;
        
        if (percent <= 0)
        {
            percent = 0.001;
        }
        else if (percent >= 1)
        {
            percent = 1;
        }
        
        const split_amount = Math.ceil(this.getItem(this.props.stack).amount * percent)

        this.props.setSplitAmount(split_amount);
    }
    
    render () {
        return (
            <>
                <div className='item-info-container'>
                    <div className='item-title'>{this.getItem(this.props.stack).name}</div>
                    <div className='description-container'>
                        <div className='description'>This is a test item description.</div>
                        <img src={GetItemImage(this.getItem(this.props.stack).name)}></img>
                    </div>
                    <div className='info-actions-container'>
                        <div className='info-container'>
                            <div className='title'>Information</div>
                            <div className='content'></div>
                        </div>
                        <div className='actions-container'>
                            <div className='title'>Actions</div>
                            <div className='content'>
                                <div className='content-abs'>
                                    {this.getItem(this.props.stack).actions && this.getItem(this.props.stack).actions.map((action) => 
                                    {
                                        return <div className='action-container' key={`item_action_${action}`}>
                                            <img src={`./images/${action}.png`} className='icon'></img>
                                            <div className='title'>{action}</div>
                                        </div>
                                    })}
                                </div>
                            </div>
                        </div>
                    </div>
                    <div className='splitting-container'>
                        <div className='content-container'>
                            <div className='title'>
                                <div className='title-left'>Splitting</div>
                                <div className='title-right'>Set Amount &#38; Drag Icon</div>
                            </div>
                            <div className='slider-container'
                            onMouseDown={(e) => this.onMouseDown(e)}
                            onMouseUp={(e) => this.onMouseUp(e)}
                            onMouseMove={(e) => this.onMouseMove(e)}>
                                <div className='slider' style={{width: `${this.props.split_amount / this.getItem(this.props.stack).amount * 100}%`}}>
                                    <div className='amount-text'>{this.props.split_amount}</div>
                                </div>
                            </div>
                        </div>
                        <div className='drag-item-container'>
                            <Item 
                            {...this.props}
                            key={`itemslot_inv_${this.drag_section}_${this.slot}`}
                            setHoveredSlotAndSection={this.props.setHoveredSlotAndSection}
                            itemMouseUp={this.itemMouseUp.bind(this)}
                            itemMouseDown={this.itemMouseDown.bind(this)}
                            slot={this.slot}
                            selected={this.slot == this.props.selectedSlot && this.props.selectedDragSection == this.drag_section}
                            drag_section={this.drag_section}
                            stack={this.getDisplayItemData()}></Item>
                        </div>
                    </div>
                </div>
            </>
        )
    }
}