package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.controller.events.StartSimEvent;
import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardustplayer.project.ProjectValueObject;

import flash.events.EventDispatcher;

import idv.cjcat.stardustextended.actions.Accelerate;
import idv.cjcat.stardustextended.actions.Action;
import idv.cjcat.stardustextended.actions.AlphaCurve;
import idv.cjcat.stardustextended.actions.FollowWaypoints;
import idv.cjcat.stardustextended.actions.Gravity;
import idv.cjcat.stardustextended.actions.IFieldContainer;
import idv.cjcat.stardustextended.actions.RandomDrift;
import idv.cjcat.stardustextended.actions.ScaleCurve;
import idv.cjcat.stardustextended.actions.SpeedLimit;
import idv.cjcat.stardustextended.actions.waypoints.Waypoint;
import idv.cjcat.stardustextended.clocks.ImpulseClock;
import idv.cjcat.stardustextended.clocks.SteadyClock;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.fields.Field;
import idv.cjcat.stardustextended.fields.RadialField;
import idv.cjcat.stardustextended.fields.UniformField;
import idv.cjcat.stardustextended.handlers.ISpriteSheetHandler;
import idv.cjcat.stardustextended.initializers.Initializer;
import idv.cjcat.stardustextended.initializers.Life;
import idv.cjcat.stardustextended.initializers.Omega;
import idv.cjcat.stardustextended.initializers.Velocity;
import idv.cjcat.stardustextended.math.AveragedRandom;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.zones.CircleContour;
import idv.cjcat.stardustextended.zones.CircleZone;
import idv.cjcat.stardustextended.zones.Composite;
import idv.cjcat.stardustextended.zones.Line;
import idv.cjcat.stardustextended.zones.RectContour;
import idv.cjcat.stardustextended.zones.RectZone;
import idv.cjcat.stardustextended.zones.Sector;
import idv.cjcat.stardustextended.zones.Zone;

public class ConvertOldSimCommand
{
    private var _bus:EventDispatcher;
    private var _projectModel:ProjectModel;

    public function ConvertOldSimCommand(bus:EventDispatcher, model:ProjectModel)
    {
        _bus = bus;
        _projectModel = model;
    }

    public function execute():void
    {
        var pvo:ProjectValueObject = _projectModel.stadustSim;
        for each (var em:Emitter in pvo.emittersArr)
        {
            if (em.particleHandler is ISpriteSheetHandler)
            {
                var sh:ISpriteSheetHandler = ISpriteSheetHandler(em.particleHandler);
                sh.spriteSheetAnimationSpeed = 60 / sh.spriteSheetAnimationSpeed;
            }
            if (em.clock is SteadyClock)
            {
                var sClock:SteadyClock = SteadyClock(em.clock);
                convertRandom(sClock.initialDelay, 1/60);
                sClock.ticksPerCall = sClock.ticksPerCall * 60;
            }
            else if (em.clock is ImpulseClock)
            {
                var iClock:ImpulseClock = ImpulseClock(em.clock);
                convertRandom(iClock.initialDelay, 1/60);
                convertRandom(iClock.impulseLength, 1/60);
                convertRandom(iClock.impulseInterval, 1/60);
                iClock.ticksPerCall = iClock.ticksPerCall * 60;
            }
            for each (var init:Initializer in em.initializers)
            {
                if (init is Life) convertRandom(Life(init).random, 1/60);
                else if (init is Velocity) convertZones(Velocity(init).zones, 60);
                else if (init is Omega) convertRandom(Omega(init).random, 60);
            }
            for each (var act:Action in em.actions)
            {
                if (act is ScaleCurve)
                {
                    ScaleCurve(act).inLifespan = reducePrecision(ScaleCurve(act).inLifespan / 60);
                    ScaleCurve(act).outLifespan = reducePrecision(ScaleCurve(act).outLifespan / 60);
                }
                if (act is AlphaCurve)
                {
                    AlphaCurve(act).inLifespan = reducePrecision(AlphaCurve(act).inLifespan / 60);
                    AlphaCurve(act).outLifespan = reducePrecision(AlphaCurve(act).outLifespan / 60);
                }
                else if (act is SpeedLimit) SpeedLimit(act).limit = SpeedLimit(act).limit * 60;
                else if (act is RandomDrift)
                {
                    RandomDrift(act).maxX = reducePrecision(RandomDrift(act).maxX * 60);
                    RandomDrift(act).maxY = reducePrecision(RandomDrift(act).maxY * 60);
                }
                else if (act is Gravity) convertFields(Gravity(act), 30);
                else if (act is Accelerate) Accelerate(act).acceleration = reducePrecision(Accelerate(act).acceleration * 60);
                else if (act is FollowWaypoints)
                {
                    for each (var wp:Waypoint in FollowWaypoints(act).waypoints)
                        wp.strength = reducePrecision(wp.strength * 60);
                }
            }
        }
        _bus.dispatchEvent(new StartSimEvent());
    }

    private static function convertFields(fc:IFieldContainer, mult:Number):void
    {
        for each (var f:Field in fc.fields)
        {
            if (f is UniformField)
            {
                UniformField(f).x = reducePrecision(UniformField(f).x * mult);
                UniformField(f).y = reducePrecision(UniformField(f).y * mult);
            }
        }
    }

    private static function convertRandom(rnd:Random, mult:Number):void
    {
        if (rnd is UniformRandom)
        {
            UniformRandom(rnd).center = reducePrecision(UniformRandom(rnd).center * mult);
            UniformRandom(rnd).radius = reducePrecision(UniformRandom(rnd).radius * mult);
        }
        else if (rnd is AveragedRandom) convertRandom(AveragedRandom(rnd).randomObj, mult);
    }

    private static function convertZones(zones:Vector.<Zone>, mult:Number):void
    {
        for each (var z:Zone in zones)
        {
            z.x = reducePrecision(z.x * mult);
            z.y = reducePrecision(z.y * mult);
            if (z is Line) { Line(z).x2 = reducePrecision(Line(z).x2 * mult); Line(z).y2 = reducePrecision(Line(z).y2 * mult); }
            else if (z is RectZone) { RectZone(z).height = reducePrecision(RectZone(z).height * mult); RectZone(z).width = reducePrecision(RectZone(z).width * mult); }
            else if (z is RectContour) { RectContour(z).height = reducePrecision(RectContour(z).height * mult); RectContour(z).width = reducePrecision(RectContour(z).width * mult); }
            else if (z is CircleZone) CircleZone(z).radius = reducePrecision(CircleZone(z).radius * mult);
            else if (z is CircleContour) CircleContour(z).radius = reducePrecision(CircleContour(z).radius * mult);
            else if (z is Sector) { Sector(z).maxRadius = reducePrecision(Sector(z).maxRadius * mult); Sector(z).minRadius = reducePrecision(Sector(z).minRadius * mult); }
            else if (z is Composite) convertZones(Composite(z).zones, mult);
        }
    }

    private static function reducePrecision(num:Number):Number
    {
        return Math.round(num * 100) / 100;
    }
}
}
