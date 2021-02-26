import React, {useState, useEffect} from 'react';
import "../styles/app.scss"

import InventoryView from "./InventoryView"
import CraftingView from "./CraftingView"
import Views from "./constants/Views"
import OOF from "./OOF"

export default class App extends React.Component {

    constructor (props)
    {
        super(props);
        this.view = Views.InventoryView
    }

    componentDidMount ()
    {
        // Call OOF ready event at end of mounting finish
        OOF.CallEvent("Ready");
    }


    render () {
        return (
            <>
                <div className="background">
                    {this.view == Views.InventoryView && <InventoryView></InventoryView>}
                    {this.view == Views.CraftingView && <CraftingView></CraftingView>}
                </div>
            </>
        )
    }
}