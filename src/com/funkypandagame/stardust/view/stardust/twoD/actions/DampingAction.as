package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;

import feathers.controls.Label;
import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import idv.cjcat.stardustextended.actions.Damping;

import starling.events.Event;

public class DampingAction extends PropertyRendererBase
{
    private var _stepper:NumericStepper;

    override protected function initialize():void
    {
        nameText = "Damping";
        super.initialize();
    }

    override protected function createContent():void
    {
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 4;
        contentContainer.layout = hLayout;

        var lbl:Label = new Label();
        lbl.text = "damping";
        contentContainer.addChild(lbl);

        _stepper = new NumericStepper();
        _stepper.step = 0.1;
        _stepper.minimum = 0;
        _stepper.maximum = 1;
        _stepper.width = 70;
        _stepper.addEventListener(Event.CHANGE, _onChange);
        contentContainer.addChild(_stepper);
    }

    override protected function commitData():void
    {
        super.commitData();
        if (_data && _stepper)
            _stepper.value = Damping(_data).damping;
    }

    private function _onChange(e:Event):void
    {
        if (_data) Damping(_data).damping = _stepper.value;
    }
}
}
