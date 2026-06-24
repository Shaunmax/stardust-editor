package com.funkypandagame.stardust.view.stardust.twoD.fields
{

import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import idv.cjcat.stardustextended.fields.RadialField;

import starling.events.Event;

public class RadialFieldRenderer extends FieldRendererBase
{
    private var _xStepper:NumericStepper;
    private var _yStepper:NumericStepper;
    private var _strengthStepper:NumericStepper;
    private var _attenuationStepper:NumericStepper;
    private var _masslessCheck:Check;

    override protected function createContent():void
    {
        var vLayout:VerticalLayout = new VerticalLayout();
        vLayout.gap = 2;
        contentContainer.layout = vLayout;

        var row1:LayoutGroup = _hgroup();
        contentContainer.addChild(row1);

        row1.addChild(_label("Radial x"));
        _xStepper = _stepper(row1);
        row1.addChild(_label("y"));
        _yStepper = _stepper(row1);
        _masslessCheck = new Check();
        _masslessCheck.label = "massless";
        _masslessCheck.addEventListener(Event.CHANGE, _onChange);
        row1.addChild(_masslessCheck);

        var row2:LayoutGroup = _hgroup();
        contentContainer.addChild(row2);

        row2.addChild(_label("strength"));
        _strengthStepper = _stepper(row2);
        row2.addChild(_label("attenuation power"));
        _attenuationStepper = _stepper(row2);
    }

    private function _label(txt:String):Label
    {
        var l:Label = new Label();
        l.text = txt;
        return l;
    }

    private function _stepper(parent:LayoutGroup):NumericStepper
    {
        var s:NumericStepper = new NumericStepper();
        s.step = 0.1;
        s.width = 60;
        s.addEventListener(Event.CHANGE, _onChange);
        parent.addChild(s);
        return s;
    }

    private function _hgroup():LayoutGroup
    {
        var g:LayoutGroup = new LayoutGroup();
        var h:HorizontalLayout = new HorizontalLayout();
        h.verticalAlign = VerticalAlign.MIDDLE;
        h.gap = 4;
        g.layout = h;
        g.layoutData = new HorizontalLayoutData(100);
        return g;
    }

    override protected function commitData():void
    {
        if (!_data) return;
        var d:RadialField = RadialField(_data);
        _xStepper.value = d.x;
        _yStepper.value = d.y;
        _strengthStepper.value = d.strength;
        _attenuationStepper.value = d.attenuationPower;
        _masslessCheck.isSelected = d.massless;
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        var d:RadialField = RadialField(_data);
        d.x = _xStepper.value;
        d.y = _yStepper.value;
        d.strength = _strengthStepper.value;
        d.attenuationPower = _attenuationStepper.value;
        d.massless = _masslessCheck.isSelected;
    }
}
}
