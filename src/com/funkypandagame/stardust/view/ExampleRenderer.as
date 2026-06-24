package com.funkypandagame.stardust.view
{

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;

import flash.utils.ByteArray;

import starling.events.Event;

public class ExampleRenderer extends LayoutGroup
{
    private var _description:Label;
    private var _loadBtn:Button;

    public var callback:Function;
    public var sdeFile:ByteArray;
    public var nameToDisplay:String;
    public var htmlDescription:String = "";

    public function ExampleRenderer()
    {
        super();
        var h:HorizontalLayout = new HorizontalLayout();
        h.verticalAlign = VerticalAlign.MIDDLE; h.gap = 4;
        h.paddingLeft = 5; h.paddingRight = 5;
        h.paddingTop = 5; h.paddingBottom = 5;
        layout = h;
    }

    override protected function initialize():void
    {
        super.initialize();

        _description = new Label();
        _description.layoutData = new HorizontalLayoutData(100);
        _description.text = htmlDescription;
        addChild(_description);

        _loadBtn = new Button(); _loadBtn.label = "Load";
        _loadBtn.addEventListener(Event.TRIGGERED, _onLoad);
        addChild(_loadBtn);
    }

    public function set description(text:String):void
    {
        htmlDescription = text;
        if (_description) _description.text = text;
    }

    private function _onLoad(e:Event):void
    {
        if (callback != null) callback(sdeFile, nameToDisplay);
    }
}
}
