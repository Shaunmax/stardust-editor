package com.funkypandagame.stardust.controller.events
{

import flash.events.Event;

public class OpenImportPopupEvent extends Event
{
    public static const TYPE:String = "OpenImportPopupEvent";

    public function OpenImportPopupEvent()
    {
        super(TYPE);
    }

    override public function clone():Event
    {
        return new OpenImportPopupEvent();
    }
}
}
