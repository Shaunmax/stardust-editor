package com.funkypandagame.stardust.view.stardust.twoD.zones
{

import feathers.controls.Label;
import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import idv.cjcat.stardustextended.zones.CircleContour;

import starling.events.Event;

public class CircleContourZone extends ZoneRendererBase
{
    private var _x:NumericStepper;
    private var _y:NumericStepper;
    private var _r:NumericStepper;

    override protected function initialize():void
    {
        nameText = "Circle contour   x";
        super.initialize();
    }

    override protected function createContent():void
    {
        var h:HorizontalLayout = new HorizontalLayout();
        h.verticalAlign = VerticalAlign.MIDDLE; h.gap = 4;
        contentContainer.layout = h;

        _x = _s(); _lbl("y"); _y = _s(); _lbl("radius"); _r = _s();
    }

    private function _lbl(t:String):void { var l:Label = new Label(); l.text = t; contentContainer.addChild(l); }
    private function _s():NumericStepper
    {
        var s:NumericStepper = new NumericStepper();
        s.step = 0.5; s.width = 55;
        s.addEventListener(Event.CHANGE, _onChange);
        contentContainer.addChild(s);
        return s;
    }

    override protected function commitData():void
    {
        if (!_data || !_x) return;
        var z:CircleContour = CircleContour(_data);
        _x.value = z.x; _y.value = z.y; _r.value = z.radius;
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        var z:CircleContour = CircleContour(_data);
        z.x = _x.value; z.y = _y.value; z.radius = _r.value;
    }
}
}
