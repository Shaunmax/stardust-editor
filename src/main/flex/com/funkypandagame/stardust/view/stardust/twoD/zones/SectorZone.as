package com.funkypandagame.stardust.view.stardust.twoD.zones
{

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import idv.cjcat.stardustextended.zones.Sector;

import starling.events.Event;

public class SectorZone extends ZoneRendererBase
{
    private var _minAngle:NumericStepper;
    private var _maxAngle:NumericStepper;
    private var _x:NumericStepper;
    private var _y:NumericStepper;
    private var _minR:NumericStepper;
    private var _maxR:NumericStepper;

    override protected function initialize():void
    {
        nameText = "Sector";
        super.initialize();
    }

    override protected function createContent():void
    {
        var v:VerticalLayout = new VerticalLayout(); v.gap = 2;
        contentContainer.layout = v;

        var row1:LayoutGroup = _hrow();
        _lbl("Circle sector  min. angle", row1); _minAngle = _s(row1); _lbl("max. angle", row1); _maxAngle = _s(row1);

        var row2:LayoutGroup = _hrow();
        _lbl("x", row2); _x = _s(row2); _lbl("y", row2); _y = _s(row2);
        _lbl("min. radius", row2); _minR = _s(row2); _lbl("max. radius", row2); _maxR = _s(row2);
    }

    private function _hrow():LayoutGroup
    {
        var g:LayoutGroup = new LayoutGroup();
        var h:HorizontalLayout = new HorizontalLayout(); h.verticalAlign = VerticalAlign.MIDDLE; h.gap = 4;
        g.layout = h; g.layoutData = new HorizontalLayoutData(100);
        contentContainer.addChild(g); return g;
    }

    private function _lbl(t:String, p:LayoutGroup):void { var l:Label = new Label(); l.text = t; p.addChild(l); }
    private function _s(p:LayoutGroup):NumericStepper
    {
        var s:NumericStepper = new NumericStepper(); s.step = 1; s.width = 50;
        s.addEventListener(Event.CHANGE, _onChange); p.addChild(s); return s;
    }

    override protected function commitData():void
    {
        if (!_data || !_x) return;
        var z:Sector = Sector(_data);
        _x.value = z.x; _y.value = z.y; _minR.value = z.minRadius; _maxR.value = z.maxRadius;
        _minAngle.value = z.minAngle; _maxAngle.value = z.maxAngle;
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        var z:Sector = Sector(_data);
        z.x = _x.value; z.y = _y.value; z.minRadius = _minR.value; z.maxRadius = _maxR.value;
        z.minAngle = _minAngle.value; z.maxAngle = _maxAngle.value;
    }
}
}
