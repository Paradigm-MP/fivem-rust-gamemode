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
        shouldUpdate = shouldUpdate || JSON.stringify(this.props.item_data) != JSON.stringify(nextProps.item_data);

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
    getItem(item)
    {
        return item || {};
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
                        {this.getItem(this.props.item_data).durable && 
                            <div className='durability'>
                                <div className='durability-inner' style={{height: `${this.getItem(this.props.item_data).durability * 100}%`}}></div>
                            </div>
                        }

                        {/* Item amount, if greater than 1 */}
                        {this.getItem(this.props.item_data).amount > 1 && 
                            <div className='amount'>x{this.props.item_data.amount}</div>
                        }

                        {/* Item Image */}
                        <img src={GetItemImage(this.getItem(this.props.item_data).name)} className='item-image'></img>
                        
                    </div>
                </div>
            </>
        )
    }
}