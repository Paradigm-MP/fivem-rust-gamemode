import React, {useState, useEffect} from 'react';
import "../styles/hotbar.scss"
import Item from "./Item"

export default class Hotbar extends React.Component {

    constructor (props)
    {
        super(props);
    }


    render () {
        return (
            <>
                <div className='hotbar-container'>
                    <Item></Item>
                    <Item></Item>
                    <Item></Item>
                    <Item></Item>
                    <Item></Item>
                    <Item></Item>
                </div>
            </>
        )
    }
}