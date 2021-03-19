import React, {useState, useEffect} from 'react';
import "../styles/app.scss"

import InventoryView from "./InventoryView"
import CraftingView from "./CraftingView"
import Views from "./constants/Views"
import LookAtItemView from "./LookAtItemView"
import OOF from "./OOF"
import Localizations from "./locale/common"

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

        OOF.Subscribe('Open', () => 
        {
            this.setState({
                open: !this.state.open
            })
        })

        OOF.Subscribe('Close', () => 
        {
            this.setState({
                open: !this.state.open
            })
        })

        OOF.Subscribe('SetLocale', (args) => 
        {
            Localizations.SetLocale(args.locale);
        })

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
            // KeepInput disables this, so it is only for developing right now
            this.setState({
                open: !this.state.open
            })
            OOF.CallEvent('Close')
        }
    }

    render () {
        return (
            <>
                <div className="background" style={this.state.open ? {} : {backgroundColor: `transparent`}}>
                    <LookAtItemView open={this.state.open}></LookAtItemView>
                    {this.view == Views.InventoryView && <InventoryView open={this.state.open}></InventoryView>}
                    {this.view == Views.CraftingView && <CraftingView open={this.state.open}></CraftingView>}
                </div>
            </>
        )
    }
}