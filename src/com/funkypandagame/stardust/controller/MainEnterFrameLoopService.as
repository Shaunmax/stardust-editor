package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.helpers.ZoneDrawer;
import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardustplayer.SimPlayer;

import flash.display.Graphics;
import flash.utils.getTimer;

import idv.cjcat.stardustextended.handlers.starling.StardustStarlingRenderer;

import starling.core.Starling;

public class MainEnterFrameLoopService
{
    private var _project:ProjectModel;
    private var _simPlayer:SimPlayer;
    private var _graphics:Graphics;
    private var _zonesVisible:Function;
    private var _onStatsUpdate:Function;

    public var calcTime:uint;
    private var _count:uint;
    private var _frameTime:Number = 0;

    public function MainEnterFrameLoopService(project:ProjectModel, simPlayer:SimPlayer)
    {
        _project = project;
        _simPlayer = simPlayer;
    }

    public function init(graphics:Graphics, zonesVisible:Function, onStatsUpdate:Function):void
    {
        _graphics = graphics;
        _zonesVisible = zonesVisible;
        _onStatsUpdate = onStatsUpdate;
    }

    public function onEnterFrame():void
    {
        const startTime:Number = getTimer();
        _frameTime = startTime - _frameTime;
        if (_frameTime > 1000) _frameTime = 0;

        if (calcTime > 1000)
        {
            _onStatsUpdate("WARN: Simulation step took " + calcTime + "ms, skipping frame");
            calcTime = 0;
            _frameTime = getTimer();
            return;
        }

        _simPlayer.stepSimulation(_frameTime / 1000);
        Starling.current.stage.setRequiresRedraw();
        calcTime = (getTimer() - startTime);

        if (_count % 4 == 0)
        {
            var statsText:String = "num particles: " + _project.stadustSim.numberOfParticles + " sim time: " + calcTime;
            if (_project.stadustSim.numberOfParticles > StardustStarlingRenderer.MAX_POSSIBLE_PARTICLES)
                statsText += " Particles over " + StardustStarlingRenderer.MAX_POSSIBLE_PARTICLES + " will not be rendered.";
            _onStatsUpdate(statsText);
        }

        if (_zonesVisible != null && _zonesVisible())
            ZoneDrawer.drawEmitterZones();
        else if (_graphics != null)
            _graphics.clear();

        _count++;
        _frameTime = getTimer();
    }
}
}
