package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.controller.events.ChangeEmitterInFocusEvent;
import com.funkypandagame.stardust.controller.events.RegenerateEmitterTexturesEvent;
import com.funkypandagame.stardust.controller.events.StartSimEvent;
import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardustplayer.emitter.EmitterValueObject;
import com.funkypandagame.stardustplayer.project.ProjectValueObject;

import flash.events.EventDispatcher;

import idv.cjcat.stardustextended.actions.Action;
import idv.cjcat.stardustextended.actions.Spawn;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.handlers.starling.StarlingHandler;

public class RemoveEmitterCommand
{
    private var _bus:EventDispatcher;
    private var _projectModel:ProjectModel;

    public function RemoveEmitterCommand(bus:EventDispatcher, model:ProjectModel)
    {
        _bus = bus;
        _projectModel = model;
    }

    public function execute():void
    {
        const projectObj:ProjectValueObject = _projectModel.stadustSim;
        if (projectObj.numberOfEmitters <= 1) return;

        for each (var em:Emitter in _projectModel.stadustSim.emittersArr)
        {
            for each (var action:Action in em.actions)
            {
                if (action is Spawn && Spawn(action).spawnerEmitterId == _projectModel.emitterInFocus.id)
                    Spawn(action).spawnerEmitter = null;
            }
        }

        StarlingHandler(_projectModel.emitterInFocus.emitter.particleHandler).dispose();

        delete _projectModel.stadustSim.emitters[_projectModel.emitterInFocus.id];
        delete _projectModel.emitterImages[_projectModel.emitterInFocus.id];

        for each (var remaining:EmitterValueObject in _projectModel.stadustSim.emitters)
        {
            _bus.dispatchEvent(new ChangeEmitterInFocusEvent(ChangeEmitterInFocusEvent.CHANGE, remaining));
            break;
        }

        _bus.dispatchEvent(new RegenerateEmitterTexturesEvent());
        _bus.dispatchEvent(new StartSimEvent());
    }
}
}
