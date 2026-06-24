package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;

import feathers.controls.Label;
import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import idv.cjcat.stardustextended.actions.Oriented;

import starling.events.Event;

public class OrientedAction extends PropertyRendererBase
{
    private var _factorStepper:NumericStepper;
    private var _offsetStepper:NumericStepper;

    override protected function initialize():void
    {
        nameText = "Orient to velocity";
        super.initialize();
    }

    override protected function createContent():void
    {
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 4;
        contentContainer.layout = hLayout;

        var lbl1:Label = new Label(); lbl1.text = "factor";
        contentContainer.addChild(lbl1);

        _factorStepper = new NumericStepper();
        _factorStepper.minimum = 0;
        _factorStepper.maximum = 1;
        _factorStepper.step = 0.1;
        _factorStepper.width = 60;
        _factorStepper.addEventListener(Event.CHANGE, _onChange);
        contentContainer.addChild(_factorStepper);

        var lbl2:Label = new Label(); lbl2.text = "offset";
        contentContainer.addChild(lbl2);

        _offsetStepper = new NumericStepper();
        _offsetStepper.step = 1;
        _offsetStepper.width = 60;
        _offsetStepper.addEventListener(Event.CHANGE, _onChange);
        contentContainer.addChild(_offsetStepper);
    }

    override protected function commitData():void
    {
        super.commitData();
        if (!_data || !_factorStepper) return;
        var d:Oriented = Oriented(_data);
        _factorStepper.value = d.factor;
        _offsetStepper.value = d.offset;
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        var d:Oriented = Oriented(_data);
        d.factor = _factorStepper.value;
        d.offset = _offsetStepper.value;
    }
}
}
