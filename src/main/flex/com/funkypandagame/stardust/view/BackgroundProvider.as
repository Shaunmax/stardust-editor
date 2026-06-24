package com.funkypandagame.stardust.view
{

import feathers.controls.Button;
import feathers.controls.Check;
import feathers.controls.LayoutGroup;
import feathers.layout.VerticalLayout;

import com.funkypandagame.stardust.controller.events.BackgroundChangeEvent;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.EventDispatcher;

import starling.core.Starling;
import starling.display.Image;
import starling.display.Quad;
import starling.events.Event;
import starling.textures.Texture;

public class BackgroundProvider extends LayoutGroup
{
    private var _hasBackgroundCheck:Check;
    private var _actAsForegroundCheck:Check;
    private var _loadImageBtn:Button;

    private var _starlingBg:starling.display.DisplayObject;
    private var _bgX:Number = 0;
    private var _bgY:Number = 0;
    private var _bgWidth:Number = 1;
    private var _bgHeight:Number = 1;

    public var bus:EventDispatcher;

    public function BackgroundProvider()
    {
        super();
        var v:VerticalLayout = new VerticalLayout();
        v.gap = 2; v.paddingLeft = 4; v.paddingRight = 4;
        v.paddingTop = 4; v.paddingBottom = 4;
        layout = v;
    }

    override protected function initialize():void
    {
        super.initialize();

        _hasBackgroundCheck = new Check(); _hasBackgroundCheck.label = "Background?";
        _hasBackgroundCheck.addEventListener(Event.CHANGE, _onHasBGChange);
        addChild(_hasBackgroundCheck);

        var optGroup:LayoutGroup = new LayoutGroup();
        var v:VerticalLayout = new VerticalLayout(); v.gap = 2;
        optGroup.layout = v;
        addChild(optGroup);

        _actAsForegroundCheck = new Check(); _actAsForegroundCheck.label = "Act as foreground";
        _actAsForegroundCheck.addEventListener(Event.CHANGE, _onForegroundChange);
        optGroup.addChild(_actAsForegroundCheck);

        _loadImageBtn = new Button(); _loadImageBtn.label = "Or image";
        _loadImageBtn.addEventListener(Event.TRIGGERED, _onLoadImage);
        optGroup.addChild(_loadImageBtn);
    }

    public function setBgImagePosition(xc:Number, yc:Number, wi:Number, he:Number):void
    {
        _bgX = xc; _bgY = yc;
        _bgWidth = Math.max(1, wi);
        _bgHeight = Math.max(1, he);
        _positionBg();
    }

    public function setData(hasBackground:Boolean, backgroundColor:uint, backgroundImage:flash.display.DisplayObject):void
    {
        if (_starlingBg && _starlingBg.parent)
        {
            _starlingBg.removeFromParent();
            _starlingBg.dispose();
            _starlingBg = null;
        }

        _hasBackgroundCheck.isSelected = hasBackground;
        if (hasBackground)
        {
            if (backgroundImage)
            {
                var bd:BitmapData = Bitmap(backgroundImage).bitmapData;
                _starlingBg = new Image(Texture.fromBitmapData(bd));
                Starling.current.stage.addChildAt(_starlingBg, 0);
            }
            else
            {
                _starlingBg = new Quad(_bgWidth, _bgHeight, backgroundColor);
                Starling.current.stage.addChildAt(_starlingBg, 0);
            }
            _positionBg();
        }
    }

    private function _positionBg():void
    {
        if (!_starlingBg) return;
        if (_starlingBg is Image)
        {
            _starlingBg.x = _bgX;
            _starlingBg.y = _bgY;
        }
        else
        {
            Quad(_starlingBg).width = _bgWidth;
            Quad(_starlingBg).height = _bgHeight;
            _starlingBg.x = StardusttoolMainView.LEFT_COLUMN_WIDTH;
            _starlingBg.y = 0;
        }
    }

    private function _onHasBGChange(e:Event):void
    {
        if (bus) bus.dispatchEvent(new BackgroundChangeEvent(BackgroundChangeEvent.HAS_BACKGROUND, _hasBackgroundCheck.isSelected));
    }

    private function _onForegroundChange(e:Event):void
    {
        if (_starlingBg)
        {
            if (_actAsForegroundCheck.isSelected)
                Starling.current.stage.setChildIndex(_starlingBg, Starling.current.stage.numChildren - 1);
            else
                Starling.current.stage.setChildIndex(_starlingBg, 0);
        }
    }

    private function _onLoadImage(e:Event):void
    {
        if (bus) bus.dispatchEvent(new BackgroundChangeEvent(BackgroundChangeEvent.IMAGE, null));
    }
}
}
