package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.controller.events.ChangeEmitterInFocusEvent;
import com.funkypandagame.stardust.controller.events.StartSimEvent;
import com.funkypandagame.stardust.controller.events.UpdateEmitterDropDownListEvent;
import com.funkypandagame.stardust.model.ProjectModel;

import flash.events.EventDispatcher;

public class ChangeEmitterInFocusCommand
{
    private var _bus:EventDispatcher;
    private var _project:ProjectModel;
    private var _event:ChangeEmitterInFocusEvent;

    public function ChangeEmitterInFocusCommand(bus:EventDispatcher, project:ProjectModel, event:ChangeEmitterInFocusEvent)
    {
        _bus = bus;
        _project = project;
        _event = event;
    }

    public function execute():void
    {
        _project.emitterInFocus = _event.emitter;
        _bus.dispatchEvent(new UpdateEmitterDropDownListEvent(UpdateEmitterDropDownListEvent.UPDATE));
        _bus.dispatchEvent(new StartSimEvent());
    }
}
}
