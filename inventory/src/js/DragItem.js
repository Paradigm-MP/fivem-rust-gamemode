import React, {useState, useEffect} from 'react';
import "../styles/drag_item.scss"
import GetItemImage from "./constants/Images"

export default class DragItem extends React.Component {

    constructor (props)
    {
        super(props);
    }


    render () {
        return (
            <>
                <div className={`drag-item`} style={{
                    top: this.props.offset.top + this.props.position.top, 
                    left: this.props.offset.left + this.props.position.left,
                    width: this.props.width,
                    height: this.props.height
                }}>
                    {/* Item Image */}
                    <img src={GetItemImage(this.props.name)} className='item-image'></img>
                </div>
            </>
        )
    }
}