package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.view.stardust.common.math.UniformRandomMath;
import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;

import feathers.controls.Check;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import idv.cjcat.stardustextended.actions.NormalDrift;
import idv.cjcat.stardustextended.math.UniformRandom;

import starling.events.Event;

public class NormalDriftAction extends PropertyRendererBase
{
    private var _randomMath:UniformRandomMath;
    private var _masslessCheck:Check;

    override protected function initialize():void
    {
        nameText = "Perpendicular accel.";
        super.initialize();
    }

    override protected function createContent():void
    {
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 6;
        contentContainer.layout = hLayout;

        _randomMath = new UniformRandomMath();
        contentContainer.addChild(_randomMath);

        _masslessCheck = new Check();
        _masslessCheck.label = "massless?";
        _masslessCheck.addEventListener(Event.CHANGE, _onChange);
        contentContainer.addChild(_masslessCheck);
    }

    override protected function commitData():void
    {
        super.commitData();
        if (!_data || !_masslessCheck) return;
        var d:NormalDrift = NormalDrift(_data);
        _masslessCheck.isSelected = d.massless;
        if (d.random is UniformRandom)
            _randomMath.setData(d.random as UniformRandom);
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        NormalDrift(_data).massless = _masslessCheck.isSelected;
    }
}
}
