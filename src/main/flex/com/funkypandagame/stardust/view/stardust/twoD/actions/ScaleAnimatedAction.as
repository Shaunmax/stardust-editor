package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.TextInput;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import idv.cjcat.stardustextended.actions.ScaleAnimated;

import starling.events.Event;

public class ScaleAnimatedAction extends PropertyRendererBase
{
    private var _ratiosInput:TextInput;
    private var _scalesInput:TextInput;

    override protected function initialize():void
    {
        nameText = "Change scale";
        super.initialize();
    }

    override protected function createContent():void
    {
        var vLayout:VerticalLayout = new VerticalLayout();
        vLayout.gap = 2;
        contentContainer.layout = vLayout;

        var row:LayoutGroup = new LayoutGroup();
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 4;
        row.layout = hLayout;
        contentContainer.addChild(row);

        var lbl1:Label = new Label(); lbl1.text = "ratios (0..255)";
        row.addChild(lbl1);
        _ratiosInput = new TextInput();
        _ratiosInput.layoutData = new HorizontalLayoutData(100);
        _ratiosInput.addEventListener(Event.CHANGE, _onChange);
        row.addChild(_ratiosInput);

        var lbl2:Label = new Label(); lbl2.text = "scales";
        row.addChild(lbl2);
        _scalesInput = new TextInput();
        _scalesInput.layoutData = new HorizontalLayoutData(100);
        _scalesInput.addEventListener(Event.CHANGE, _onChange);
        row.addChild(_scalesInput);
    }

    override protected function commitData():void
    {
        super.commitData();
        if (!_data || !_ratiosInput) return;
        var d:ScaleAnimated = ScaleAnimated(_data);
        _ratiosInput.text = d.ratios.toString();
        _scalesInput.text = d.scales.toString();
    }

    private function _onChange(e:Event):void
    {
        if (!_data) return;
        var ratiosArr:Array = _ratiosInput.text.split(",");
        var scalesArr:Array = _scalesInput.text.split(",");
        if (ratiosArr.length != scalesArr.length || ratiosArr.length < 2) return;
        var prev:Number = -1;
        for (var j:int = 0; j < ratiosArr.length; j++)
        {
            var num:int = int(ratiosArr[j]);
            if (j == 0 && num != 0) return;
            if (j == ratiosArr.length - 1 && num != 255) return;
            if (j > 0 && prev >= num) return;
            prev = num;
        }
        var ratiosNums:Array = [];
        var scalesNums:Array = [];
        for (var k:int = 0; k < ratiosArr.length; k++)
        {
            ratiosNums.push(int(ratiosArr[k]));
            scalesNums.push(Number(scalesArr[k]));
        }
        ScaleAnimated(_data).setGradient(ratiosNums, scalesNums);
    }
}
}
