package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;
import com.funkypandagame.stardust.view.stardust.twoD.zones.ZoneContainer;

import feathers.controls.Check;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import idv.cjcat.stardustextended.actions.DeathZone;

import starling.events.Event;

public class DeathZoneAction extends PropertyRendererBase
{
    private var _invertedCheck:Check;
    private var _zoneContainer:ZoneContainer;

    override protected function initialize():void
    {
        nameText = "Die in zone";
        super.initialize();
    }

    override protected function createContent():void
    {
        var vLayout:VerticalLayout = new VerticalLayout();
        vLayout.gap = 4;
        contentContainer.layout = vLayout;

        var topRow:feathers.controls.LayoutGroup = new feathers.controls.LayoutGroup();
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 4;
        topRow.layout = hLayout;
        contentContainer.addChild(topRow);

        _invertedCheck = new Check();
        _invertedCheck.label = "Inverted?";
        _invertedCheck.addEventListener(Event.CHANGE, _onChange);
        topRow.addChild(_invertedCheck);

        _zoneContainer = new ZoneContainer();
        _zoneContainer.zeroAreaZonesVisible = false;
        contentContainer.addChild(_zoneContainer);
    }

    override protected function commitData():void
    {
        super.commitData();
        if (!_data || !_invertedCheck) return;
        var d:DeathZone = DeathZone(_data);
        _invertedCheck.isSelected = d.inverted;
        _zoneContainer.setData(d);
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        var d:DeathZone = DeathZone(_data);
        d.inverted = _invertedCheck.isSelected;
    }
}
}
