import React, {useState, useEffect} from 'react';
import "../styles/inventory.scss"
import OOF from "./OOF"
import MainInventory from "./MainInventory"

export default class InventoryView extends React.Component {

    constructor (props)
    {
        super(props);
    }

    componentDidMount ()
    {
        OOF.Subscribe("")


        OOF.CallEvent("Ready")
    }


    render () {
        return (
            <>
                {/* Character section */}
                <div className='inv-section'></div>

                {/* Inventory + hotbar section */}
                <div className='inv-section'>
                    <MainInventory></MainInventory>
                </div>

                {/* Loot/quick craft/Other section */}
                <div className='inv-section'>
                    {/* Render display depending on state - lootbox type, workbench, etc */}
                </div>
            </>
        )
    }
}