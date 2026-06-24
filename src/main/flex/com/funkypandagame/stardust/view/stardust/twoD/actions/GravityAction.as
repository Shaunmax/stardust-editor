package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;
import com.funkypandagame.stardust.view.stardust.twoD.fields.FieldContainer;

import feathers.layout.VerticalLayout;

import idv.cjcat.stardustextended.actions.Gravity;

import starling.events.Event;

public class GravityAction extends PropertyRendererBase
{
    private var _fieldContainer:FieldContainer;

    override protected function initialize():void
    {
        nameText = "Gravity";
        super.initialize();
    }

    override protected function createContent():void
    {
        contentContainer.layout = new VerticalLayout();

        _fieldContainer = new FieldContainer();
        _fieldContainer.addEventListener(Event.CHANGE, _onChange);
        contentContainer.addChild(_fieldContainer);
    }

    override protected function commitData():void
    {
        super.commitData();
        if (!_data || !_fieldContainer) return;
        _fieldContainer.setData(Gravity(_data).fields);
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        Gravity(_data).fields = _fieldContainer.getData();
    }
}
}
