import React, {useState, useEffect} from 'react';
import "../styles/inventory.scss"
import OOF from "./OOF"
import MainInventory from "./MainInventory"
import InventoryViewDragSections from "./constants/InventoryViewDragSections"
import ContainerType from "./constants/ContainerType"
import DragItem from "./DragItem"
import LootView from "./LootView"
import CharacterView from "./CharacterView"
import GetItemImage from "./constants/Images"
import $ from "jquery";

export default class InventoryView extends React.Component {

    constructor (props)
    {
        super(props);
        this.state = 
        {
            container_type: ContainerType.Loot,
            selected_slot: -1,
            selected_drag_section: InventoryViewDragSections.Main,

            drag_active: false, // If the player is currently dragging an item
            drag_ready: false,
            drag_section: InventoryViewDragSections.Main, // What section the item is being dragged from
            drag_element: null,
            drag_offset: {left: 0, top: 0},
            drag_position: {left: 0, top: 0},
            drag_width: 0,
            drag_height: 0,
            drag_slot: -1, // What slot is being dragged

            // Store currently hovered slot and section
            hover_section: InventoryViewDragSections.Main,
            hover_slot: -1
        }
    }

    componentDidMount ()
    {
        OOF.CallEvent("Ready")
    }

    selectSlot (slot, drag_section)
    {
        this.setState({
            selected_slot: slot == this.state.selected_slot ? -1 : slot,
            selected_drag_section: drag_section
        })
    }

    /**
     * Called when the player stops dragging an item on mouse up.
     * @param {*} event 
     * @param {*} slot 
     */
    stopDraggingItem(event)
    {
        if (!this.state.drag_active) {return;}

        this.setState({
            drag_active: false,
            drag_ready: false,
        })

        if (this.state.drag_slot == this.state.hover_slot && this.state.drag_section == this.state.hover_section)
        {
            // Dragged item to same slot and section, so don't do anything
            return;
        }

        console.log(`Dragged from ${this.state.drag_slot} ${this.state.drag_section} to ${this.state.hover_slot} ${this.state.hover_section}`);

        if (this.state.hover_slot == -1)
        {
            // Drop on ground

            return;
        }

        if (this.state.hover_section == InventoryViewDragSections.Main)
        {
            // Dragged item on main inventory
        }
        else if (this.state.hover_section == InventoryViewDragSections.Character)
        {
            // Dragged item on character slots   
        }
        else if (this.state.hover_section == InventoryViewDragSections.Hotbar)
        {
            // Dragged item on hotbar slots
        }
        else if (this.state.hover_section == InventoryViewDragSections.Loot)
        {
            // Dragged item on loot slots
        }

    }

    setHoveredSlotAndSection(slot, section)
    {
        this.setState({
            hover_slot: slot,
            hover_section: section
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
        if (this.state.drag_active) {return;}

        // TODO: check if this is an empty slot. If so, do not drag
        // console.log("startDraggingItem");
        // console.log(event);

        // jQuery could be replaced with a pure DOM/React solution
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
                <div className='inv-section'>
                    <CharacterView
                        setHoveredSlotAndSection={this.setHoveredSlotAndSection.bind(this)}
                        startDraggingItem={this.startDraggingItem.bind(this)}
                        selectSlot={this.selectSlot.bind(this)}
                        selectedSlot={this.state.selected_slot}
                        selectedDragSection={this.state.selected_drag_section}
                    ></CharacterView>
                </div>

                {/* Inventory + hotbar section */}
                <div className='inv-section'>
                    <MainInventory
                        setHoveredSlotAndSection={this.setHoveredSlotAndSection.bind(this)}
                        startDraggingItem={this.startDraggingItem.bind(this)}
                        selectSlot={this.selectSlot.bind(this)}
                        selectedSlot={this.state.selected_slot}
                        selectedDragSection={this.state.selected_drag_section}
                    ></MainInventory>
                </div>

                {/* Loot/quick craft/Other section */}
                <div className='inv-section'>
                    {/* Render display depending on state - lootbox type, workbench, etc */}
                    {this.state.container_type == ContainerType.Loot && 
                        <LootView
                            setHoveredSlotAndSection={this.setHoveredSlotAndSection.bind(this)}
                            startDraggingItem={this.startDraggingItem.bind(this)}
                            selectSlot={this.selectSlot.bind(this)}
                            selectedSlot={this.state.selected_slot}
                            selectedDragSection={this.state.selected_drag_section}
                        ></LootView>}
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