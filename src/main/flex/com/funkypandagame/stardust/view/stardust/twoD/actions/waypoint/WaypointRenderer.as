package com.funkypandagame.stardust.view.stardust.twoD.actions.waypoint
{

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.NumericStepper;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import idv.cjcat.stardustextended.actions.waypoints.Waypoint;

import starling.events.Event;

public class WaypointRenderer extends LayoutGroup
{
    public var onRemove:Function;

    private var _data:Waypoint;
    private var _xStepper:NumericStepper;
    private var _yStepper:NumericStepper;
    private var _radiusStepper:NumericStepper;
    private var _strengthStepper:NumericStepper;
    private var _attenuationStepper:NumericStepper;
    private var _epsilonStepper:NumericStepper;

    override protected function initialize():void
    {
        super.initialize();

        var vLayout:VerticalLayout = new VerticalLayout();
        vLayout.gap = 2;
        layout = vLayout;

        var row1:LayoutGroup = _makeHRow();
        addChild(row1);
        row1.addChild(_lbl("x"));
        _xStepper = _stepper(row1);
        row1.addChild(_lbl("y"));
        _yStepper = _stepper(row1);
        row1.addChild(_lbl("radius"));
        _radiusStepper = _stepper(row1);
        row1.addChild(_lbl("strength"));
        _strengthStepper = _stepper(row1, NaN, NaN, 0.1);

        var row2:LayoutGroup = _makeHRow();
        addChild(row2);
        row2.addChild(_lbl("attenuation power"));
        _attenuationStepper = _stepper(row2, NaN, NaN, 0.1);
        row2.addChild(_lbl("epsilon"));
        _epsilonStepper = _stepper(row2);

        var btnRow:LayoutGroup = new LayoutGroup();
        var hBtn:HorizontalLayout = new HorizontalLayout();
        hBtn.verticalAlign = VerticalAlign.MIDDLE;
        btnRow.layout = hBtn;
        addChild(btnRow);

        var spacer:LayoutGroup = new LayoutGroup();
        spacer.layoutData = new HorizontalLayoutData(100);
        btnRow.addChild(spacer);

        var removeBtn:Button = new Button();
        removeBtn.label = "remove";
        removeBtn.addEventListener(Event.TRIGGERED, _onRemove);
        btnRow.addChild(removeBtn);
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

    public function get data():Waypoint { return _data; }

    public function setData(d:Waypoint):void
    {
        _data = d;
        if (_data && _xStepper)
        {
            _xStepper.value = _data.x;
            _yStepper.value = _data.y;
            _radiusStepper.value = _data.radius;
            _strengthStepper.value = _data.strength;
            _attenuationStepper.value = _data.attenuationPower;
            _epsilonStepper.value = _data.epsilon;
        }
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        _data.x = _xStepper.value;
        _data.y = _yStepper.value;
        _data.radius = _radiusStepper.value;
        _data.strength = _strengthStepper.value;
        _data.attenuationPower = _attenuationStepper.value;
        _data.epsilon = _epsilonStepper.value;
    }

    private function _onRemove(e:Event):void
    {
        if (onRemove != null) onRemove(this);
    }
}
}
