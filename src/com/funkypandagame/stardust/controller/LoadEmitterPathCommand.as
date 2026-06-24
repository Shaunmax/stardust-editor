package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardust.view.events.PositionInitializerEmitterPathEvent;

import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.geom.Point;
import flash.net.FileFilter;
import flash.net.FileReference;

import idv.cjcat.stardustextended.initializers.PositionAnimated;
import idv.cjcat.stardustextended.initializers.Initializer;

public class LoadEmitterPathCommand
{
    private var _projectModel:ProjectModel;
    private var _event:PositionInitializerEmitterPathEvent;
    private var _fileRef:FileReference;

    public function LoadEmitterPathCommand(model:ProjectModel, event:PositionInitializerEmitterPathEvent)
    {
        _projectModel = model;
        _event = event;
    }

    public function execute():void
    {
        _fileRef = new FileReference();
        _fileRef.browse([new FileFilter("SWF files (*.swf)", "*.swf")]);
        _fileRef.addEventListener(Event.SELECT, onSelect);
    }

    private function onSelect(e:Event):void
    {
        _fileRef.removeEventListener(Event.SELECT, onSelect);
        _fileRef.addEventListener(Event.COMPLETE, onComplete);
        _fileRef.load();
    }

    private function onComplete(e:Event):void
    {
        _fileRef.removeEventListener(Event.COMPLETE, onComplete);
        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onSwfLoaded);
        loader.loadBytes(_fileRef.data);
    }

    private function onSwfLoaded(e:Event):void
    {
        var mc:MovieClip = e.currentTarget.loader.content as MovieClip;
        if (mc == null) return;
        var emitterClip:MovieClip = mc.getChildByName("emitter") as MovieClip;
        if (emitterClip == null) return;

        var points:Vector.<Point> = new Vector.<Point>();
        for (var f:int = 1; f <= emitterClip.totalFrames; f++)
        {
            emitterClip.gotoAndStop(f);
            points.push(new Point(emitterClip.x, emitterClip.y));
        }

        for each (var init:Initializer in _projectModel.emitterInFocus.emitter.initializers)
        {
            if (init is PositionAnimated)
            {
                PositionAnimated(init).positions = points;
                break;
            }
        }
    }
}
}
