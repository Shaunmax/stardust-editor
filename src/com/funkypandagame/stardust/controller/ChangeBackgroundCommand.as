package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.controller.events.BackgroundChangeEvent;
import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardust.view.events.RefreshBackgroundViewEvent;
import com.funkypandagame.stardustplayer.sequenceLoader.ISequenceLoader;
import com.funkypandagame.stardustplayer.sequenceLoader.LoadByteArrayJob;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.net.FileFilter;
import flash.net.FileReference;

public class ChangeBackgroundCommand
{
    private var _bus:EventDispatcher;
    private var _sequenceLoader:ISequenceLoader;
    private var _event:BackgroundChangeEvent;
    private var _projectModel:ProjectModel;
    private var _backgroundFileReference:FileReference;

    public static const BACKGROUND_JOB_ID:String = "backgroundJobId";

    public function ChangeBackgroundCommand(bus:EventDispatcher, sequenceLoader:ISequenceLoader,
                                            projectModel:ProjectModel, event:BackgroundChangeEvent)
    {
        _bus = bus;
        _sequenceLoader = sequenceLoader;
        _projectModel = projectModel;
        _event = event;
    }

    public function execute():void
    {
        if (_event.property == BackgroundChangeEvent.IMAGE)
        {
            var loadFile:FileReference = new FileReference();
            loadFile.browse([new FileFilter("Images: (*.jpeg, *.jpg, *.gif, *.png)", "*.jpeg; *.jpg; *.gif; *.png")]);
            _backgroundFileReference = loadFile;
            _backgroundFileReference.addEventListener(Event.SELECT, backgroundSelectHandler);
        }
        else if (_event.property == BackgroundChangeEvent.COLOR)
        {
            _projectModel.backgroundColor = _event.value as uint;
            _bus.dispatchEvent(new RefreshBackgroundViewEvent());
        }
        else if (_event.property == BackgroundChangeEvent.HAS_BACKGROUND)
        {
            _projectModel.hasBackground = _event.value as Boolean;
            if (!_projectModel.hasBackground)
            {
                _projectModel.backgroundColor = 0;
                _projectModel.backgroundImage = null;
                _projectModel.backgroundRawData = null;
            }
            else
            {
                _projectModel.backgroundColor = 0;
                _projectModel.backgroundImage = null;
                _projectModel.backgroundRawData = null;
            }
            _bus.dispatchEvent(new RefreshBackgroundViewEvent());
        }
    }

    private function backgroundSelectHandler(event:Event):void
    {
        _backgroundFileReference.removeEventListener(Event.SELECT, backgroundSelectHandler);
        _backgroundFileReference.addEventListener(Event.COMPLETE, loadBackgroundFromByteArray);
        _backgroundFileReference.load();
    }

    private function loadBackgroundFromByteArray(event:Event):void
    {
        _sequenceLoader.removeCompletedJobByName(BACKGROUND_JOB_ID);
        var job:LoadByteArrayJob = new LoadByteArrayJob(BACKGROUND_JOB_ID, _backgroundFileReference.name, _backgroundFileReference.data);
        _sequenceLoader.addJob(job);
        _sequenceLoader.addEventListener(Event.COMPLETE, onBackgroundLoaded);
        _sequenceLoader.loadSequence();
    }

    private function onBackgroundLoaded(event:Event):void
    {
        _sequenceLoader.removeEventListener(Event.COMPLETE, onBackgroundLoaded);
        var job:LoadByteArrayJob = _sequenceLoader.getJobByName(BACKGROUND_JOB_ID);
        _projectModel.backgroundImage = job.content;
        _projectModel.backgroundRawData = job.byteArray;
        _bus.dispatchEvent(new RefreshBackgroundViewEvent());
    }
}
}
