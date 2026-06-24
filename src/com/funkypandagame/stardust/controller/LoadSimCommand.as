package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.controller.events.LoadSimEvent;
import com.funkypandagame.stardust.controller.events.RefreshFPSTextEvent;
import com.funkypandagame.stardust.controller.events.RegenerateEmitterTexturesEvent;
import com.funkypandagame.stardust.controller.events.StartSimEvent;
import com.funkypandagame.stardust.helpers.Globals;
import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardust.view.events.RefreshBackgroundViewEvent;
import com.funkypandagame.stardustplayer.ISimLoader;
import com.funkypandagame.stardustplayer.SimLoader;
import com.funkypandagame.stardustplayer.SimPlayer;
import com.funkypandagame.stardustplayer.SDEConstants;
import com.funkypandagame.stardustplayer.emitter.EmitterValueObject;
import com.funkypandagame.stardustplayer.sequenceLoader.LoadByteArrayJob;
import com.funkypandagame.stardustplayer.sequenceLoader.SequenceLoader;

import feathers.controls.Alert;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.initializers.Alpha;
import idv.cjcat.stardustextended.initializers.Initializer;
import idv.cjcat.stardustextended.initializers.Life;
import idv.cjcat.stardustextended.initializers.Mass;
import idv.cjcat.stardustextended.initializers.Scale;
import idv.cjcat.stardustextended.initializers.Omega;
import idv.cjcat.stardustextended.initializers.PositionAnimated;
import idv.cjcat.stardustextended.initializers.Rotation;
import idv.cjcat.stardustextended.initializers.Velocity;

import org.as3commons.zip.Zip;

public class LoadSimCommand
{
    private var _bus:EventDispatcher;
    private var _simLoader:ISimLoader;
    private var _projectModel:ProjectModel;
    private var _event:LoadSimEvent;
    private var _simPlayer:SimPlayer;
    private var _numLoaded:uint;
    private var _sequenceLoader:SequenceLoader;
    private var _loadedZip:Zip;

    public function LoadSimCommand(bus:EventDispatcher, simLoader:ISimLoader, projectModel:ProjectModel,
                                   simPlayer:SimPlayer, event:LoadSimEvent)
    {
        _bus = bus;
        _simLoader = simLoader;
        _projectModel = projectModel;
        _simPlayer = simPlayer;
        _event = event;
    }

    public function execute():void
    {
        if (_projectModel.stadustSim)
        {
            _projectModel.stadustSim.destroy();
            _simLoader.dispose();
        }
        _numLoaded = 0;
        try
        {
            _simLoader.addEventListener(Event.COMPLETE, onSimLoadComplete);
            _simLoader.loadSim(_event.sdeFile);

            _loadedZip = new Zip();
            _loadedZip.loadBytes(_event.sdeFile);

            var descriptorJSON:Object = JSON.parse(_loadedZip.getFileByName(SimLoader.DESCRIPTOR_FILENAME).getContentAsString());
            _projectModel.hasBackground = (descriptorJSON.hasBackground == "true");
            _projectModel.backgroundColor = descriptorJSON.backgroundColor;

            if (_loadedZip.getFileByName(SimLoader.BACKGROUND_FILENAME) != null)
            {
                _projectModel.backgroundRawData = _loadedZip.getFileByName(SimLoader.BACKGROUND_FILENAME).content;
                var loader:Loader = new Loader();
                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBGLoadComplete);
                loader.loadBytes(_projectModel.backgroundRawData);
            }
            else
            {
                _numLoaded++;
            }
        }
        catch (err:Error)
        {
            Alert.show("Unable to load simulation.\n" + err.toString(), "ERROR");
        }
    }

    private function onBGLoadComplete(event:Event):void
    {
        var li:LoaderInfo = LoaderInfo(event.target);
        li.removeEventListener(Event.COMPLETE, onBGLoadComplete);
        _projectModel.backgroundImage = li.content;
        checkIfAllLoaded();
    }

    private function onSimLoadComplete(event:Event):void
    {
        _simLoader.removeEventListener(Event.COMPLETE, onSimLoadComplete);
        _projectModel.stadustSim = _simLoader.createProjectInstance();
        _projectModel.emitterImages = new Dictionary();

        var foundAtlas:Boolean = false;
        for (var i:int = 0; i < _loadedZip.getFileCount(); i++)
        {
            var loadedFileName:String = _loadedZip.getFileAt(i).filename;
            if (loadedFileName == SDEConstants.ATLAS_IMAGE_NAME)
            {
                foundAtlas = true;
                const loadAtlasJob:LoadByteArrayJob = new LoadByteArrayJob(loadedFileName, loadedFileName, _loadedZip.getFileAt(i).content);
                _sequenceLoader = new SequenceLoader();
                _sequenceLoader.addJob(loadAtlasJob);
                _sequenceLoader.addEventListener(Event.COMPLETE, onProjectAtlasLoaded);
                _sequenceLoader.loadSequence();
                break;
            }
        }
        if (!foundAtlas)
        {
            checkIfAllLoaded();
        }
    }

    private function onProjectAtlasLoaded(event:Event):void
    {
        _sequenceLoader.removeEventListener(Event.COMPLETE, onProjectAtlasLoaded);
        var job:LoadByteArrayJob = _sequenceLoader.getCompletedJobs().pop();
        var atlasXMLBA:ByteArray = _loadedZip.getFileByName(SDEConstants.ATLAS_XML_NAME).content;
        var atlasXml:XML = new XML(atlasXMLBA.readUTFBytes(atlasXMLBA.length));
        var atlasBD:BitmapData = Bitmap(job.content).bitmapData;

        // Parse pixel-accurate rects directly from the XML to avoid Starling HiDPI scaling issues
        var regionMap:Dictionary = new Dictionary();
        for each (var subTexXml:XML in atlasXml.SubTexture)
        {
            regionMap[String(subTexXml.@name)] = new Rectangle(
                int(subTexXml.@x), int(subTexXml.@y),
                int(subTexXml.@width), int(subTexXml.@height));
        }

        for each (var emitterVO:EmitterValueObject in _projectModel.stadustSim.emitters)
        {
            var emitterId:String = emitterVO.id;
            if (_projectModel.emitterImages[emitterId] == null)
                _projectModel.emitterImages[emitterId] = new Vector.<BitmapData>();
            var prefix:String = SDEConstants.getSubTexturePrefix(emitterId);
            var names:Array = [];
            for (var n:String in regionMap)
            {
                if (n.indexOf(prefix) == 0) names.push(n);
            }
            names.sort();
            for each (var frameName:String in names)
            {
                var rect:Rectangle = regionMap[frameName];
                var singleSprite:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
                singleSprite.copyPixels(atlasBD, rect, new Point(0, 0));
                _projectModel.emitterImages[emitterId].push(singleSprite);
            }
        }
        checkIfAllLoaded();
    }

    private function checkIfAllLoaded():void
    {
        _numLoaded++;
        if (_numLoaded == 2) onAllLoaded();
    }

    private function onAllLoaded():void
    {
        if (_sequenceLoader) _sequenceLoader.clearAllJobs();
        _projectModel.emitterInFocus = null;
        for each (var emitterVO:EmitterValueObject in _projectModel.stadustSim.emitters)
        {
            if (_projectModel.emitterInFocus == null) _projectModel.emitterInFocus = emitterVO;
            var em:Emitter = emitterVO.emitter;
            if (!hasInitializerType(em, PositionAnimated)) em.addInitializer(new PositionAnimated());
            if (!hasInitializerType(em, Life)) em.addInitializer(new Life());
            if (!hasInitializerType(em, Velocity)) em.addInitializer(new Velocity());
            if (!hasInitializerType(em, Alpha)) em.addInitializer(new Alpha());
            if (!hasInitializerType(em, Scale)) em.addInitializer(new Scale());
            if (!hasInitializerType(em, Rotation)) em.addInitializer(new Rotation());
            if (!hasInitializerType(em, Omega)) em.addInitializer(new Omega());
            if (!hasInitializerType(em, Mass)) em.addInitializer(new Mass());
        }

        _simPlayer.setRenderTarget(null);
        _simPlayer.setProject(_projectModel.stadustSim);
        _simPlayer.setRenderTarget(Globals.starlingCanvas);

        _bus.dispatchEvent(new RegenerateEmitterTexturesEvent());
        _bus.dispatchEvent(new RefreshBackgroundViewEvent());
        _bus.dispatchEvent(new RefreshFPSTextEvent());
        Globals.dispatchExternalTitleChangeEvent(_event.nameToDisplay);
        _bus.dispatchEvent(new StartSimEvent());
    }

    private static function hasInitializerType(em:Emitter, clazz:Class):Boolean
    {
        for each (var init:Initializer in em.initializers)
            if (init is clazz) return true;
        return false;
    }
}
}
