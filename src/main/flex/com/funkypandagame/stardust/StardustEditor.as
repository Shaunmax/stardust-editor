package com.funkypandagame.stardust
{

import com.funkypandagame.stardust.config.AppController;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.utils.ByteArray;

import starling.core.Starling;

[SWF(width="1280", height="800", frameRate="60", backgroundColor="#1A1A1A")]
public class StardustEditor extends Sprite
{
    private var _starling:Starling;

    public function StardustEditor()
    {
        if (stage) init();
        else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(e:Event):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        init();
    }

    private function init():void
    {
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;

        Starling.multitouchEnabled = false;

        _starling = new Starling(AppRoot, stage);
        _starling.antiAliasing = 1;
        _starling.showStats = false;
        _starling.start();
    }

    /** Called by the AIR wrapper to load a sim file directly from disk. */
    public function loadExternalSim(bytes:ByteArray, nameToDisplay:String):void
    {
        if (AppController.instance) AppController.instance.loadExternalSim(bytes, nameToDisplay);
    }
}
}
