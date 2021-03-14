import React, {useState, useEffect} from 'react';
import "../styles/item.scss"
import GetItemImage from "./constants/Images"

// It's technically an item stack but one class should suffice
export default class Item extends React.Component {

    constructor (props)
    {
        super(props);
        this.state = 
        {
            hovered: false
        }
    }

    shouldComponentUpdate(nextProps, nextState)
    {
        let shouldUpdate = false;

        // Selected props updated
        shouldUpdate = shouldUpdate || nextProps.selected != this.props.selected;

        // Item data updated
        shouldUpdate = shouldUpdate || JSON.stringify(this.props.stack) != JSON.stringify(nextProps.stack);

        // Hovered internal state changed
        shouldUpdate = shouldUpdate || nextState.hovered != this.state.hovered;

        return shouldUpdate;
    }

    hoverItem(hovered)
    {
        if (!this.props.open) {return;}

        this.setState({hovered: hovered})
        this.props.setHoveredSlotAndSection(hovered ? this.props.slot : -1, this.props.drag_section)
    }

    // Helper function to ensure this still works if no item data is passed in
    getItem(stack)
    {
        return (typeof stack != 'undefined' && typeof stack.contents != 'undefined' && typeof stack.contents[0] != 'undefined') 
            ? stack.contents[0] : {};
    }

    getDurabilityPercent(_item)
    {
        const item = this.getItem(_item);
        return item.durability / item.max_durability;
    }

    getStackAmount()
    {
        if (typeof this.props.stack != 'undefined')
        {
            return this.props.stack.contents[0].amount
        }

        return 0
    }

    render () {
        return (
            <>
                <div className={`item-container ${this.props.selected ? 'selected' : ''}`}>

                    <div className='grab-container'
                    onMouseOver={() => this.hoverItem(true)}
                    onMouseOut={() => this.hoverItem(false)}
                    onMouseUp={(e) => this.props.itemMouseUp(e, this.props.slot)}
                    onMouseDown={(e) => this.props.itemMouseDown(e, this.props.slot)}></div>

                    {/* Use an inner container to have a hover animation without messing with the hover events */}
                    <div className={`innner-hover-container ${this.state.hovered ? 'hovered' : ''}`}>
                        {/* Durability bar on the left */}
                        {this.getItem(this.props.stack).durable && 
                            <div className='durability'>
                                <div className='durability-inner' style={{height: `${this.getDurabilityPercent(this.props.stack) * 100}%`}}></div>
                            </div>
                        }

                        {/* Item amount, if greater than 1 */}
                        {this.getStackAmount() > 1 && 
                            <div className='amount'>x{this.getStackAmount()}</div>
                        }

                        {/* Item Image */}
                        <img src={GetItemImage(this.getItem(this.props.stack).name)} className='item-image'></img>
                        
                    </div>
                </div>
            </>
        )
    }
}