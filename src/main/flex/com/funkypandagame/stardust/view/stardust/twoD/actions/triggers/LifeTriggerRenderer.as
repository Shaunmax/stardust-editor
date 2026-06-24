package com.funkypandagame.stardust.view.stardust.twoD.actions.triggers
{

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import idv.cjcat.stardustextended.actions.triggers.LifeTrigger;
import idv.cjcat.stardustextended.actions.triggers.Trigger;

public class LifeTriggerRenderer extends LayoutGroup implements ITriggerRenderer
{
    private var _trigger:LifeTrigger;

    override protected function initialize():void
    {
        super.initialize();
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        layout = hLayout;

        var lbl:Label = new Label();
        lbl.text = "Trigger every step";
        addChild(lbl);
    }

    public function setData(d:Trigger):void
    {
        _trigger = LifeTrigger(d);
    }
}
}
