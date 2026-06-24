package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;

import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import idv.cjcat.stardustextended.actions.SpeedLimit;

import starling.events.Event;

public class SpeedLimitAction extends PropertyRendererBase
{
    private var _stepper:NumericStepper;

    override protected function initialize():void
    {
        nameText = "Speed limit";
        super.initialize();
    }

    override protected function createContent():void
    {
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        contentContainer.layout = hLayout;

        _stepper = new NumericStepper();
        _stepper.minimum = 0;
        _stepper.maximum = 9999;
        _stepper.width = 80;
        _stepper.addEventListener(Event.CHANGE, _onChange);
        contentContainer.addChild(_stepper);
    }

    override protected function commitData():void
    {
        super.commitData();
        if (!_data || !_stepper) return;
        var d:SpeedLimit = SpeedLimit(_data);
        if (d.limit > 9999) d.limit = 9999;
        _stepper.value = d.limit;
    }

    private function _onChange(e:Event):void
    {
        if (_data) SpeedLimit(_data).limit = _stepper.value;
    }
}
}
