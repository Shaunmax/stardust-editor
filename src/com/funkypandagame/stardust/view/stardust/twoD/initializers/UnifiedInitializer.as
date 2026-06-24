package com.funkypandagame.stardust.view.stardust.twoD.initializers
{

import feathers.controls.Button;
import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import com.funkypandagame.stardust.view.stardust.common.math.UniformRandomMath;
import com.funkypandagame.stardust.view.stardust.twoD.zones.ZoneContainer;
import com.funkypandagame.stardust.view.events.PositionInitializerEmitterPathEvent;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.initializers.Alpha;
import idv.cjcat.stardustextended.initializers.Initializer;
import idv.cjcat.stardustextended.initializers.Life;
import idv.cjcat.stardustextended.initializers.Mass;
import idv.cjcat.stardustextended.initializers.Omega;
import idv.cjcat.stardustextended.initializers.PositionAnimated;
import idv.cjcat.stardustextended.initializers.Rotation;
import idv.cjcat.stardustextended.initializers.Scale;
import idv.cjcat.stardustextended.initializers.Velocity;
import idv.cjcat.stardustextended.math.UniformRandom;

import flash.events.EventDispatcher;

import starling.display.Quad;

import starling.events.Event;
import starling.utils.Color;

public class UnifiedInitializer extends LayoutGroup
{
    public var bus:EventDispatcher;

    private var _posZc:ZoneContainer;
    private var _speedZc:ZoneContainer;
    private var _posAnimatedCheck:Check;
    private var _inheritVelocityCheck:Check;
    private var _loadPathBtn:Button;
    private var _lifeMath:UniformRandomMath;
    private var _alphaMath:UniformRandomMath;
    private var _scaleMath:UniformRandomMath;
    private var _rotStartMath:UniformRandomMath;
    private var _rotSpeedMath:UniformRandomMath;
    private var _massMath:UniformRandomMath;
    private var _position:PositionAnimated;

    public function UnifiedInitializer()
    {
        super();
        var v:VerticalLayout = new VerticalLayout();
        v.gap = 2; v.paddingLeft = 2; v.paddingRight = 2;
        layout = v;
        var skin:Quad = new Quad(50,50,Color.TEAL);
        backgroundSkin = skin;
    }

    override protected function initialize():void
    {
        super.initialize();

        // Position row
        var posRow:LayoutGroup = _hrow();
        _lbl("Position", posRow);
        var posCol:LayoutGroup = new LayoutGroup();
        var posColV:VerticalLayout = new VerticalLayout(); posColV.gap = 2;
        posCol.layout = posColV;
        posCol.layoutData = new HorizontalLayoutData(100);
        posRow.addChild(posCol);

        _posZc = new ZoneContainer();
        posCol.addChild(_posZc);

        var animRow:LayoutGroup = new LayoutGroup();
        var animH:HorizontalLayout = new HorizontalLayout();
        animH.verticalAlign = VerticalAlign.MIDDLE; animH.gap = 4;
        animRow.layout = animH;
        posCol.addChild(animRow);

        _posAnimatedCheck = new Check(); _posAnimatedCheck.label = "animated?";
        _posAnimatedCheck.addEventListener(Event.CHANGE, _onAnimatedChange);
        animRow.addChild(_posAnimatedCheck);

        _loadPathBtn = new Button(); _loadPathBtn.label = "Load emitter path from .swf";
        _loadPathBtn.isEnabled = false;
        _loadPathBtn.addEventListener(Event.TRIGGERED, _onLoadPath);
        animRow.addChild(_loadPathBtn);

        _inheritVelocityCheck = new Check(); _inheritVelocityCheck.label = "inherit velocity";
        _inheritVelocityCheck.isEnabled = false;
        _inheritVelocityCheck.addEventListener(Event.CHANGE, _onInheritVelocityChange);
        animRow.addChild(_inheritVelocityCheck);

        // Lifespan row
        var lifeRow:LayoutGroup = _hrow();
        _lbl("Lifespan (secs)", lifeRow);
        _lifeMath = new UniformRandomMath(); lifeRow.addChild(_lifeMath);

        // Speed row
        var speedRow:LayoutGroup = _hrow();
        _lbl("Speed (points/sec)", speedRow);
        _speedZc = new ZoneContainer();
        _speedZc.zeroAreaZonesVisible = false;
        speedRow.addChild(_speedZc);

        // Alpha row
        var alphaRow:LayoutGroup = _hrow();
        _lbl("Alpha", alphaRow);
        _alphaMath = new UniformRandomMath(); alphaRow.addChild(_alphaMath);

        // Scale row
        var scaleRow:LayoutGroup = _hrow();
        _lbl("Scale", scaleRow);
        _scaleMath = new UniformRandomMath(); scaleRow.addChild(_scaleMath);

        // Rotation row
        var rotRow:LayoutGroup = _hrow();
        _lbl("Rotation   starting", rotRow);
        _rotStartMath = new UniformRandomMath(); rotRow.addChild(_rotStartMath);
        _lbl("speed", rotRow);
        _rotSpeedMath = new UniformRandomMath(); rotRow.addChild(_rotSpeedMath);

        // Mass row
        var massRow:LayoutGroup = _hrow();
        _lbl("Mass", massRow);
        _massMath = new UniformRandomMath(); massRow.addChild(_massMath);
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

    private function _lbl(t:String, p:LayoutGroup):void
    {
        var l:Label = new Label(); l.text = t; p.addChild(l);
    }

    public function setData(emitter:Emitter):void
    {
        for each (var init:Initializer in emitter.initializers)
        {
            if (init is PositionAnimated)
            {
                _position = PositionAnimated(init);
                _posZc.setData(_position);
                _posAnimatedCheck.isSelected = (_position.positions != null);
                _inheritVelocityCheck.isSelected = _position.inheritVelocity;
                _inheritVelocityCheck.isEnabled = _posAnimatedCheck.isSelected;
                _loadPathBtn.isEnabled = _posAnimatedCheck.isSelected;
            }
            else if (init is Life)
                _lifeMath.setData(Life(init).random as UniformRandom);
            else if (init is Velocity)
                _speedZc.setData(Velocity(init));
            else if (init is Alpha)
                _alphaMath.setData(Alpha(init).random as UniformRandom);
            else if (init is Scale)
                _scaleMath.setData(Scale(init).random as UniformRandom);
            else if (init is Rotation)
                _rotStartMath.setData(Rotation(init).random as UniformRandom);
            else if (init is Omega)
                _rotSpeedMath.setData(Omega(init).random as UniformRandom);
            else if (init is Mass)
                _massMath.setData(Mass(init).random as UniformRandom);
        }
    }

    private function _onAnimatedChange(e:Event):void
    {
        var on:Boolean = _posAnimatedCheck.isSelected;
        _loadPathBtn.isEnabled = on;
        _inheritVelocityCheck.isEnabled = on;
        if (!on && _position) _position.positions = null;
    }

    private function _onInheritVelocityChange(e:Event):void
    {
        if (_position) _position.inheritVelocity = _inheritVelocityCheck.isSelected;
    }

    private function _onLoadPath(e:Event):void
    {
        if (bus) bus.dispatchEvent(new PositionInitializerEmitterPathEvent(PositionInitializerEmitterPathEvent.LOAD));
    }
}
}
