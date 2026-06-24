package com.funkypandagame.stardust.controller.events
{

import flash.display.BitmapData;
import flash.events.Event;

public class ShowSetEmitterImagePopupEvent extends Event
{
    public static const SHOW_SET_EMITTER_IMAGE_POPUP:String = "showSetEmitterImagePopup";

    public var rawData:Vector.<BitmapData>;
    public var onClosed:Function;

    public function ShowSetEmitterImagePopupEvent(rawData:Vector.<BitmapData>, onClosed:Function)
    {
        super(SHOW_SET_EMITTER_IMAGE_POPUP, true, false);
        this.rawData = rawData;
        this.onClosed = onClosed;
    }
}
}
