package com.funkypandagame.stardust.view.stardust.common.clocks
{

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import idv.cjcat.stardustextended.clocks.Clock;
import idv.cjcat.stardustextended.clocks.SteadyClock;
import idv.cjcat.stardustextended.math.UniformRandom;

import com.funkypandagame.stardust.view.stardust.common.math.UniformRandomMath;

import starling.events.Event;

public class SteadyClockRenderer extends LayoutGroup implements IClockRenderer
{
    private var _stepper:NumericStepper;
    private var _initDelayMath:UniformRandomMath;
    private var _clock:SteadyClock;

    public function SteadyClockRenderer()
    {
        super();
        var h:HorizontalLayout = new HorizontalLayout();
        h.verticalAlign = VerticalAlign.MIDDLE;
        h.gap = 4;
        layout = h;
    }

    override protected function initialize():void
    {
        super.initialize();

        var lbl1:Label = new Label(); lbl1.text = "new particles/second";
        addChild(lbl1);

        _stepper = new NumericStepper();
        _stepper.minimum = 0; _stepper.maximum = 1000; _stepper.step = 1; _stepper.width = 60;
        _stepper.addEventListener(Event.CHANGE, _onChange);
        addChild(_stepper);

        var lbl2:Label = new Label(); lbl2.text = "initial delay";
        addChild(lbl2);

        _initDelayMath = new UniformRandomMath();
        addChild(_initDelayMath);
    }

    public function setData(d:Clock):void
    {
        _clock = SteadyClock(d);
        _stepper.value = _clock.ticksPerCall;
        _initDelayMath.setData(_clock.initialDelay as UniformRandom);
    }

    private function _onChange(e:Event):void
    {
        if (!_clock) return;
        _clock.ticksPerCall = _stepper.value;
    }
}
}
