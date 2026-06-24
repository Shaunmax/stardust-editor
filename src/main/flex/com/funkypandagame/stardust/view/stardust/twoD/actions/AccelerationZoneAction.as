package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;
import com.funkypandagame.stardust.view.stardust.twoD.zones.ZoneContainer;

import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import idv.cjcat.stardustextended.actions.AccelerationZone;

import starling.events.Event;

public class AccelerationZoneAction extends PropertyRendererBase
{
    private var _accelerationStepper:NumericStepper;
    private var _invertedCheck:Check;
    private var _useParticleDirectionCheck:Check;
    private var _angleStepper:NumericStepper;
    private var _zoneContainer:ZoneContainer;

    override protected function initialize():void
    {
        nameText = "Accel. zone";
        super.initialize();
    }

    override protected function createContent():void
    {
        var vLayout:VerticalLayout = new VerticalLayout();
        vLayout.gap = 4;
        contentContainer.layout = vLayout;

        var row1:LayoutGroup = _makeHRow();
        contentContainer.addChild(row1);
        row1.addChild(_lbl("Acceleration"));
        _accelerationStepper = new NumericStepper();
        _accelerationStepper.step = 0.1;
        _accelerationStepper.width = 60;
        _accelerationStepper.addEventListener(Event.CHANGE, _onChange);
        row1.addChild(_accelerationStepper);
        _invertedCheck = new Check();
        _invertedCheck.label = "Inverted?";
        _invertedCheck.addEventListener(Event.CHANGE, _onChange);
        row1.addChild(_invertedCheck);

        var row2:LayoutGroup = _makeHRow();
        contentContainer.addChild(row2);
        _useParticleDirectionCheck = new Check();
        _useParticleDirectionCheck.label = "Use particle direction?";
        _useParticleDirectionCheck.addEventListener(Event.CHANGE, _onDirectionCheckChange);
        row2.addChild(_useParticleDirectionCheck);
        row2.addChild(_lbl("angle(degrees)"));
        _angleStepper = new NumericStepper();
        _angleStepper.width = 60;
        _angleStepper.addEventListener(Event.CHANGE, _onChange);
        row2.addChild(_angleStepper);

        _zoneContainer = new ZoneContainer();
        _zoneContainer.zeroAreaZonesVisible = false;
        contentContainer.addChild(_zoneContainer);
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

    override protected function commitData():void
    {
        super.commitData();
        if (!_data || !_accelerationStepper) return;
        var d:AccelerationZone = AccelerationZone(_data);
        _accelerationStepper.value = d.acceleration;
        _invertedCheck.isSelected = d.inverted;
        _useParticleDirectionCheck.isSelected = d.useParticleDirection;
        _angleStepper.value = d.direction.angle;
        _angleStepper.isEnabled = !d.useParticleDirection;
        _zoneContainer.setData(d);
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        var d:AccelerationZone = AccelerationZone(_data);
        d.acceleration = _accelerationStepper.value;
        d.inverted = _invertedCheck.isSelected;
        d.direction.angle = _angleStepper.value;
    }

    private function _onDirectionCheckChange(e:Event):void
    {
        if (!_data) return;
        var d:AccelerationZone = AccelerationZone(_data);
        d.useParticleDirection = _useParticleDirectionCheck.isSelected;
        _angleStepper.isEnabled = !d.useParticleDirection;
    }
}
}
