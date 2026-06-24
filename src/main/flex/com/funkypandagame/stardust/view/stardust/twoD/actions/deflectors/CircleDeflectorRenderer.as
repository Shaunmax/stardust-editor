package com.funkypandagame.stardust.view.stardust.twoD.actions.deflectors
{

import feathers.controls.Label;
import feathers.controls.NumericStepper;

import idv.cjcat.stardustextended.deflectors.CircleDeflector;

import starling.events.Event;

public class CircleDeflectorRenderer extends DeflectorRendererBase
{
    private var _xStepper:NumericStepper;
    private var _yStepper:NumericStepper;
    private var _radiusStepper:NumericStepper;
    private var _bounceStepper:NumericStepper;
    private var _slipperinessStepper:NumericStepper;

    override protected function createContent():void
    {
        _contentRow1.addChild(_lbl("Circle   x"));
        _xStepper = _stepper(_contentRow1);
        _contentRow1.addChild(_lbl("y"));
        _yStepper = _stepper(_contentRow1);
        _contentRow1.addChild(_lbl("radius"));
        _radiusStepper = _stepper(_contentRow1, 0, NaN, 1);
        addChild(_contentRow2);

        _contentRow2.addChild(_lbl("bounciness"));
        _bounceStepper = _stepper(_contentRow2, NaN, NaN, 0.1);
        _contentRow2.addChild(_lbl("slipperiness"));
        _slipperinessStepper = _stepper(_contentRow2, 0, NaN, 0.1);
    }

    private function _lbl(t:String):Label
    {
        var l:Label = new Label(); l.text = t; return l;
    }

    private function _stepper(parent:LayoutGroup, minVal:Number = NaN, maxVal:Number = NaN, step:Number = 1):NumericStepper
    {
        var s:NumericStepper = new NumericStepper();
        s.width = 60;
        s.step = step;
        if (!isNaN(minVal)) s.minimum = minVal;
        if (!isNaN(maxVal)) s.maximum = maxVal;
        s.addEventListener(Event.CHANGE, _onChange);
        parent.addChild(s);
        return s;
    }

    override protected function commitData():void
    {
        var d:CircleDeflector = CircleDeflector(_data);
        _xStepper.value = d.x;
        _yStepper.value = d.y;
        _radiusStepper.value = d.radius;
        _bounceStepper.value = d.bounce;
        _slipperinessStepper.value = d.slipperiness;
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        var d:CircleDeflector = CircleDeflector(_data);
        d.x = _xStepper.value;
        d.y = _yStepper.value;
        d.radius = _radiusStepper.value;
        d.bounce = _bounceStepper.value;
        d.slipperiness = _slipperinessStepper.value;
    }
}
}
