package com.funkypandagame.stardust.view.stardust.twoD.zones
{

import feathers.controls.Label;
import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import idv.cjcat.stardustextended.zones.CircleContour;

import starling.events.Event;

public class CircleContourZoneRenderer extends ZoneRendererBase
{
    private var _xStepper:NumericStepper;
    private var _yStepper:NumericStepper;
    private var _radiusStepper:NumericStepper;

    override protected function initialize():void
    {
        nameText = "Circle contour   x";
        super.initialize();
    }

    override protected function createContent():void
    {
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 4;
        contentContainer.layout = hLayout;

        _xStepper = _stepper(45);
        contentContainer.addChild(_lbl("y"));
        _yStepper = _stepper(45);
        contentContainer.addChild(_lbl("radius"));
        _radiusStepper = _stepper(45);
    }

    override protected function commitData():void
    {
        if (!_data || !_xStepper) return;
        var z:CircleContour = CircleContour(_data);
        _xStepper.value = z.x;
        _yStepper.value = z.y;
        _radiusStepper.value = z.radius;
    }

    private function _lbl(t:String):Label
    {
        var l:Label = new Label(); l.text = t; return l;
    }

    private function _stepper(w:Number):NumericStepper
    {
        var s:NumericStepper = new NumericStepper();
        s.width = w;
        s.addEventListener(Event.CHANGE, _onChange);
        contentContainer.addChild(s);
        return s;
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        var z:CircleContour = CircleContour(_data);
        z.x = _xStepper.value;
        z.y = _yStepper.value;
        z.radius = _radiusStepper.value;
    }
}
}
