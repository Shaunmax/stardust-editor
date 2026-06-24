package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import idv.cjcat.stardustextended.actions.ScaleCurve;

import starling.events.Event;

public class ScaleCurveAction extends PropertyRendererBase
{
    private var _inScaleStepper:NumericStepper;
    private var _inLifeStepper:NumericStepper;
    private var _outScaleStepper:NumericStepper;
    private var _outLifeStepper:NumericStepper;

    override protected function initialize():void
    {
        nameText = "Change scale";
        super.initialize();
    }

    override protected function createContent():void
    {
        var vLayout:VerticalLayout = new VerticalLayout();
        vLayout.gap = 2;
        contentContainer.layout = vLayout;

        var row1:LayoutGroup = _makeHRow();
        contentContainer.addChild(row1);
        row1.addChild(_lbl("initial scale"));
        _inScaleStepper = _stepper(row1, 0.1);
        row1.addChild(_lbl("initial transition (secs)"));
        _inLifeStepper = _stepper(row1, 0.1);

        var row2:LayoutGroup = _makeHRow();
        contentContainer.addChild(row2);
        row2.addChild(_lbl("final scale"));
        _outScaleStepper = _stepper(row2, 0.1);
        row2.addChild(_lbl("final transition (secs)"));
        _outLifeStepper = _stepper(row2, 0.1);
    }

    private function _lbl(t:String):Label
    {
        var l:Label = new Label(); l.text = t; return l;
    }

    private function _makeHRow():LayoutGroup
    {
        var g:LayoutGroup = new LayoutGroup();
        var h:HorizontalLayout = new HorizontalLayout();
        h.verticalAlign = VerticalAlign.MIDDLE;
        h.gap = 4;
        g.layout = h;
        return g;
    }

    private function _stepper(parent:LayoutGroup, step:Number = 1):NumericStepper
    {
        var s:NumericStepper = new NumericStepper();
        s.step = step; s.width = 60;
        s.addEventListener(Event.CHANGE, _onChange);
        parent.addChild(s);
        return s;
    }

    override protected function commitData():void
    {
        super.commitData();
        if (!_data || !_inScaleStepper) return;
        var d:ScaleCurve = ScaleCurve(_data);
        _inScaleStepper.value = d.inScale;
        _inLifeStepper.value = d.inLifespan;
        _outScaleStepper.value = d.outScale;
        _outLifeStepper.value = d.outLifespan;
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        var d:ScaleCurve = ScaleCurve(_data);
        d.inScale = _inScaleStepper.value;
        d.inLifespan = _inLifeStepper.value;
        d.outScale = _outScaleStepper.value;
        d.outLifespan = _outLifeStepper.value;
    }
}
}
