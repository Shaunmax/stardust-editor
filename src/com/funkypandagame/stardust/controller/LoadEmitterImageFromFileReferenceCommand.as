package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.controller.events.RegenerateEmitterTexturesEvent;
import com.funkypandagame.stardust.controller.events.StartSimEvent;
import com.funkypandagame.stardust.controller.events.ShowSetEmitterImagePopupEvent;
import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardustplayer.emitter.EmitterValueObject;
import com.funkypandagame.stardustplayer.sequenceLoader.ISequenceLoader;
import com.funkypandagame.stardustplayer.sequenceLoader.LoadByteArrayJob;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.net.FileFilter;
import flash.net.FileReference;

import com.funkypandagame.stardust.helpers.SpriteSheetBitmapSlicedCache;

public class LoadEmitterImageFromFileReferenceCommand
{
    private var _bus:EventDispatcher;
    private var _sequenceLoader:ISequenceLoader;
    private var _projectModel:ProjectModel;
    private var _emitterImageFile:FileReference;

    public function LoadEmitterImageFromFileReferenceCommand(bus:EventDispatcher, sequenceLoader:ISequenceLoader, projectModel:ProjectModel)
    {
        _bus = bus;
        _sequenceLoader = sequenceLoader;
        _projectModel = projectModel;
    }

    public function execute():void
    {
        var loadFile:FileReference = new FileReference();
        loadFile.browse([new FileFilter("Images", ".gif;*.jpeg;*.jpg;*.png")]);
        _emitterImageFile = loadFile;
        _emitterImageFile.addEventListener(Event.SELECT, emitterSelectHandler);
    }

    private function emitterSelectHandler(event:Event):void
    {
        _emitterImageFile.removeEventListener(Event.SELECT, emitterSelectHandler);
        _emitterImageFile.addEventListener(Event.COMPLETE, loadEmitterFromByteArray);
        _emitterImageFile.load();
    }

    private function loadEmitterFromByteArray(event:Event):void
    {
        var emitterName:String = _projectModel.emitterInFocus.id.toString();
        _sequenceLoader.removeCompletedJobByName(emitterName);
        var job:LoadByteArrayJob = new LoadByteArrayJob(emitterName, _emitterImageFile.name, _emitterImageFile.data);
        _sequenceLoader.addJob(job);
        _sequenceLoader.addEventListener(Event.COMPLETE, onEmitterImageLoaded);
        _sequenceLoader.loadSequence();
    }

    private function onEmitterImageLoaded(event:Event):void
    {
        _sequenceLoader.removeEventListener(Event.COMPLETE, onEmitterImageLoaded);
        const loadJob:LoadByteArrayJob = _sequenceLoader.getCompletedJobs()[0];
        var rawData:BitmapData = Bitmap(loadJob.content).bitmapData;
        _bus.dispatchEvent(new ShowSetEmitterImagePopupEvent(new <BitmapData>[rawData], onImagePropsClosed));
    }

    private function onImagePropsClosed(spWidth:Number, spHeight:Number):void
    {
        const emitterVO:EmitterValueObject = _projectModel.emitterInFocus;
        const loadJob:LoadByteArrayJob = _sequenceLoader.getCompletedJobs().pop();
        var rawData:BitmapData = Bitmap(loadJob.content).bitmapData;

        var isSpriteSheet:Boolean = (spWidth > 0 && spHeight > 0) &&
                (rawData.width >= spWidth * 2 || rawData.height >= spHeight * 2);
        if (isSpriteSheet)
        {
            var splicer:SpriteSheetBitmapSlicedCache = new SpriteSheetBitmapSlicedCache(rawData, spWidth, spHeight);
            _projectModel.emitterImages[emitterVO.id] = splicer.bds;
        }
        else
        {
            _projectModel.emitterImages[emitterVO.id] = new <BitmapData>[rawData];
        }
        _bus.dispatchEvent(new RegenerateEmitterTexturesEvent());
        _bus.dispatchEvent(new StartSimEvent());
    }
}
}
