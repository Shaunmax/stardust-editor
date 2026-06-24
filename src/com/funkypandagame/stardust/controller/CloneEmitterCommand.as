package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.controller.events.ChangeEmitterInFocusEvent;
import com.funkypandagame.stardust.controller.events.RegenerateEmitterTexturesEvent;
import com.funkypandagame.stardust.controller.events.StartSimEvent;
import com.funkypandagame.stardust.helpers.Globals;
import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardustplayer.emitter.EmitterBuilder;
import com.funkypandagame.stardustplayer.emitter.EmitterValueObject;

import flash.display.BitmapData;
import flash.events.EventDispatcher;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.handlers.starling.StarlingHandler;
import idv.cjcat.stardustextended.xml.XMLBuilder;

import starling.display.BlendMode;

public class CloneEmitterCommand
{
    private var _bus:EventDispatcher;
    private var _projectModel:ProjectModel;

    public function CloneEmitterCommand(bus:EventDispatcher, model:ProjectModel)
    {
        _bus = bus;
        _projectModel = model;
    }

    public function execute():void
    {
        var uniqueID:uint = 0;
        while (_projectModel.stadustSim.emitters[uniqueID]) uniqueID++;

        var xml:XML = XMLBuilder.buildXML(_projectModel.emitterInFocus.emitter);
        var clonedEmitter:Emitter = EmitterBuilder.buildEmitter(xml, uniqueID.toString());
        clonedEmitter.name = uniqueID.toString();

        const emitterData:EmitterValueObject = new EmitterValueObject(clonedEmitter);
        _projectModel.stadustSim.emitters[emitterData.id] = emitterData;

        var sourceImages:Vector.<BitmapData> = _projectModel.emitterImages[_projectModel.emitterInFocus.id];
        _projectModel.emitterImages[emitterData.id] = sourceImages.concat();

        var starlingHandler:StarlingHandler = new StarlingHandler();
        starlingHandler.blendMode = BlendMode.NORMAL;
        starlingHandler.spriteSheetAnimationSpeed = 1;
        starlingHandler.container = Globals.starlingCanvas;
        clonedEmitter.particleHandler = starlingHandler;

        _bus.dispatchEvent(new RegenerateEmitterTexturesEvent());
        _bus.dispatchEvent(new ChangeEmitterInFocusEvent(ChangeEmitterInFocusEvent.CHANGE, emitterData));
        _bus.dispatchEvent(new StartSimEvent());
    }
}
}
