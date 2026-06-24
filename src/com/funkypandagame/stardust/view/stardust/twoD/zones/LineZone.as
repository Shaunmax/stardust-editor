package com.funkypandagame.stardust.view.stardust.twoD.zones
{

import feathers.controls.Label;
import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import idv.cjcat.stardustextended.zones.Line;

import starling.events.Event;

public class LineZone extends ZoneRendererBase
{
    private var _x1:NumericStepper;
    private var _y1:NumericStepper;
    private var _x2:NumericStepper;
    private var _y2:NumericStepper;

    override protected function initialize():void
    {
        nameText = "Line   x1";
        super.initialize();
    }

    override protected function createContent():void
    {
        var h:HorizontalLayout = new HorizontalLayout();
        h.verticalAlign = VerticalAlign.MIDDLE; h.gap = 4;
        contentContainer.layout = h;

        _x1 = _s(); _lbl("y1"); _y1 = _s(); _lbl("x2"); _x2 = _s(); _lbl("y2"); _y2 = _s();
    }

    private function _lbl(t:String):void { var l:Label = new Label(); l.text = t; contentContainer.addChild(l); }
    private function _s():NumericStepper
    {
        var s:NumericStepper = new NumericStepper();
        s.step = 1; s.width = 55;
        s.addEventListener(Event.CHANGE, _onChange);
        contentContainer.addChild(s);
        return s;
    }

    override protected function commitData():void
    {
        if (!_data || !_x1) return;
        var z:Line = Line(_data);
        _x1.value = z.x; _y1.value = z.y; _x2.value = z.x2; _y2.value = z.y2;
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        var z:Line = Line(_data);
        z.x = _x1.value; z.y = _y1.value; z.x2 = _x2.value; z.y2 = _y2.value;
    }
}
}
