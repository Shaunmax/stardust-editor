package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.controller.events.InitCompleteEvent;
import com.funkypandagame.stardust.controller.events.InitalizeZoneDrawerEvent;
import com.funkypandagame.stardust.controller.events.SetClockEvent;
import com.funkypandagame.stardust.controller.events.SetParticleHandlerEvent;
import com.funkypandagame.stardust.controller.events.UpdateEmitterDropDownListEvent;
import com.funkypandagame.stardust.controller.events.UpdateEmitterFromViewUICollectionsEvent;
import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardustplayer.emitter.EmitterValueObject;

import flash.events.EventDispatcher;

import idv.cjcat.stardustextended.handlers.starling.StarlingHandler;

import starling.core.Starling;

public class StartSimCommand
{
    private var _bus:EventDispatcher;
    private var _project:ProjectModel;
    private var _mainLoop:MainEnterFrameLoopService;

    public function StartSimCommand(bus:EventDispatcher, project:ProjectModel, mainLoop:MainEnterFrameLoopService)
    {
        _bus = bus;
        _project = project;
        _mainLoop = mainLoop;
    }

    public function execute():void
    {
        _project.stadustSim.resetSimulation();
        _mainLoop.calcTime = 0;

        _bus.dispatchEvent(new SetClockEvent());
        _bus.dispatchEvent(new UpdateEmitterDropDownListEvent(UpdateEmitterDropDownListEvent.UPDATE));
        _bus.dispatchEvent(new InitalizeZoneDrawerEvent(InitalizeZoneDrawerEvent.RESET));
        if (_project.emitterInFocus != null)
        {
            _bus.dispatchEvent(new UpdateEmitterFromViewUICollectionsEvent(UpdateEmitterFromViewUICollectionsEvent.UPDATE, _project.emitterInFocus));
            _bus.dispatchEvent(new SetParticleHandlerEvent(StarlingHandler(_project.emitterInFocus.emitter.particleHandler)));
        }

        for each (var emitterVO:EmitterValueObject in _project.stadustSim.emitters)
        {
            if (emitterVO.emitterSnapshot)
                emitterVO.addParticlesFromSnapshot();
        }
        _bus.dispatchEvent(new InitCompleteEvent());
    }
}
}
