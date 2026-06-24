package com.funkypandagame.stardust.view.importSim
{

import feathers.controls.Check;
import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.controls.renderers.LayoutGroupListItemRenderer;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import flash.display.BitmapData;
import flash.utils.Timer;
import flash.events.TimerEvent;

import starling.textures.Texture;

public class ImportEmitterRenderer extends LayoutGroupListItemRenderer
{
    private var _image:ImageLoader;
    private var _check:Check;
    private var _timer:Timer = new Timer(2000);
    private var _cnt:uint;
    private var _texture:Texture;

    public function ImportEmitterRenderer()
    {
        super();
        width = 100; height = 100;
    }

    override protected function initialize():void
    {
        super.initialize();
        layout = new AnchorLayout();

        _image = new ImageLoader();
        _image.layoutData = new AnchorLayoutData(0, 0, 0, 0);
        _image.maintainAspectRatio = true;
        addChild(_image);

        _check = new Check();
        _check.isEnabled = false;
        _check.layoutData = new AnchorLayoutData(NaN, 0, 0, NaN);
        addChild(_check);

        _timer.addEventListener(TimerEvent.TIMER, _onTimer);
    }

    override protected function commitData():void
    {
        super.commitData();
        _cnt = 0;
        _timer.stop();
        _timer.reset();

        if (_data is ImportedEmitter)
        {
            var iem:ImportedEmitter = ImportedEmitter(_data);
            _setImage(iem.emitterImages[0]);
            if (iem.emitterImages.length > 1) _timer.start();
        }
        else
        {
            _setImage(null);
        }
    }

    override protected function draw():void
    {
        if (isInvalid(INVALIDATION_FLAG_DATA))
        {
            commitData();
            _check.isSelected = isSelected;
        }
        super.draw();
    }

    private function _onTimer(e:TimerEvent):void
    {
        var iem:ImportedEmitter = _data as ImportedEmitter;
        if (!iem || !iem.emitterImages) return;
        _cnt++;
        if (_cnt >= iem.emitterImages.length) _cnt = 0;
        _setImage(iem.emitterImages[_cnt]);
    }

    private function _setImage(bd:BitmapData):void
    {
        if (_texture) { _texture.dispose(); _texture = null; }
        if (bd) { _texture = Texture.fromBitmapData(bd); _image.source = _texture; }
        else _image.source = null;
    }

    override public function dispose():void
    {
        _timer.stop();
        _timer.removeEventListener(TimerEvent.TIMER, _onTimer);
        if (_texture) { _texture.dispose(); _texture = null; }
        super.dispose();
    }
}
}
