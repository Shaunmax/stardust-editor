package com.funkypandagame.stardust.helpers
{

import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardust.view.stardust.twoD.actions.AccelerateAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.AccelerationZoneAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.AgeAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.AlphaCurveAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.ColorCurveAdvancedAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.DampingAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.DeathLifeAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.DeathZoneAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.DeflectAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.FollowWaypointsAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.GravityAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.MoveAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.NormalDriftAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.OrientedAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.RandomDriftAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.ScaleAnimatedAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.ScaleCurveAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.SpawnAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.SpeedLimitAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.SpinAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.VelocityFieldAction;
import com.funkypandagame.stardust.view.stardust.twoD.actions.triggers.DeathTriggerRenderer;
import com.funkypandagame.stardust.view.stardust.twoD.actions.triggers.LifeTriggerRenderer;
import com.funkypandagame.stardust.view.stardust.twoD.zones.CircleContourZone;
import com.funkypandagame.stardust.view.stardust.twoD.zones.CircleZoneRenderer;
import com.funkypandagame.stardust.view.stardust.twoD.zones.LineZone;
import com.funkypandagame.stardust.view.stardust.twoD.zones.RectContourZone;
import com.funkypandagame.stardust.view.stardust.twoD.zones.RectZoneRenderer;
import com.funkypandagame.stardust.view.stardust.twoD.zones.SectorZone;
import com.funkypandagame.stardust.view.stardust.twoD.zones.SinglePointZone;

import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.TextEvent;
import flash.utils.Dictionary;

import feathers.data.ListCollection;

import idv.cjcat.stardustextended.actions.Age;
import idv.cjcat.stardustextended.actions.AlphaCurve;
import idv.cjcat.stardustextended.actions.ColorGradient;
import idv.cjcat.stardustextended.actions.DeathLife;
import idv.cjcat.stardustextended.actions.ScaleCurve;
import idv.cjcat.stardustextended.actions.triggers.DeathTrigger;
import idv.cjcat.stardustextended.actions.triggers.LifeTrigger;
import idv.cjcat.stardustextended.actions.Accelerate;
import idv.cjcat.stardustextended.actions.AccelerationZone;
import idv.cjcat.stardustextended.actions.Damping;
import idv.cjcat.stardustextended.actions.DeathZone;
import idv.cjcat.stardustextended.actions.Deflect;
import idv.cjcat.stardustextended.actions.FollowWaypoints;
import idv.cjcat.stardustextended.actions.Gravity;
import idv.cjcat.stardustextended.actions.Move;
import idv.cjcat.stardustextended.actions.NormalDrift;
import idv.cjcat.stardustextended.actions.Oriented;
import idv.cjcat.stardustextended.actions.RandomDrift;
import idv.cjcat.stardustextended.actions.ScaleAnimated;
import idv.cjcat.stardustextended.actions.Spawn;
import idv.cjcat.stardustextended.actions.SpeedLimit;
import idv.cjcat.stardustextended.actions.Spin;
import idv.cjcat.stardustextended.actions.VelocityField;
import idv.cjcat.stardustextended.zones.CircleContour;
import idv.cjcat.stardustextended.zones.CircleZone;
import idv.cjcat.stardustextended.zones.Line;
import idv.cjcat.stardustextended.zones.RectContour;
import idv.cjcat.stardustextended.zones.RectZone;
import idv.cjcat.stardustextended.zones.Sector;
import idv.cjcat.stardustextended.zones.SinglePoint;

import starling.display.BlendMode;
import starling.display.Sprite;

public class Globals
{
    public static const starlingCanvas:Sprite = new Sprite();

    /** Set by AppController at startup so SpawnAction renderer can access emitter list */
    public static var projectModel:ProjectModel;

    public static const actionDict:Dictionary = new Dictionary();
    public static var actionsCollection:ListCollection;

    public static const zonesDict:Dictionary = new Dictionary();
    public static var zonesCollection:ListCollection;
    public static var noZeroAreaZonesCollection:ListCollection;

    public static const triggersDict:Dictionary = new Dictionary();
    public static var triggersCollection:ListCollection;

    public static const EXTERNAL_SET_SIM_NAME_EVENT:String = "setSimName";
    public static const EXTERNAL_LOAD_FILE_EVENT:String = "loadFile";

    public static var externalEventDispatcher:IEventDispatcher;
    public static var currentFileName:String;

    public static var blendModesCollection:ListCollection;

    public static function init():void
    {
        blendModesCollection = new ListCollection([
            BlendMode.NORMAL,
            BlendMode.MULTIPLY,
            BlendMode.SCREEN,
            BlendMode.ADD,
            BlendMode.ERASE,
            BlendMode.BELOW
        ]);

        actionDict[Move]             = new DropdownListVO("Simulation speed",              Move,             MoveAction);
        actionDict[DeathZone]        = new DropdownListVO("Death zone",                    DeathZone,        DeathZoneAction);
        actionDict[RandomDrift]      = new DropdownListVO("Random acceleration",           RandomDrift,      RandomDriftAction);
        actionDict[Oriented]         = new DropdownListVO("Orient to velocity",            Oriented,         OrientedAction);
        actionDict[Age]              = new DropdownListVO("Change age",                    Age,              AgeAction);
        actionDict[DeathLife]        = new DropdownListVO("Death on life end",             DeathLife,        DeathLifeAction);
        actionDict[ScaleCurve]       = new DropdownListVO("Change scale",                  ScaleCurve,       ScaleCurveAction);
        actionDict[Accelerate]       = new DropdownListVO("Accelerate",                    Accelerate,       AccelerateAction);
        actionDict[SpeedLimit]       = new DropdownListVO("Speed limit",                   SpeedLimit,       SpeedLimitAction);
        actionDict[Spin]             = new DropdownListVO("Rotate",                        Spin,             SpinAction);
        actionDict[FollowWaypoints]  = new DropdownListVO("Follow waypoints",              FollowWaypoints,  FollowWaypointsAction);
        actionDict[Deflect]          = new DropdownListVO("Deflect/bounce",                Deflect,          DeflectAction);
        actionDict[Gravity]          = new DropdownListVO("Gravity (acceleration) field",  Gravity,          GravityAction);
        actionDict[VelocityField]    = new DropdownListVO("Velocity field",                VelocityField,    VelocityFieldAction);
        actionDict[NormalDrift]      = new DropdownListVO("Perpendicular acceleration",    NormalDrift,      NormalDriftAction);
        actionDict[AccelerationZone] = new DropdownListVO("Acceleration zone",             AccelerationZone, AccelerationZoneAction);
        actionDict[ColorGradient]    = new DropdownListVO("Color/Alpha curve",             ColorGradient,    ColorCurveAdvancedAction);
        actionDict[Spawn]            = new DropdownListVO("Spawn particles",               Spawn,            SpawnAction);
        actionDict[AlphaCurve]       = new DropdownListVO("Change alpha(deprecated)",      AlphaCurve,       AlphaCurveAction);
        actionDict[Damping]          = new DropdownListVO("Damping",                       Damping,          DampingAction);
        actionDict[ScaleAnimated]    = new DropdownListVO("Change Scale2",                 ScaleAnimated,    ScaleAnimatedAction);

        zonesDict[Line]        = new DropdownListVO("Line",             Line,      LineZone);
        zonesDict[SinglePoint] = new DropdownListVO("Point",            SinglePoint, SinglePointZone);
        zonesDict[RectZone]    = new DropdownListVO("Rectangle",        RectZone,  RectZoneRenderer);
        zonesDict[RectContour] = new DropdownListVO("Rectangle contour",RectContour, RectContourZone);
        zonesDict[CircleZone]  = new DropdownListVO("Circle",           CircleZone, CircleZoneRenderer);
        zonesDict[CircleContour] = new DropdownListVO("Circle contour", CircleContour, CircleContourZone);
        zonesDict[Sector]      = new DropdownListVO("Circle sector",    Sector,    SectorZone);

        triggersDict[DeathTrigger] = new DropdownListVO("Death trigger", DeathTrigger, DeathTriggerRenderer);
        triggersDict[LifeTrigger]  = new DropdownListVO("Life trigger",  LifeTrigger,  LifeTriggerRenderer);

        // Build sorted arrays for collections
        var actArr:Array = [];
        for each (var ddl:DropdownListVO in actionDict) actArr.push(ddl);
        actArr.sort(function(a:DropdownListVO, b:DropdownListVO):int { return a.name.localeCompare(b.name); });
        actionsCollection = new ListCollection(actArr);

        var zArr:Array = [];
        for each (var zdl:DropdownListVO in zonesDict) zArr.push(zdl);
        zArr.sort(function(a:DropdownListVO, b:DropdownListVO):int { return a.name.localeCompare(b.name); });
        zonesCollection = new ListCollection(zArr);

        noZeroAreaZonesCollection = new ListCollection([
            zonesDict[RectZone],
            zonesDict[CircleZone],
            zonesDict[Sector]
        ]);

        var tArr:Array = [];
        for each (var tdl:DropdownListVO in triggersDict) tArr.push(tdl);
        tArr.sort(function(a:DropdownListVO, b:DropdownListVO):int { return a.name.localeCompare(b.name); });
        triggersCollection = new ListCollection(tArr);

        starlingCanvas.touchable = false;
    }

    public static function dispatchExternalTitleChangeEvent(newTitle:String):void
    {
        currentFileName = newTitle;
        if (externalEventDispatcher)
            externalEventDispatcher.dispatchEvent(new TextEvent(EXTERNAL_SET_SIM_NAME_EVENT, true, false, newTitle));
    }

    public static function dispatchExternalLoadSimEvent():void
    {
        if (externalEventDispatcher)
            externalEventDispatcher.dispatchEvent(new Event(EXTERNAL_LOAD_FILE_EVENT, true));
    }
}
}
