package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;

import feathers.controls.Label;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import idv.cjcat.stardustextended.actions.ColorGradient;

public class ColorCurveAdvancedAction extends PropertyRendererBase
{
    override protected function initialize():void
    {
        nameText = "Color curve";
        super.initialize();
    }

    override protected function createContent():void
    {
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        contentContainer.layout = hLayout;

        var lbl:Label = new Label();
        lbl.text = "Color gradient (use .sde XML editor to modify)";
        contentContainer.addChild(lbl);
    }

    override protected function commitData():void
    {
        super.commitData();
        // Color gradient editing is not supported in this version
    }
}
}
