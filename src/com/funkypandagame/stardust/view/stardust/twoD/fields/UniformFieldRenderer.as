package com.funkypandagame.stardust.view.stardust.twoD.fields
{

import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import idv.cjcat.stardustextended.fields.UniformField;

import starling.events.Event;

public class UniformFieldRenderer extends FieldRendererBase
{
    private var _xStepper:NumericStepper;
    private var _yStepper:NumericStepper;
    private var _masslessCheck:Check;

    override protected function createContent():void
    {
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 4;
        contentContainer.layout = hLayout;

        var lbl:Label = new Label();
        lbl.text = "Uniform  x";
        contentContainer.addChild(lbl);

        _xStepper = new NumericStepper();
        _xStepper.step = 0.1;
        _xStepper.width = 60;
        _xStepper.addEventListener(Event.CHANGE, _onChange);
        contentContainer.addChild(_xStepper);

        var lbl2:Label = new Label();
        lbl2.text = "y";
        contentContainer.addChild(lbl2);

        _yStepper = new NumericStepper();
        _yStepper.step = 0.1;
        _yStepper.width = 60;
        _yStepper.addEventListener(Event.CHANGE, _onChange);
        contentContainer.addChild(_yStepper);

        _masslessCheck = new Check();
        _masslessCheck.label = "massless";
        _masslessCheck.addEventListener(Event.CHANGE, _onChange);
        contentContainer.addChild(_masslessCheck);
    }

    override protected function commitData():void
    {
        if (!_data) return;
        var d:UniformField = UniformField(_data);
        _xStepper.value = d.x;
        _yStepper.value = d.y;
        _masslessCheck.isSelected = d.massless;
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        var d:UniformField = UniformField(_data);
        d.x = _xStepper.value;
        d.y = _yStepper.value;
        d.massless = _masslessCheck.isSelected;
    }
}
}
