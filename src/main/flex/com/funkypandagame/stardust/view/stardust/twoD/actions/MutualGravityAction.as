package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;

import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import idv.cjcat.stardustextended.actions.MutualGravity;

import starling.events.Event;

public class MutualGravityAction extends PropertyRendererBase
{
    private var _strengthStepper:NumericStepper;
    private var _epsilonStepper:NumericStepper;
    private var _maxDistStepper:NumericStepper;
    private var _attenuationStepper:NumericStepper;
    private var _masslessCheck:Check;

    override protected function initialize():void
    {
        nameText = "Mutual gravity";
        super.initialize();
    }

    override protected function createContent():void
    {
        var vLayout:VerticalLayout = new VerticalLayout();
        vLayout.gap = 2;
        contentContainer.layout = vLayout;

        var row1:LayoutGroup = _makeHRow();
        contentContainer.addChild(row1);
        row1.addChild(_lbl("strength"));
        _strengthStepper = _stepper(row1, NaN, NaN, 0.1);
        row1.addChild(_lbl("epsilon"));
        _epsilonStepper = _stepper(row1, NaN, NaN, 0.1);
        row1.addChild(_lbl("max. distance"));
        _maxDistStepper = _stepper(row1);

        var row2:LayoutGroup = _makeHRow();
        contentContainer.addChild(row2);
        row2.addChild(_lbl("attenuation power"));
        _attenuationStepper = _stepper(row2, NaN, NaN, 0.1);
        _masslessCheck = new Check();
        _masslessCheck.label = "massless";
        _masslessCheck.addEventListener(Event.CHANGE, _onChange);
        row2.addChild(_masslessCheck);
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

    private function _stepper(parent:LayoutGroup, minVal:Number = NaN, maxVal:Number = NaN, step:Number = 1):NumericStepper
    {
        var s:NumericStepper = new NumericStepper();
        s.width = 60;
        s.step = step;
        if (!isNaN(minVal)) s.minimum = minVal;
        if (!isNaN(maxVal)) s.maximum = maxVal;
        s.addEventListener(Event.CHANGE, _onChange);
        parent.addChild(s);
        return s;
    }

    override protected function commitData():void
    {
        super.commitData();
        if (!_data || !_strengthStepper) return;
        var d:MutualGravity = MutualGravity(_data);
        _strengthStepper.value = d.strength;
        _epsilonStepper.value = d.epsilon;
        _maxDistStepper.value = d.maxDistance;
        _attenuationStepper.value = d.attenuationPower;
        _masslessCheck.isSelected = d.massless;
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        var d:MutualGravity = MutualGravity(_data);
        d.strength = _strengthStepper.value;
        d.epsilon = _epsilonStepper.value;
        d.maxDistance = _maxDistStepper.value;
        d.attenuationPower = _attenuationStepper.value;
        d.massless = _masslessCheck.isSelected;
    }
}
}
