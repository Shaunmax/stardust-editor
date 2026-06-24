package com.funkypandagame.stardust.view
{

import feathers.controls.Button;
import feathers.controls.ImageLoader;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.NumericStepper;
import feathers.controls.Panel;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import feathers.core.PopUpManager;

import com.funkypandagame.stardust.helpers.SpriteSheetBitmapSlicedCache;

import flash.display.BitmapData;
import flash.utils.Timer;
import flash.events.TimerEvent;

import starling.events.Event;
import starling.textures.Texture;

public class SetEmitterImagePopup extends Panel
{
    private var _widthStepper:NumericStepper;
    private var _heightStepper:NumericStepper;
    private var _previewImage:ImageLoader;
    private var _infoLabel:Label;

    private var _onClose:Function;  // function(frameWidth:int, frameHeight:int):void
    private var _originalBD:BitmapData;
    private var _previews:Vector.<BitmapData>;
    private var _previewTexture:Texture;
    private var _cnt:uint;
    private var _timer:Timer = new Timer(600);

    public function SetEmitterImagePopup()
    {
        super();
        title = "Set source image slices";
        width = 420;
    }

    override protected function initialize():void
    {
        super.initialize();

        var v:VerticalLayout = new VerticalLayout();
        v.gap = 4; v.paddingLeft = 5; v.paddingRight = 5;
        v.paddingTop = 5; v.paddingBottom = 5;
        layout = v;

        var dimRow:LayoutGroup = new LayoutGroup();
        var h:HorizontalLayout = new HorizontalLayout();
        h.verticalAlign = VerticalAlign.MIDDLE; h.gap = 4;
        dimRow.layout = h;
        addChild(dimRow);

        var wLbl:Label = new Label(); wLbl.text = "Single image width";
        dimRow.addChild(wLbl);

        _widthStepper = new NumericStepper();
        _widthStepper.minimum = 1; _widthStepper.maximum = 2044; _widthStepper.step = 1; _widthStepper.width = 60;
        _widthStepper.addEventListener(Event.CHANGE, _onDimChange);
        dimRow.addChild(_widthStepper);

        var hLbl:Label = new Label(); hLbl.text = "height";
        dimRow.addChild(hLbl);

        _heightStepper = new NumericStepper();
        _heightStepper.minimum = 1; _heightStepper.maximum = 2044; _heightStepper.step = 1; _heightStepper.width = 60;
        _heightStepper.addEventListener(Event.CHANGE, _onDimChange);
        dimRow.addChild(_heightStepper);

        _previewImage = new ImageLoader();
        _previewImage.width = 400; _previewImage.height = 300;
        _previewImage.maintainAspectRatio = true;
        addChild(_previewImage);

        _infoLabel = new Label();
        addChild(_infoLabel);

        var doneBtn:Button = new Button(); doneBtn.label = "Done";
        doneBtn.addEventListener(Event.TRIGGERED, _onDone);
        addChild(doneBtn);

        _timer.addEventListener(TimerEvent.TIMER, _onTimer);
    }

    public function setImageSlices(bitmapData:BitmapData, onClose:Function):void
    {
        _onClose = onClose;
        _originalBD = bitmapData;
        _previews = new <BitmapData>[bitmapData];
        _cnt = 0;

        _widthStepper.value = bitmapData.width;
        _heightStepper.value = bitmapData.height;
        _infoLabel.text = "The emitter will have 1 image";

        _showPreview(bitmapData);
        _timer.reset();
        _timer.start();
    }

    private function _showPreview(bd:BitmapData):void
    {
        if (_previewTexture) { _previewTexture.dispose(); _previewTexture = null; }
        _previewTexture = Texture.fromBitmapData(bd);
        _previewImage.source = _previewTexture;
    }

    private function _onTimer(e:TimerEvent):void
    {
        if (!_previews || _previews.length == 0) return;
        _cnt++;
        if (_cnt >= _previews.length) _cnt = 0;
        _showPreview(_previews[_cnt]);
    }

    private function _onDimChange(e:Event):void
    {
        var w:int = int(_widthStepper.value);
        var h:int = int(_heightStepper.value);
        if (w < 1) { w = 1; _widthStepper.value = 1; }
        if (h < 1) { h = 1; _heightStepper.value = 1; }
        if (w > _originalBD.width) { w = _originalBD.width; _widthStepper.value = w; }
        if (h > _originalBD.height) { h = _originalBD.height; _heightStepper.value = h; }

        var slices:SpriteSheetBitmapSlicedCache = new SpriteSheetBitmapSlicedCache(_originalBD, w, h);
        _previews = slices.bds;
        _cnt = 0;
        _infoLabel.text = (_previews.length == 1)
            ? "The emitter will have 1 image"
            : "The emitter will be an animation with " + _previews.length + " images";
    }

    private function _onDone(e:Event):void
    {
        _timer.stop();
        _timer.removeEventListener(TimerEvent.TIMER, _onTimer);
        if (_previewTexture) { _previewTexture.dispose(); _previewTexture = null; }
        PopUpManager.removePopUp(this);
        if (_onClose != null)
            _onClose(int(_widthStepper.value), int(_heightStepper.value));
    }
}
}
