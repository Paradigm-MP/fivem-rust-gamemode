import React, {useState, useEffect} from 'react';
import "../styles/inventory.scss"
import OOF from "./OOF"
import MainInventory from "./MainInventory"
import InventoryViewDragSections from "./constants/InventoryViewDragSections"
import DragItem from "./DragItem"
import GetItemImage from "./constants/Images"
import $ from "jquery";

export default class InventoryView extends React.Component {

    constructor (props)
    {
        super(props);
        this.state = 
        {
            drag_active: false, // If the player is currently dragging an item
            drag_ready: false,
            drag_section: InventoryViewDragSections.Main, // What section the item is being dragged from
            drag_element: null,
            drag_offset: {left: 0, top: 0},
            drag_position: {left: 0, top: 0},
            drag_width: 0,
            drag_height: 0,
            drag_slot: -1 // What slot is being dragged
        }
    }

    componentDidMount ()
    {
        OOF.Subscribe("")


        OOF.CallEvent("Ready")
    }

    /**
     * Called when the player stops dragging an item on mouse up.
     * @param {*} event 
     * @param {*} slot 
     */
    stopDraggingItem(event)
    {
        if (!this.state.drag_active) {return;}

        console.log("stopDraggingItem");
        console.log(event);

        if (event.target == this.state.drag_element)
        {
            // Dragged it onto the same slot
            console.log("Same")
        }
        else
        {
            // Dragged it into a different slot
            console.log("Different")
        }

        this.setState({
            drag_active: false,
            drag_ready: false
        })
    }

    /**
     * Called when the player presses the mouse down on an item.
     * @param {*} event 
     * @param {*} slot 
     * @param {*} drag_section 
     */
    startDraggingItem (event, slot, drag_section)
    {
        // TODO: check if this is an empty slot. If so, do not drag
        console.log("startDraggingItem");
        console.log(event);
        const element_offset = $(event.target).offset();
        const offset = {left: element_offset.left - event.clientX, top: element_offset.top - event.clientY}
        this.setState({
            drag_active: false,
            drag_ready: true,
            drag_moved: false,
            drag_section: drag_section,
            drag_slot: slot,
            drag_offset: offset,
            drag_position: {left: event.clientX, top: event.clientY},
            drag_width: $(event.target).width(),
            drag_height: $(event.target).height(),
            drag_element: event.target
        })
    }

    /**
     * General mouseup event for the entire container
     * @param {*} event 
     */
    onMouseUp (event)
    {
        this.setState({
            drag_ready: false
        })

        if (this.state.drag_active)
        {
            this.stopDraggingItem(event);
            this.setState({
                drag_active: false,
                drag_ready: false
            })
        }
    }

    onMouseMove (event)
    {
        if (!this.state.drag_active && this.state.drag_ready)
        {
            this.setState({
                drag_active: true
            })
        }

        if (this.state.drag_active)
        {
            this.setState({
                drag_position: {left: event.clientX, top: event.clientY}
            })
        }
    }

    render () {
        return (
            <div 
            className='inventory-view-container'
            onMouseUp={(e) => this.onMouseUp(e)}
            onMouseMove={(e) => this.onMouseMove(e)}
            >

                {/* Character section */}
                <div className='inv-section'></div>

                {/* Inventory + hotbar section */}
                <div className='inv-section'>
                    <MainInventory
                        startDraggingItem={this.startDraggingItem.bind(this)}
                        stopDraggingItem={this.stopDraggingItem.bind(this)}
                    ></MainInventory>
                </div>

                {/* Loot/quick craft/Other section */}
                <div className='inv-section'>
                    {/* Render display depending on state - lootbox type, workbench, etc */}
                </div>
                
                {/* Dragging item display */}
                {this.state.drag_active && 
                    <DragItem 
                        offset={this.state.drag_offset} 
                        position={this.state.drag_position}
                        width={this.state.drag_width} 
                        height={this.state.drag_height}></DragItem>
                }
            </div>
        )
    }
}