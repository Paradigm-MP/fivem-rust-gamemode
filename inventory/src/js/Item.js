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
            item_data: props.item_data || {}
        }
    }

    hoverItem(hovered)
    {
        this.props.setHoveredSlotAndSection(hovered ? this.props.slot : -1, this.props.drag_section)
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

                    {/* Durability bar on the left */}
                    {this.state.item_data.durable && 
                        <div className='durability'>
                            <div className='durability-inner' style={{height: `${this.state.item_data.durability * 100}%`}}></div>
                        </div>
                    }

                    {/* Item amount, if greater than 1 */}
                    {this.state.item_data.amount > 1 && 
                        <div className='amount'>x{this.state.item_data.amount}</div>
                    }

                    {/* Item Image */}
                    <img src={GetItemImage(this.state.item_data.name)} className='item-image'></img>
                </div>
            </>
        )
    }
}