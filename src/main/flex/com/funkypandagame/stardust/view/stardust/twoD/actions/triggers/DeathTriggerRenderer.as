package com.funkypandagame.stardust.view.stardust.twoD.actions.triggers
{

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import idv.cjcat.stardustextended.actions.triggers.DeathTrigger;
import idv.cjcat.stardustextended.actions.triggers.Trigger;

public class DeathTriggerRenderer extends LayoutGroup implements ITriggerRenderer
{
    private var _trigger:DeathTrigger;

    override protected function initialize():void
    {
        super.initialize();
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        layout = hLayout;

        var lbl:Label = new Label();
        lbl.text = "Trigger is activated when a particle dies";
        addChild(lbl);
    }

    public function setData(d:Trigger):void
    {
        _trigger = DeathTrigger(d);
    }
}
}
