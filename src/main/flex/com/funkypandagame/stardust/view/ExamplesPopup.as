package com.funkypandagame.stardust.view
{

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Panel;
import feathers.layout.VerticalLayout;

import feathers.core.PopUpManager;

import flash.utils.ByteArray;

import starling.events.Event;

public class ExamplesPopup extends Panel
{
    [Embed(source="../../../../../resources/blazing_fire.sde", mimeType="application/octet-stream")]
    private static const BlazingFireSim:Class;

    [Embed(source="../../../../../resources/simple_fireworks.sde", mimeType="application/octet-stream")]
    private static const SimpleFireworkSim:Class;

    [Embed(source="../../../../../resources/big_explosion.sde", mimeType="application/octet-stream")]
    private static const BigExplosionSim:Class;

    [Embed(source="../../../../../resources/rocket.sde", mimeType="application/octet-stream")]
    private static const RocketSim:Class;

    [Embed(source="../../../../../resources/dry_ice.sde", mimeType="application/octet-stream")]
    private static const DryIceSim:Class;

    [Embed(source="../../../../../resources/snowfall.sde", mimeType="application/octet-stream")]
    private static const SnowfallSim:Class;

    [Embed(source="../../../../../resources/coins_particles.sde", mimeType="application/octet-stream")]
    private static const CoinShowerSim:Class;

    [Embed(source="../../../../../resources/glitter_burst.sde", mimeType="application/octet-stream")]
    private static const GlitterBurst:Class;

    public var callback:Function;  // function(sdeFile:ByteArray, name:String):void

    public function ExamplesPopup()
    {
        super();
        title = "Examples";
        width = 650;
    }

    override protected function initialize():void
    {
        super.initialize();

        var v:VerticalLayout = new VerticalLayout(); v.gap = 2;
        layout = v;

        var warning:Label = new Label();
        warning.text = "WARNING: If you load a new simulation you will lose all your unsaved changes!";
        addChild(warning);

        _addExample(new BlazingFireSim() as ByteArray, "blazingFire",
            "Blazing fire — Shows how to use the Color Curve action to alter a particle's color and alpha over time.");
        _addExample(new SimpleFireworkSim() as ByteArray, "fireworks",
            "Simple fireworks — Example of the Spawn action. New particles are spawned upon another particle's death.");
        _addExample(new BigExplosionSim() as ByteArray, "bigExplosion",
            "Big explosion — To make the explosion bright the premultiplied alpha is turned off.");
        _addExample(new RocketSim() as ByteArray, "rocket",
            "Rocket + smoke trail — Example of the Spawn action. New particles are spawned while another is alive.");
        _addExample(new DryIceSim() as ByteArray, "dryIce",
            "Dry ice — A quite heavy simulation because it renders a lot of big particles.");
        _addExample(new SnowfallSim() as ByteArray, "snowfall",
            "Snowfall — Simple snowfall + obstacles in the way of the snow.");
        _addExample(new CoinShowerSim() as ByteArray, "coinShower",
            "Coin shower — Shows how animated particles can look and how to use multiple emitters.");
        _addExample(new GlitterBurst() as ByteArray, "glitterBurst",
            "Confetti — Confetti/glitter explosion. The animated particles are another way to change colors.");

        var closeBtn:Button = new Button(); closeBtn.label = "Close";
        closeBtn.addEventListener(Event.TRIGGERED, _onClose);
        addChild(closeBtn);
    }

    private function _addExample(sde:ByteArray, name:String, desc:String):void
    {
        var r:ExampleRenderer = new ExampleRenderer();
        r.sdeFile = sde;
        r.nameToDisplay = name;
        r.description = desc;
        r.callback = _loadSim;
        addChild(r);
    }

    private function _loadSim(sdeFile:ByteArray, name:String):void
    {
        PopUpManager.removePopUp(this);
        if (callback != null) callback(sdeFile, name);
    }

    private function _onClose(e:Event):void
    {
        PopUpManager.removePopUp(this);
    }
}
}
