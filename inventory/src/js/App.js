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

        this.state = 
        {
            view: Views.InventoryView, // Current view that is open
            open: false // If the view/inventory is open
        }

        this.view = Views.InventoryView
    }

    componentDidMount ()
    {
        document.addEventListener("keydown", (e) => 
        {
            this.onKeyDown(e);
        }, false);

        // Call OOF ready event at end of mounting finish
        OOF.CallEvent("Ready");
    }
    
    componentWillUnmount()
    {
        document.removeEventListener("keydown", (e) => 
        {
            this.onKeyDown(e);
        }, false);
    }

    onKeyDown (e)
    {
        if (e.key == "Tab")
        {
            this.setState({
                open: !this.state.open
            })
        }
    }

    render () {
        return (
            <>
                <div className="background">
                    {this.view == Views.InventoryView && <InventoryView open={this.state.open}></InventoryView>}
                    {this.view == Views.CraftingView && <CraftingView open={this.state.open}></CraftingView>}
                </div>
            </>
        )
    }
}