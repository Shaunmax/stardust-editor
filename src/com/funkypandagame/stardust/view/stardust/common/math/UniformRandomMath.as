package com.funkypandagame.stardust.view.stardust.common.math
{

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import idv.cjcat.stardustextended.math.UniformRandom;

import starling.events.Event;

public class UniformRandomMath extends LayoutGroup
{
    private var _centerStepper:NumericStepper;
    private var _radiusStepper:NumericStepper;
    private var _data:UniformRandom;

    override protected function initialize():void
    {
        super.initialize();

        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 4;
        this.layout = hLayout;

        var lbl1:Label = new Label();
        lbl1.text = "average";
        addChild(lbl1);

        _centerStepper = new NumericStepper();
        _centerStepper.step = 0.1;
        _centerStepper.width = 55;
        _centerStepper.addEventListener(Event.CHANGE, _onChange);
        addChild(_centerStepper);

        var lbl2:Label = new Label();
        lbl2.text = "variation";
        addChild(lbl2);

        _radiusStepper = new NumericStepper();
        _radiusStepper.step = 0.1;
        _radiusStepper.minimum = 0;
        _radiusStepper.width = 55;
        _radiusStepper.addEventListener(Event.CHANGE, _onChange);
        addChild(_radiusStepper);
    }

    public function setData(d:UniformRandom):void
    {
        _data = d;
        if (_centerStepper)
        {
            _centerStepper.value = d.center;
            _radiusStepper.value = d.radius;
        }
    }

    public function updateData():void
    {
        if (_data && _centerStepper)
        {
            _data.center = _centerStepper.value;
            _data.radius = _radiusStepper.value;
        }
    }

    private function _onChange(e:Event):void
    {
        updateData();
    }
}
}
