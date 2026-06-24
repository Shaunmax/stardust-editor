package com.funkypandagame.stardust.view.stardust.twoD.zones
{

import feathers.controls.Label;
import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import idv.cjcat.stardustextended.zones.CircleZone;

import starling.events.Event;

public class CircleZoneRenderer extends ZoneRendererBase
{
    private var _x:NumericStepper;
    private var _y:NumericStepper;
    private var _r:NumericStepper;

    override protected function initialize():void
    {
        nameText = "Circle   x";
        super.initialize();
    }

    override protected function createContent():void
    {
        var h:HorizontalLayout = new HorizontalLayout();
        h.verticalAlign = VerticalAlign.MIDDLE;
        h.gap = 4;
        contentContainer.layout = h;

        _x = _stepper(contentContainer, null);
        contentContainer.addChild(_lbl("y"));
        _y = _stepper(contentContainer, null);
        contentContainer.addChild(_lbl("radius"));
        _r = _stepper(contentContainer, null);
    }

    private function _lbl(t:String):Label { var l:Label = new Label(); l.text = t; return l; }
    private function _stepper(parent:LayoutGroup, lbl:String):NumericStepper
    {
        var s:NumericStepper = new NumericStepper();
        s.step = 0.5; s.width = 55;
        s.addEventListener(Event.CHANGE, _onChange);
        if (parent) parent.addChild(s);
        return s;
    }

    override protected function commitData():void
    {
        if (!_data || !_x) return;
        var z:CircleZone = CircleZone(_data);
        _x.value = z.x; _y.value = z.y; _r.value = z.radius;
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        var z:CircleZone = CircleZone(_data);
        z.x = _x.value; z.y = _y.value; z.radius = _r.value;
    }
}
}
