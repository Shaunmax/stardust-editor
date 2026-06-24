package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.controller.events.EmitterImportedEvent;
import com.funkypandagame.stardust.controller.events.ImportSimEvent;
import com.funkypandagame.stardust.view.importSim.ImportedEmitter;
import com.funkypandagame.stardustplayer.ISimLoader;
import com.funkypandagame.stardustplayer.SDEConstants;
import com.funkypandagame.stardustplayer.emitter.EmitterValueObject;
import com.funkypandagame.stardustplayer.project.ProjectValueObject;
import com.funkypandagame.stardustplayer.sequenceLoader.LoadByteArrayJob;
import com.funkypandagame.stardustplayer.sequenceLoader.SequenceLoader;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.utils.ByteArray;

import org.as3commons.zip.Zip;

import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

public class ImportEmitterCommand
{
    private var _bus:EventDispatcher;
    private var _simLoader:ISimLoader;
    private var _event:ImportSimEvent;
    private var _fileRef:FileReference;
    private var _rawBytes:ByteArray;
    private var _loadedZip:Zip;
    private var _sequenceLoader:SequenceLoader;
    private var _project:ProjectValueObject;

    public function ImportEmitterCommand(bus:EventDispatcher, simLoader:ISimLoader, event:ImportSimEvent)
    {
        _bus = bus;
        _simLoader = simLoader;
        _event = event;
    }

    public function execute():void
    {
        _fileRef = new FileReference();
        _fileRef.browse([new FileFilter("SDE files", "*.sde")]);
        _fileRef.addEventListener(Event.SELECT, onSelect);
    }

    private function onSelect(e:Event):void
    {
        _fileRef.removeEventListener(Event.SELECT, onSelect);
        _fileRef.addEventListener(Event.COMPLETE, onComplete);
        _fileRef.load();
    }

    private function onComplete(e:Event):void
    {
        _fileRef.removeEventListener(Event.COMPLETE, onComplete);
        _rawBytes = _fileRef.data;
        _simLoader.addEventListener(Event.COMPLETE, onSimLoaded);
        _simLoader.loadSim(_rawBytes);
    }

    private function onSimLoaded(e:Event):void
    {
        _simLoader.removeEventListener(Event.COMPLETE, onSimLoaded);
        _project = _simLoader.createProjectInstance();

        _loadedZip = new Zip();
        _loadedZip.loadBytes(_rawBytes);

        for (var i:int = 0; i < _loadedZip.getFileCount(); i++)
        {
            var fileName:String = _loadedZip.getFileAt(i).filename;
            if (fileName == SDEConstants.ATLAS_IMAGE_NAME)
            {
                var atlasJob:LoadByteArrayJob = new LoadByteArrayJob(fileName, fileName, _loadedZip.getFileAt(i).content);
                _sequenceLoader = new SequenceLoader();
                _sequenceLoader.addJob(atlasJob);
                _sequenceLoader.addEventListener(Event.COMPLETE, onAtlasLoaded);
                _sequenceLoader.loadSequence();
                return;
            }
        }
        // no atlas found — dispatch with placeholders
        dispatchEmitters(null, null);
    }

    private function onAtlasLoaded(e:Event):void
    {
        _sequenceLoader.removeEventListener(Event.COMPLETE, onAtlasLoaded);
        var job:LoadByteArrayJob = _sequenceLoader.getCompletedJobs().pop();
        var atlasXMLBA:ByteArray = _loadedZip.getFileByName(SDEConstants.ATLAS_XML_NAME).content;
        var atlasXml:XML = new XML(atlasXMLBA.readUTFBytes(atlasXMLBA.length));
        var atlasBD:BitmapData = Bitmap(job.content).bitmapData;
        dispatchEmitters(atlasBD, atlasXml);
    }

    private function dispatchEmitters(atlasBD:BitmapData, atlasXml:XML):void
    {
        var tmpAtlas:TextureAtlas = (atlasBD && atlasXml)
                ? new TextureAtlas(Texture.empty(1, 1, false, false), atlasXml)
                : null;

        var emitters:Vector.<ImportedEmitter> = new Vector.<ImportedEmitter>();
        for each (var emitterVO:EmitterValueObject in _project.emitters)
        {
            var images:Vector.<BitmapData> = new Vector.<BitmapData>();
            if (tmpAtlas && atlasBD)
            {
                var textures:Vector.<Texture> = tmpAtlas.getTextures(SDEConstants.getSubTexturePrefix(emitterVO.id));
                for (var k:int = 0; k < textures.length; k++)
                {
                    var tex:SubTexture = textures[k] as SubTexture;
                    var frame:BitmapData = new BitmapData(tex.width, tex.height, true, 0);
                    frame.copyPixels(atlasBD, tex.region, new Point(0, 0));
                    images.push(frame);
                }
            }
            if (images.length == 0)
                images.push(new BitmapData(10, 10, false, 0xFFFFFF));
            emitters.push(new ImportedEmitter(emitterVO, images));
        }

        if (tmpAtlas) tmpAtlas.dispose();
        _sequenceLoader.clearAllJobs();
        _bus.dispatchEvent(new EmitterImportedEvent(emitters));
    }
}
}
