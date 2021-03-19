import React, {useState, useEffect} from 'react';
import "../styles/look_at_item_view.scss"
import Localizations from "./locale/common"
import OOF from "./OOF"

export default class LookAtItemView extends React.Component {

    constructor (props)
    {
        super(props);

        this.state = 
        {
            lookat_name: null,
            lookat_amount: 0,
            active: false
        }
    }

    componentDidMount()
    {
        OOF.Subscribe('UpdateLookAtItem', (args) => 
        {
            if (args.active)
            {
                this.setState({
                    lookat_name: args.name,
                    lookat_amount: args.amount,
                    active: true
                })
            }
            else
            {
                this.setState({
                    active: false
                })
            }
        })
    }

    getAmountString()
    {
        return this.state.lookat_amount > 1 ?
            `x${this.state.lookat_amount}` : 
            ``
    }

    render () {
        return (
            <>
                {(!this.props.open && this.state.active) && <div className={`look-at-item-container`}>
                    <img src={`./images/hand.png`} className='icon'></img>
                    <div className='text'><div className='item-name'>{Localizations.GetItemName(this.state.lookat_name)}</div> {this.getAmountString()}</div>
                </div>}
            </>
        )
    }
}