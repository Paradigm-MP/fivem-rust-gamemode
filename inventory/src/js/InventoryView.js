import React, {useState, useEffect} from 'react';
import "../styles/inventory.scss"
import OOF from "./OOF"
import MainInventory from "./MainInventory"
import InventorySections from "./constants/InventorySections"
import ContainerType from "./constants/ContainerType"
import DragItem from "./DragItem"
import LootView from "./LootView"
import CharacterView from "./CharacterView"
import ItemInfo from "./ItemInfo"
import $ from "jquery";

export default class InventoryView extends React.Component {

    constructor (props)
    {
        super(props);
        this.state = 
        {
            // Inventories
            inventory: 
            {
                [InventorySections.Main]: {},
                [InventorySections.Hotbar]: {},
                [InventorySections.Loot]: {},
                [InventorySections.Character]: {},
                [InventorySections.ItemInfo]: {}
            },

            // Currently opened type of container, if any (right side)
            container_type: ContainerType.Loot,

            selected_slot: -1,
            selected_drag_section: InventorySections.Main,

            // Current equipped hotbar slot
            equipped_hotbar_slot: -1,

            // Current split amount used in ItemInfo
            split_amount: 0,

            drag_active: false, // If the player is currently dragging an item
            drag_ready: false,
            drag_section: InventorySections.Main, // What section the item is being dragged from
            drag_element: null,
            drag_offset: {left: 0, top: 0},
            drag_position: {left: 0, top: 0},
            drag_width: 0,
            drag_height: 0,
            drag_slot: -1, // What slot is being dragged

            // Store currently hovered slot and section
            hover_section: InventorySections.Main,
            hover_slot: -1
        }
    }

    componentDidUpdate(prevProps, prevState)
    {
        // Disable dragging once inventory is closed
        if (this.props.open && this.state.drag_active && !prevProps.open)
        {
            this.setState({
                drag_active: false,
                drag_ready: false
            })
        }

        if (!this.props.open && prevProps.open)
        {
            // Reset selected slot if hotbar is selected
            if (this.state.selected_drag_section == InventorySections.Hotbar
                && this.state.selected_slot != this.state.equipped_hotbar_slot)
            {
                this.setState({
                    selected_drag_section: InventorySections.Main,
                    selected_slot: -1
                })
            }
        }
    }

    componentDidMount ()
    {
        OOF.Subscribe("InventoryUpdated", (args) => 
        {
            if (args.action == "full")
            {
                const contents = {}

                // Parse contents back into a table/map/dict
                args.data.contents.forEach((sync_object) => {
                    contents[sync_object.index] = sync_object;
                });

                args.data.contents = contents;

                this.fullInventorySync(args);
            }
            else if (args.action == "swap")
            {
                this.inventorySwapped(args)
            }
            else if (args.action == "update")
            {
                this.inventoryUpdated(args)
            }
            else if (args.action == "remove")
            {
                this.inventoryRemoved(args)
            }

        })

        OOF.Subscribe("Inventory/SelectHotbar", (args) => 
        {
            this.setState({
                equipped_hotbar_slot: args.index
            })
        })

        OOF.CallEvent("Inventory/Ready")
    }

    // Called when a player clicks to perform an action from the ItemInfo section (such as Drop)
    clickItemAction(action)
    {
        if (typeof this.action_timer == 'undefined')
        {
            OOF.CallEvent("Inventory/DoAction",
            {
                index: this.state.selected_slot,
                section: this.state.selected_drag_section,
                amount: this.state.split_amount,
                action: action
            })

            this.action_timer = setTimeout(() => {
                this.action_timer = undefined;
            }, 1000);
        }

    }

    inventorySwapped(args)
    {
        const copy = this.getInventoryCopy();
        const stack = copy[args.section][args.from];
        copy[args.section][args.from] = copy[args.section][args.to];
        copy[args.section][args.to] = stack;
        copy[InventorySections.ItemInfo][0] = copy[this.state.selected_drag_section][this.state.selected_slot];

        this.setState({
            inventory: copy,
            selectedSlot: args.to
        })
    }

    inventoryUpdated(args)
    {
        const copy = this.getInventoryCopy();
        copy[args.section][args.index] = args.stack;
        copy[InventorySections.ItemInfo][0] = copy[this.state.selected_drag_section][this.state.selected_slot];
        
        let split_amount = this.state.split_amount;
        if (args.section == this.state.selected_drag_section
            && args.index == this.state.selected_slot)
        {
            split_amount = Math.ceil(args.stack.contents[0].amount / 2);
        }

        this.setState({
            inventory: copy,
            split_amount: split_amount
        })
    }

    inventoryRemoved(args)
    {
        const copy = this.getInventoryCopy();
        delete copy[args.section][args.index];
        copy[InventorySections.ItemInfo][0] = copy[this.state.selected_drag_section][this.state.selected_slot];
        
        this.setState({
            inventory: copy
        })
    }

    // Called when an entire inventory syncs
    fullInventorySync(args)
    {
        const copy = this.getInventoryCopy();
        copy[args.data.type] = args.data.contents;

        this.setState({
            inventory: copy
        })
    }

    getInventoryCopy()
    {
        return JSON.parse(JSON.stringify(this.state.inventory))
    }

    setSplitAmount(amount)
    {
        if (!this.props.open) {return;}

        this.setState({
            split_amount: amount
        })
    }

    selectSlot (slot, drag_section)
    {
        if (!this.props.open) {return;}

        // Cannot select item info section, only drag
        if (drag_section == InventorySections.ItemInfo) {return;}

        // Disable selecting slots while dragging
        if (this.state.drag_active) {return;}

        const inventory_copy = this.getInventoryCopy();
        inventory_copy[InventorySections.ItemInfo][0] = inventory_copy[drag_section][slot];

        this.setState({
            selected_slot: slot == this.state.selected_slot ? -1 : slot,
            selected_drag_section: drag_section,
            inventory: inventory_copy
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

        // console.log(`Dragged from ${this.state.drag_slot} ${this.state.drag_section} to ${this.state.hover_slot} ${this.state.hover_section}`);

        if (this.state.hover_slot == -1)
        {
            // Drop on ground
            OOF.CallEvent("Inventory/DropStack",
            {
                index: this.state.drag_slot,
                section: this.state.drag_section
            })
            return;
        }

        let dragged_item = this.state.inventory[this.state.drag_section][this.state.drag_slot];

        // They dragged an empty slot, so return
        if (!dragged_item) {return;}

        if (this.state.hover_section == InventorySections.ItemInfo) {return;}

        if (this.state.drag_section == InventorySections.ItemInfo
            && (this.state.hover_section == InventorySections.Main
                || this.state.hover_section == InventorySections.Hotbar))
        {
            // Non-empty space
            if (typeof this.state.inventory[this.state.hover_section][this.state.hover_slot] != 'undefined')
            {
                return;
            }

            // Dragged from ItemInfo to Main inventory
            // Split the stack based on split amount  
            OOF.CallEvent("Inventory/SplitStack", 
            {
                index: this.state.hover_slot,
                to_section: this.state.hover_section,
                base_index: this.state.selected_slot,
                base_section: this.state.selected_drag_section,
                amount: this.state.split_amount
            }) 
        }
        else
        {
            // Dragging a non-equippable item to the Character section
            if (this.state.hover_section == InventorySections.Character &&
                !dragged_item.contents[0].can_equip) {return;}

            OOF.CallEvent("Inventory/DragItem", 
            {
                from_section: this.state.drag_section,
                from_slot: this.state.drag_slot,
                to_section: this.state.hover_section,
                to_slot: this.state.hover_slot
            })
        }
    }

    setHoveredSlotAndSection(slot, section)
    {
        if (!this.props.open) {return;}

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
        if (!this.props.open) {return;}

        if (this.state.drag_active) {return;}

        // Check if they are dragging an empty slot
        const dragged_item = this.state.inventory[drag_section][slot];
        if (!dragged_item) {return}

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
        if (!this.props.open) {return;}

        this.setState({
            drag_ready: false,
            mouse_down: false
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

    onMouseDown (event)
    {
        if (!this.props.open) {return;}

        this.setState({
            mouse_down: true
        })
    }

    onMouseMove (event)
    {
        if (!this.props.open) {return;}

        if (!this.state.drag_active && this.state.drag_ready)
        {
            // Small threshold for clicking items
            if (Math.abs(this.state.drag_position.left - event.clientX) > this.state.drag_width * 0.1
            || Math.abs(this.state.drag_position.top - event.clientY) > this.state.drag_width * 0.1)
            {
                this.setState({
                    drag_active: true
                })
            }
        }

        if (this.state.drag_active)
        {
            this.setState({
                drag_position: {left: event.clientX, top: event.clientY}
            })
        }
    }

    getSelectedStack()
    {
        if (this.state.selected_slot != -1 && this.state.selected_drag_section != -1)
        {
            return this.state.inventory[this.state.selected_drag_section][this.state.selected_slot];
        }
    }

    getDraggingStack()
    {
        if (this.state.drag_slot != -1 && this.state.drag_section != -1)
        {
            return this.state.inventory[this.state.drag_section][this.state.drag_slot];
        }
    }

    render () {
        return (
            <div 
            className='inventory-view-container'
            onMouseDown={(e) => this.onMouseDown(e)}
            onMouseUp={(e) => this.onMouseUp(e)}
            onMouseMove={(e) => this.onMouseMove(e)}
            >

                {/* Character section */}
                <div className='inv-section'>
                    {this.props.open && <CharacterView
                        setHoveredSlotAndSection={this.setHoveredSlotAndSection.bind(this)}
                        startDraggingItem={this.startDraggingItem.bind(this)}
                        selectSlot={this.selectSlot.bind(this)}
                        selectedSlot={this.state.selected_slot}
                        selectedDragSection={this.state.selected_drag_section}
                        contents={this.state.inventory[InventorySections.Character]}
                        {...this.props}
                    ></CharacterView>}
                </div>

                {/* Item Info + Inventory + hotbar section */}
                <div className='inv-section'>
                    
                    <div className='middle-section-container-relative'>
                        <div className='middle-section-container-bottom'>
                            {this.props.open && typeof this.getSelectedStack() != 'undefined' &&
                                <ItemInfo
                                    setHoveredSlotAndSection={this.setHoveredSlotAndSection.bind(this)}
                                    startDraggingItem={this.startDraggingItem.bind(this)}
                                    selectSlot={this.selectSlot.bind(this)}
                                    selectedSlot={this.state.selected_slot}
                                    selectedDragSection={this.state.selected_drag_section}
                                    stack={this.getSelectedStack()}
                                    setSplitAmount={this.setSplitAmount.bind(this)}
                                    split_amount={this.state.split_amount}
                                    mouse_down={this.state.mouse_down}
                                    clickItemAction={this.clickItemAction.bind(this)}
                                ></ItemInfo>}

                            <MainInventory
                                setHoveredSlotAndSection={this.setHoveredSlotAndSection.bind(this)}
                                startDraggingItem={this.startDraggingItem.bind(this)}
                                selectSlot={this.selectSlot.bind(this)}
                                selectedSlot={this.state.selected_slot}
                                selectedDragSection={this.state.selected_drag_section}
                                contents={this.state.inventory[InventorySections.Main]}
                                contents_hotbar={this.state.inventory[InventorySections.Hotbar]}
                                equipped_hotbar_slot={this.state.equipped_hotbar_slot}
                                {...this.props}
                            ></MainInventory>
                        </div>
                    </div>
                </div>

                {/* Loot/quick craft/Other section */}
                <div className='inv-section'>
                    {/* Render display depending on state - lootbox type, workbench, etc */}
                    {this.props.open && this.state.container_type == ContainerType.Loot && 
                        <LootView
                            setHoveredSlotAndSection={this.setHoveredSlotAndSection.bind(this)}
                            startDraggingItem={this.startDraggingItem.bind(this)}
                            selectSlot={this.selectSlot.bind(this)}
                            selectedSlot={this.state.selected_slot}
                            selectedDragSection={this.state.selected_drag_section}
                            contents={this.state.inventory[InventorySections.Loot]}
                            {...this.props}
                        ></LootView>}
                </div>
                
                {/* Dragging item display */}
                {this.state.drag_active && this.props.open && 
                    <DragItem 
                        name={this.getDraggingStack().contents[0].name}
                        offset={this.state.drag_offset} 
                        position={this.state.drag_position}
                        width={this.state.drag_width} 
                        height={this.state.drag_height}></DragItem>
                }
            </div>
        )
    }
}