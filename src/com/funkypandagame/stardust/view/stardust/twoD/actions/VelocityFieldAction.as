package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;
import com.funkypandagame.stardust.view.stardust.twoD.fields.FieldContainer;

import feathers.layout.VerticalLayout;

import idv.cjcat.stardustextended.actions.VelocityField;
import idv.cjcat.stardustextended.fields.Field;

import starling.events.Event;

public class VelocityFieldAction extends PropertyRendererBase
{
    private var _fieldContainer:FieldContainer;

    override protected function initialize():void
    {
        nameText = "Velocity field";
        super.initialize();
    }

    override protected function createContent():void
    {
        contentContainer.layout = new VerticalLayout();

        _fieldContainer = new FieldContainer();
        _fieldContainer.hasOnlyOneField = true;
        _fieldContainer.addEventListener(Event.CHANGE, _onChange);
        contentContainer.addChild(_fieldContainer);
    }

    override protected function commitData():void
    {
        super.commitData();
        if (!_data || !_fieldContainer) return;
        var d:VelocityField = VelocityField(_data);
        if (d.fields != null)
            _fieldContainer.setData(d.fields);
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        var fields:Vector.<Field> = _fieldContainer.getData();
        VelocityField(_data).fields = fields.length > 0 ? fields : null;
    }
}
}
