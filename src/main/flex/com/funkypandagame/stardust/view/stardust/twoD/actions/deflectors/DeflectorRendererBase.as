package com.funkypandagame.stardust.view.stardust.twoD.actions.deflectors
{

import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import starling.events.Event;
import starling.events.EventDispatcher;

public class DeflectorRendererBase extends LayoutGroup
{
    public var onRemove:Function;

    protected var _data:Object;
    protected var _contentRow1:LayoutGroup;
    protected var _contentRow2:LayoutGroup;
    private var _removeBtn:Button;

    override protected function initialize():void
    {
        super.initialize();

        var vLayout:VerticalLayout = new VerticalLayout();
        vLayout.gap = 2;
        layout = vLayout;

        _contentRow1 = new LayoutGroup();
        var h1:HorizontalLayout = new HorizontalLayout();
        h1.verticalAlign = VerticalAlign.MIDDLE;
        h1.gap = 4;
        _contentRow1.layout = h1;
        addChild(_contentRow1);

        _contentRow2 = new LayoutGroup();
        var h2:HorizontalLayout = new HorizontalLayout();
        h2.verticalAlign = VerticalAlign.MIDDLE;
        h2.gap = 4;
        _contentRow2.layout = h2;

        var btnRow:LayoutGroup = new LayoutGroup();
        var hBtn:HorizontalLayout = new HorizontalLayout();
        hBtn.verticalAlign = VerticalAlign.MIDDLE;
        btnRow.layout = hBtn;
        addChild(btnRow);

        var spacer:LayoutGroup = new LayoutGroup();
        spacer.layoutData = new HorizontalLayoutData(100);
        btnRow.addChild(spacer);

        _removeBtn = new Button();
        _removeBtn.label = "remove";
        _removeBtn.addEventListener(Event.TRIGGERED, _onRemove);
        btnRow.addChild(_removeBtn);

        createContent();
    }

    protected function createContent():void {}

    public function get data():Object { return _data; }

    public function setData(d:Object):void
    {
        _data = d;
        if (_data) commitData();
    }

    protected function commitData():void {}

    private function _onRemove(e:Event):void
    {
        if (onRemove != null) onRemove(this);
    }
}
}
