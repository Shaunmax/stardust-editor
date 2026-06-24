package com.funkypandagame.stardust.view
{

import feathers.controls.Button;
import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.NumericStepper;
import feathers.controls.PickerList;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import com.funkypandagame.stardust.helpers.Globals;
import com.funkypandagame.stardust.view.events.LoadEmitterImageFromFileEvent;
import com.funkypandagame.stardust.controller.events.StartSimEvent;

import idv.cjcat.stardustextended.handlers.starling.StarlingHandler;

import flash.display.BitmapData;
import flash.events.EventDispatcher;

import starling.events.Event;

public class ParticleHandlerContainer extends LayoutGroup
{
    private var _smoothingCheck:Check;
    private var _premultiplyAlphaCheck:Check;
    private var _blendModeDDL:PickerList;
    private var _animSpeedStepper:NumericStepper;
    private var _randomFrameCheck:Check;
    private var _spriteSheetRow:LayoutGroup;
    private var _handler:StarlingHandler;
    private var _settingHandler:Boolean = false;

    public var bus:EventDispatcher;

    public function ParticleHandlerContainer()
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

        var row1:LayoutGroup = _hrow();

        _smoothingCheck = new Check(); _smoothingCheck.label = "Smoothing";
        _smoothingCheck.addEventListener(Event.CHANGE, _onPropsChange);
        row1.addChild(_smoothingCheck);

        _premultiplyAlphaCheck = new Check(); _premultiplyAlphaCheck.label = "Premultiply Alpha";
        _premultiplyAlphaCheck.addEventListener(Event.CHANGE, _onPropsChange);
        row1.addChild(_premultiplyAlphaCheck);

        var blendLbl:Label = new Label(); blendLbl.text = "Blendmode";
        row1.addChild(blendLbl);

        _blendModeDDL = new PickerList();
        _blendModeDDL.dataProvider = Globals.blendModesCollection;
        _blendModeDDL.width = 94;
        _blendModeDDL.addEventListener(Event.CHANGE, _onPropsChange);
        row1.addChild(_blendModeDDL);

        var row2:LayoutGroup = _hrow();

        var graphicLbl:Label = new Label(); graphicLbl.text = "Graphic";
        row2.addChild(graphicLbl);

        var browseBtn:Button = new Button(); browseBtn.label = "Browse";
        browseBtn.addEventListener(Event.TRIGGERED, _onBrowse);
        row2.addChild(browseBtn);

        _spriteSheetRow = new LayoutGroup();
        var sh:HorizontalLayout = new HorizontalLayout();
        sh.verticalAlign = VerticalAlign.MIDDLE; sh.gap = 4;
        _spriteSheetRow.layout = sh;
        row2.addChild(_spriteSheetRow);

        var animLbl:Label = new Label(); animLbl.text = "anim. speed(FPS)";
        _spriteSheetRow.addChild(animLbl);

        _animSpeedStepper = new NumericStepper();
        _animSpeedStepper.minimum = 0; _animSpeedStepper.maximum = 1000; _animSpeedStepper.step = 1;
        _animSpeedStepper.width = 50;
        _animSpeedStepper.addEventListener(Event.CHANGE, _onSpeedChange);
        _spriteSheetRow.addChild(_animSpeedStepper);

        _randomFrameCheck = new Check(); _randomFrameCheck.label = "start at random frame?";
        _randomFrameCheck.addEventListener(Event.CHANGE, _onPropsChange);
        _spriteSheetRow.addChild(_randomFrameCheck);
    }

    private function _hrow():LayoutGroup
    {
        var g:LayoutGroup = new LayoutGroup();
        var h:HorizontalLayout = new HorizontalLayout();
        h.verticalAlign = VerticalAlign.MIDDLE; h.gap = 4;
        g.layout = h;
        g.layoutData = new HorizontalLayoutData(100);
        addChild(g);
        return g;
    }

    public function setHandler(handler:StarlingHandler, handlerImages:Vector.<BitmapData>):void
    {
        _settingHandler = true;
        _handler = handler;
        _smoothingCheck.isSelected = handler.smoothing;
        _premultiplyAlphaCheck.isSelected = handler.premultiplyAlpha;
        _blendModeDDL.selectedItem = handler.blendMode;
        _animSpeedStepper.value = handler.spriteSheetAnimationSpeed;
        _randomFrameCheck.isSelected = handler.spriteSheetStartAtRandomFrame;
        _spriteSheetRow.visible = handler.isSpriteSheet;
        _spriteSheetRow.includeInLayout = handler.isSpriteSheet;
        _settingHandler = false;
    }

    private function _onPropsChange(e:Event):void
    {
        if (!_handler || _settingHandler) return;
        _handler.smoothing = _smoothingCheck.isSelected;
        _handler.premultiplyAlpha = _premultiplyAlphaCheck.isSelected;
        _handler.blendMode = String(_blendModeDDL.selectedItem);
        _handler.spriteSheetStartAtRandomFrame = _randomFrameCheck.isSelected;
    }

    private function _onSpeedChange(e:Event):void
    {
        if (!_handler || _settingHandler) return;
        var speed:int = int(_animSpeedStepper.value);
        if (speed < 0) { _animSpeedStepper.value = 0; speed = 0; }
        _handler.spriteSheetAnimationSpeed = speed;
        if (bus) bus.dispatchEvent(new StartSimEvent());
    }

    private function _onBrowse(e:Event):void
    {
        if (bus) bus.dispatchEvent(new LoadEmitterImageFromFileEvent());
    }
}
}
