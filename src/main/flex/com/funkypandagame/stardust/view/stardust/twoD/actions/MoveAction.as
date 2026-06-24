package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;

import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import idv.cjcat.stardustextended.actions.Move;

import starling.events.Event;

public class MoveAction extends PropertyRendererBase
{
    private var _stepper:NumericStepper;

    override protected function initialize():void
    {
        nameText = "Move speed  Multiplier:";
        showRemoveButton = false;
        super.initialize();
    }

    override protected function createContent():void
    {
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 4;
        contentContainer.layout = hLayout;

        _stepper = new NumericStepper();
        _stepper.minimum = 0;
        _stepper.step = 0.1;
        _stepper.width = 60;
        _stepper.addEventListener(Event.CHANGE, _onChange);
        contentContainer.addChild(_stepper);
    }

    override protected function commitData():void
    {
        super.commitData();
        if (_data && _stepper)
            _stepper.value = Move(_data).multiplier;
    }

    private function _onChange(e:Event):void
    {
        if (_data) Move(_data).multiplier = _stepper.value;
    }
}
}
