package com.funkypandagame.stardust
{

import com.funkypandagame.stardust.config.AppController;
import com.funkypandagame.stardust.helpers.Globals;

import feathers.themes.MetalWorksDesktopTheme;

import flash.display.Sprite;

import starling.core.Starling;
import starling.events.Event;

public class AppRoot extends starling.display.Sprite
{
    public function AppRoot()
    {
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(e:Event):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        new MetalWorksDesktopTheme();

        Globals.init();

        // Flash overlay sprite for zone drawing, positioned over the Starling viewport
        var overlay:Sprite = new Sprite();
        overlay.mouseEnabled = false;
        overlay.mouseChildren = false;
        Starling.current.nativeStage.addChild(overlay);

        // The shared Starling canvas for particle rendering
        Starling.current.stage.addChild(Globals.starlingCanvas);

        // Wire external event dispatcher so AIR wrapper gets title-change events
        Globals.externalEventDispatcher = Starling.current.nativeStage;

        var controller:AppController = new AppController(this, overlay);
        controller.start();
    }
}
}
