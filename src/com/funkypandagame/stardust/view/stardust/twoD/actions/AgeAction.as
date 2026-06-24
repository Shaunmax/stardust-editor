package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;

import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import idv.cjcat.stardustextended.actions.Age;

import starling.events.Event;

public class AgeAction extends PropertyRendererBase
{
    private var _stepper:NumericStepper;

    override protected function initialize():void
    {
        nameText = "Change age  Multiplier";
        super.initialize();
    }

    override protected function createContent():void
    {
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 4;
        contentContainer.layout = hLayout;

        _stepper = new NumericStepper();
        _stepper.step = 0.1;
        _stepper.value = 1;
        _stepper.width = 70;
        _stepper.addEventListener(Event.CHANGE, _onChange);
        contentContainer.addChild(_stepper);
    }

    override protected function commitData():void
    {
        super.commitData();
        if (_data && _stepper)
            _stepper.value = Age(_data).multiplier;
    }

    private function _onChange(e:Event):void
    {
        if (_data) Age(_data).multiplier = _stepper.value;
    }
}
}
