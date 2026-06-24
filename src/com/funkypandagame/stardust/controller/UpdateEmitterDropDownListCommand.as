package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.controller.events.SetResultsForEmitterDropDownListEvent;
import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardustplayer.emitter.EmitterValueObject;

import flash.events.EventDispatcher;

public class UpdateEmitterDropDownListCommand
{
    private var _bus:EventDispatcher;
    private var _project:ProjectModel;

    public function UpdateEmitterDropDownListCommand(bus:EventDispatcher, project:ProjectModel)
    {
        _bus = bus;
        _project = project;
    }

    public function execute():void
    {
        if (_project.stadustSim == null || _project.emitterInFocus == null) return;
        var list:Array = [];
        for each (var emitterVO:EmitterValueObject in _project.stadustSim.emitters)
            list.push(emitterVO);
        _bus.dispatchEvent(new SetResultsForEmitterDropDownListEvent(SetResultsForEmitterDropDownListEvent.UPDATE, list, _project.emitterInFocus));
    }
}
}
