package com.funkypandagame.stardust.view.stardust.twoD.fields
{

import feathers.controls.Button;
import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.NumericStepper;
import feathers.controls.PickerList;
import feathers.data.ListCollection;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import flash.display.Bitmap;
import starling.events.Event;
import flash.events.Event;
import flash.net.FileFilter;
import flash.net.FileReference;

import idv.cjcat.stardustextended.fields.BitmapField;

public class BitmapFieldRenderer extends FieldRendererBase
{
    private static const CHANNELS:ListCollection = new ListCollection([1, 2, 4]);

    private static function _channelLabel(item:Object):String
    {
        if (item == 1) return "Red";
        if (item == 2) return "Green";
        return "Blue";
    }

    private var _masslessCheck:Check;
    private var _repeatCheck:Check;
    private var _maxStepper:NumericStepper;
    private var _xChannelList:PickerList;
    private var _yChannelList:PickerList;
    private var _xScaleStepper:NumericStepper;
    private var _yScaleStepper:NumericStepper;
    private var _fileRef:FileReference;

    override protected function createContent():void
    {
        _fileRef = new FileReference();
        _fileRef.addEventListener(flash.events.Event.SELECT, _onFileSelect);
        _fileRef.addEventListener(flash.events.Event.COMPLETE, _onFileComplete);

        var vLayout:VerticalLayout = new VerticalLayout();
        vLayout.gap = 2;
        contentContainer.layout = vLayout;

        // Row 1
        var row1:LayoutGroup = _hgroup();
        contentContainer.addChild(row1);
        var browseBtn:Button = new Button();
        browseBtn.label = "Set bitmap";
        browseBtn.addEventListener(starling.events.Event.TRIGGERED, _onBrowse);
        row1.addChild(browseBtn);
        _repeatCheck = new Check();
        _repeatCheck.label = "repeat";
        _repeatCheck.addEventListener(starling.events.Event.CHANGE, _onChange);
        row1.addChild(_repeatCheck);

        // Row 2
        var row2:LayoutGroup = _hgroup();
        contentContainer.addChild(row2);
        _masslessCheck = new Check();
        _masslessCheck.label = "massless";
        _masslessCheck.addEventListener(starling.events.Event.CHANGE, _onChange);
        row2.addChild(_masslessCheck);
        row2.addChild(_label("max strength"));
        _maxStepper = new NumericStepper();
        _maxStepper.step = 0.1;
        _maxStepper.width = 60;
        _maxStepper.addEventListener(starling.events.Event.CHANGE, _onChange);
        row2.addChild(_maxStepper);

        // Row 3
        var row3:LayoutGroup = _hgroup();
        contentContainer.addChild(row3);
        row3.addChild(_label("Channel: horizontal"));
        _xChannelList = _channelPicker(row3);
        row3.addChild(_label("vertical"));
        _yChannelList = _channelPicker(row3);

        // Row 4
        var row4:LayoutGroup = _hgroup();
        contentContainer.addChild(row4);
        row4.addChild(_label("Bitmap scale: h"));
        _xScaleStepper = _numericStepper(row4);
        row4.addChild(_label("v"));
        _yScaleStepper = _numericStepper(row4);
    }

    private function _label(t:String):Label { var l:Label = new Label(); l.text = t; return l; }

    private function _hgroup():LayoutGroup
    {
        var g:LayoutGroup = new LayoutGroup();
        var h:HorizontalLayout = new HorizontalLayout();
        h.verticalAlign = VerticalAlign.MIDDLE; h.gap = 4;
        g.layout = h;
        g.layoutData = new HorizontalLayoutData(100);
        return g;
    }

    private function _channelPicker(parent:LayoutGroup):PickerList
    {
        var p:PickerList = new PickerList();
        p.dataProvider = CHANNELS;
        p.labelFunction = _channelLabel;
        p.selectedIndex = 0;
        p.width = 80;
        p.addEventListener(starling.events.Event.CHANGE, _onChange);
        parent.addChild(p);
        return p;
    }

    private function _numericStepper(parent:LayoutGroup):NumericStepper
    {
        var s:NumericStepper = new NumericStepper();
        s.step = 0.1; s.width = 60;
        s.addEventListener(starling.events.Event.CHANGE, _onChange);
        parent.addChild(s);
        return s;
    }

    private function _onBrowse(e:starling.events.Event):void
    {
        _fileRef.browse([new FileFilter("Images", "*.gif;*.jpeg;*.jpg;*.png")]);
    }

    private function _onFileSelect(e:flash.events.Event):void { _fileRef.load(); }

    private function _onFileComplete(e:flash.events.Event):void
    {
        var loader:flash.display.Loader = new flash.display.Loader();
        loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, _onLoaded);
        loader.loadBytes(_fileRef.data);
    }

    private function _onLoaded(e:flash.events.Event):void
    {
        if (_data) BitmapField(_data).update(Bitmap(flash.display.LoaderInfo(e.target).content).bitmapData);
    }

    override protected function commitData():void
    {
        if (!_data) return;
        var d:BitmapField = BitmapField(_data);
        _masslessCheck.isSelected = d.massless;
        _repeatCheck.isSelected = d.tile;
        _maxStepper.value = d.max;
        _xChannelList.selectedItem = d.channelX;
        _yChannelList.selectedItem = d.channelY;
        _xScaleStepper.value = d.scaleX;
        _yScaleStepper.value = d.scaleY;
    }

    private function _onChange(e:Object):void
    {
        if (!_data) return;
        var d:BitmapField = BitmapField(_data);
        d.massless = _masslessCheck.isSelected;
        d.tile = _repeatCheck.isSelected;
        d.max = _maxStepper.value;
        d.channelX = uint(_xChannelList.selectedItem);
        d.channelY = uint(_yChannelList.selectedItem);
        d.scaleX = _xScaleStepper.value;
        d.scaleY = _yScaleStepper.value;
    }
}
}
