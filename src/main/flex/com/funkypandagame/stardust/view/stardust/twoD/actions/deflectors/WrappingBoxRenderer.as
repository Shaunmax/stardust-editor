package com.funkypandagame.stardust.view.stardust.twoD.actions.deflectors
{

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.NumericStepper;

import idv.cjcat.stardustextended.deflectors.WrappingBox;

import starling.events.Event;

public class WrappingBoxRenderer extends DeflectorRendererBase
{
    private var _xStepper:NumericStepper;
    private var _yStepper:NumericStepper;
    private var _widthStepper:NumericStepper;
    private var _heightStepper:NumericStepper;

    override protected function createContent():void
    {
        _contentRow1.addChild(_lbl("Wrapping Box"));

        var row:LayoutGroup = _contentRow1;
        addChild(_contentRow2);

        _contentRow2.addChild(_lbl("x"));
        _xStepper = _stepper(_contentRow2);
        _contentRow2.addChild(_lbl("y"));
        _yStepper = _stepper(_contentRow2);
        _contentRow2.addChild(_lbl("width"));
        _widthStepper = _stepper(_contentRow2);
        _contentRow2.addChild(_lbl("height"));
        _heightStepper = _stepper(_contentRow2);
    }

    private function _lbl(t:String):Label
    {
        var l:Label = new Label(); l.text = t; return l;
    }

    private function _stepper(parent:LayoutGroup):NumericStepper
    {
        var s:NumericStepper = new NumericStepper();
        s.width = 60;
        s.addEventListener(Event.CHANGE, _onChange);
        parent.addChild(s);
        return s;
    }

    override protected function commitData():void
    {
        var d:WrappingBox = WrappingBox(_data);
        _xStepper.value = d.x;
        _yStepper.value = d.y;
        _widthStepper.value = d.width;
        _heightStepper.value = d.height;
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        var d:WrappingBox = WrappingBox(_data);
        d.x = _xStepper.value;
        d.y = _yStepper.value;
        d.width = _widthStepper.value;
        d.height = _heightStepper.value;
    }
}
}
