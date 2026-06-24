package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;

import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import idv.cjcat.stardustextended.actions.RandomDrift;

import starling.events.Event;

public class RandomDriftAction extends PropertyRendererBase
{
    private var _maxXStepper:NumericStepper;
    private var _maxYStepper:NumericStepper;
    private var _masslessCheck:Check;

    override protected function initialize():void
    {
        nameText = "Random drift";
        super.initialize();
    }

    override protected function createContent():void
    {
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 4;
        contentContainer.layout = hLayout;

        var lbl1:Label = new Label(); lbl1.text = "max X";
        contentContainer.addChild(lbl1);
        _maxXStepper = new NumericStepper();
        _maxXStepper.step = 0.1; _maxXStepper.width = 60;
        _maxXStepper.addEventListener(Event.CHANGE, _onChange);
        contentContainer.addChild(_maxXStepper);

        var lbl2:Label = new Label(); lbl2.text = "max Y";
        contentContainer.addChild(lbl2);
        _maxYStepper = new NumericStepper();
        _maxYStepper.step = 0.1; _maxYStepper.width = 60;
        _maxYStepper.addEventListener(Event.CHANGE, _onChange);
        contentContainer.addChild(_maxYStepper);

        _masslessCheck = new Check();
        _masslessCheck.label = "massless?";
        _masslessCheck.addEventListener(Event.CHANGE, _onChange);
        contentContainer.addChild(_masslessCheck);
    }

    override protected function commitData():void
    {
        super.commitData();
        if (!_data || !_maxXStepper) return;
        var d:RandomDrift = RandomDrift(_data);
        _maxXStepper.value = d.maxX;
        _maxYStepper.value = d.maxY;
        _masslessCheck.isSelected = d.massless;
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        var d:RandomDrift = RandomDrift(_data);
        d.maxX = _maxXStepper.value;
        d.maxY = _maxYStepper.value;
        d.massless = _masslessCheck.isSelected;
    }
}
}
