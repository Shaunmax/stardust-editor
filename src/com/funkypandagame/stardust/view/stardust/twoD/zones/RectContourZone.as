package com.funkypandagame.stardust.view.stardust.twoD.zones
{

import feathers.controls.Label;
import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import idv.cjcat.stardustextended.zones.RectContour;

import starling.events.Event;

public class RectContourZone extends ZoneRendererBase
{
    private var _x:NumericStepper;
    private var _y:NumericStepper;
    private var _w:NumericStepper;
    private var _h:NumericStepper;
    private var _rot:NumericStepper;

    override protected function initialize():void
    {
        nameText = "Rect. contour";
        super.initialize();
    }

    override protected function createContent():void
    {
        var h:HorizontalLayout = new HorizontalLayout();
        h.verticalAlign = VerticalAlign.MIDDLE; h.gap = 3;
        contentContainer.layout = h;

        _lbl("x"); _x = _s(); _lbl("y"); _y = _s(); _lbl("width"); _w = _s();
        _lbl("height"); _h = _s(); _lbl("rotation"); _rot = _s();
    }

    private function _lbl(t:String):void { var l:Label = new Label(); l.text = t; contentContainer.addChild(l); }
    private function _s():NumericStepper
    {
        var s:NumericStepper = new NumericStepper(); s.step = 1; s.width = 45;
        s.addEventListener(Event.CHANGE, _onChange); contentContainer.addChild(s); return s;
    }

    override protected function commitData():void
    {
        if (!_data || !_x) return;
        var z:RectContour = RectContour(_data);
        _x.value = z.x; _y.value = z.y; _w.value = z.width; _h.value = z.height; _rot.value = z.rotation;
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        var z:RectContour = RectContour(_data);
        z.x = _x.value; z.y = _y.value; z.width = _w.value; z.height = _h.value; z.rotation = _rot.value;
    }
}
}
