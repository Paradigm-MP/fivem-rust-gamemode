import React, {useState, useEffect} from 'react';
import "../styles/main_inventory.scss"
import "./Hotbar"
import Item from "./Item"
import Hotbar from './Hotbar';

export default class MainInventory extends React.Component {

    constructor (props)
    {
        super(props);
    }


    render () {
        return (
            <>
                <div className='main-inventory-container'>
                    <div className='title'>Inventory</div>
                    <div className='inventory-items-container'>
                        <Item></Item>
                        <Item></Item>
                        <Item></Item>
                        <Item></Item>
                        <Item></Item>
                        <Item></Item>
                        
                        <Item></Item>
                        <Item></Item>
                        <Item></Item>
                        <Item></Item>
                        <Item></Item>
                        <Item></Item>
                        
                        <Item></Item>
                        <Item></Item>
                        <Item></Item>
                        <Item></Item>
                        <Item></Item>
                        <Item></Item>
                        
                        <Item></Item>
                        <Item></Item>
                        <Item></Item>
                        <Item></Item>
                        <Item></Item>
                        <Item></Item>
                    </div>
                    <div className='hotbar-container-outer'>
                        <Hotbar></Hotbar>
                    </div>
                </div>

            </>
        )
    }
}