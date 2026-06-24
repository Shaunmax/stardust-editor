package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.controller.events.LoadSimEvent;
import com.funkypandagame.stardust.helpers.Globals;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.net.FileFilter;
import flash.net.FileReference;

public class FileLoadCommand
{
    private var _bus:EventDispatcher;
    private var _loadFile:FileReference;

    public function FileLoadCommand(bus:EventDispatcher)
    {
        _bus = bus;
    }

    public function execute():void
    {
        // Always in AIR — dispatch external event so the AIR wrapper can cache the path
        if (Globals.externalEventDispatcher != null)
        {
            Globals.dispatchExternalLoadSimEvent();
        }
        else
        {
            _loadFile = new FileReference();
            _loadFile.addEventListener(Event.SELECT, selectHandler);
            _loadFile.addEventListener(Event.CANCEL, cancelHandler);
            _loadFile.browse([new FileFilter("Stardust editor project (*.sde)", "*.sde")]);
        }
    }

    private function cancelHandler(event:Event):void
    {
        _loadFile.removeEventListener(Event.SELECT, selectHandler);
        _loadFile.removeEventListener(Event.CANCEL, cancelHandler);
    }

    private function selectHandler(event:Event):void
    {
        _loadFile.removeEventListener(Event.SELECT, selectHandler);
        _loadFile.removeEventListener(Event.CANCEL, cancelHandler);
        _loadFile.addEventListener(Event.COMPLETE, loadCompleteHandler);
        _loadFile.load();
    }

    private function loadCompleteHandler(event:Event):void
    {
        _loadFile.removeEventListener(Event.COMPLETE, loadCompleteHandler);
        var fileName:String = _loadFile.name;
        var fileNameNoExtension:String = fileName.substr(0, fileName.lastIndexOf("."));
        _bus.dispatchEvent(new LoadSimEvent(_loadFile.data, fileNameNoExtension));
    }
}
}
