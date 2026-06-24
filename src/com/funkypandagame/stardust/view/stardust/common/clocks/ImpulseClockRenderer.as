package com.funkypandagame.stardust.view.stardust.common.clocks
{

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import idv.cjcat.stardustextended.clocks.Clock;
import idv.cjcat.stardustextended.clocks.ImpulseClock;
import idv.cjcat.stardustextended.math.UniformRandom;

import com.funkypandagame.stardust.view.stardust.common.math.UniformRandomMath;

import starling.events.Event;

public class ImpulseClockRenderer extends LayoutGroup implements IClockRenderer
{
    private var _ticksStepper:NumericStepper;
    private var _initDelayMath:UniformRandomMath;
    private var _impulseLengthMath:UniformRandomMath;
    private var _impulseIntervalMath:UniformRandomMath;
    private var _clock:ImpulseClock;

    public function ImpulseClockRenderer()
    {
        super();
        var v:VerticalLayout = new VerticalLayout(); v.gap = 2;
        layout = v;
    }

    override protected function initialize():void
    {
        super.initialize();

        var row1:LayoutGroup = _hrow();
        _lbl("new particles/second", row1);
        _ticksStepper = new NumericStepper();
        _ticksStepper.minimum = 0; _ticksStepper.maximum = 1000; _ticksStepper.step = 1; _ticksStepper.width = 60;
        _ticksStepper.addEventListener(Event.CHANGE, _onChange);
        row1.addChild(_ticksStepper);
        _lbl("initial delay", row1);
        _initDelayMath = new UniformRandomMath();
        row1.addChild(_initDelayMath);

        var row2:LayoutGroup = _hrow();
        _lbl("impulse length", row2);
        _impulseLengthMath = new UniformRandomMath();
        row2.addChild(_impulseLengthMath);
        _lbl("impulse interval", row2);
        _impulseIntervalMath = new UniformRandomMath();
        row2.addChild(_impulseIntervalMath);
    }

    private function _hrow():LayoutGroup
    {
        var g:LayoutGroup = new LayoutGroup();
        var h:HorizontalLayout = new HorizontalLayout();
        h.verticalAlign = VerticalAlign.MIDDLE; h.gap = 4;
        g.layout = h;
        g.layoutData = new HorizontalLayoutData(100);
        addChild(g);
        return g;
    }

    private function _lbl(t:String, p:LayoutGroup):void
    {
        var l:Label = new Label(); l.text = t; p.addChild(l);
    }

    public function setData(d:Clock):void
    {
        _clock = ImpulseClock(d);
        _ticksStepper.value = _clock.ticksPerCall;
        _initDelayMath.setData(_clock.initialDelay as UniformRandom);
        _impulseLengthMath.setData(_clock.impulseLength as UniformRandom);
        _impulseIntervalMath.setData(_clock.impulseInterval as UniformRandom);
    }

    private function _onChange(e:Event):void
    {
        if (!_clock) return;
        _clock.ticksPerCall = _ticksStepper.value;
    }
}
}
