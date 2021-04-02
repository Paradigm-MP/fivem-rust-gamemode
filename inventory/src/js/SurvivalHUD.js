import React, {useState, useEffect} from 'react';
import "../styles/survival_hud.scss"
import Localizations from "./locale/common"
import OOF from "./OOF"

export default class SurvivalHUD extends React.Component {

    constructor (props)
    {
        super(props);

        this.state = 
        {
            health: 0.75,
            hunger: 0.75,
            thirst: 0.75
        }
    }

    componentDidMount()
    {
        OOF.Subscribe("Inventory/SurvivalHUD/UpdateHealth", (args) => 
        {
            this.setState({
                health: args.health
            })
        })
    }

    formatNumber(number)
    {
        return (number * 100).toFixed(0)
    }

    render () {
        return (
            <>
                <div className='survival-hud-container'>
                    <div className='inner-container'>
                        <div className='stat-container'>
                            <img src={`./images/health.png`} className='icon'></img>
                            <div className='text-and-fill-container'>
                                <div className='fill green' style={{width: `${this.state.health * 100}%`}}></div>
                                <div className='text'>{this.formatNumber(this.state.health)}</div>
                            </div>
                        </div>
                        <div className='stat-container'>
                            <img src={`./images/thirst.png`} className='icon'></img>
                            <div className='text-and-fill-container'>
                                <div className='fill blue' style={{width: `${this.state.thirst * 100}%`}}></div>
                                <div className='text'>{this.formatNumber(this.state.thirst)}</div>
                            </div>
                        </div>
                        <div className='stat-container'>
                            <img src={`./images/eat.png`} className='icon'></img>
                            <div className='text-and-fill-container'>
                                <div className='fill orange' style={{width: `${this.state.hunger * 100}%`}}></div>
                                <div className='text'>{this.formatNumber(this.state.hunger)}</div>
                            </div>
                        </div>
                    </div>
                </div>
            </>
        )
    }
}