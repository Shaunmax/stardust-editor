package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.helpers.Globals;
import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardust.textures.Atlas;
import com.funkypandagame.stardust.textures.AtlasTexture;
import com.funkypandagame.stardust.textures.TexturePacker;
import com.funkypandagame.stardustplayer.SimLoader;
import com.funkypandagame.stardustplayer.SDEConstants;
import com.funkypandagame.stardustplayer.emitter.EmitterValueObject;

import feathers.controls.Alert;

import flash.display.BitmapData;
import flash.display.PNGEncoderOptions;
import flash.events.IOErrorEvent;
import flash.geom.Rectangle;
import flash.net.FileReference;
import flash.utils.ByteArray;

import idv.cjcat.stardustextended.xml.XMLBuilder;

import org.as3commons.zip.Zip;

public class SaveSimCommand
{
    private var _projectModel:ProjectModel;

    public function SaveSimCommand(model:ProjectModel)
    {
        _projectModel = model;
    }

    public function execute():void
    {
        const saveFile:FileReference = new FileReference();
        saveFile.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        saveFile.save(constructProjectFileByteArray(), Globals.currentFileName + ".sde");
    }

    private static function ioErrorHandler(e:IOErrorEvent):void
    {
        Alert.show("Error saving the file, details:\n" + e.toString(), "ERROR");
    }

    private function constructProjectFileByteArray():ByteArray
    {
        const zip:Zip = new Zip();
        const descObj:Object = {};
        descObj.version = "2.1";

        createEmitterAtlas(zip);
        addEmittersToProjectFile(zip);
        addBackgroundToProjectFile(zip, descObj);

        zip.addFileFromString(SimLoader.DESCRIPTOR_FILENAME, JSON.stringify(descObj));
        const zippedData:ByteArray = new ByteArray();
        zip.serialize(zippedData, false);
        return zippedData;
    }

    private function createEmitterAtlas(zip:Zip):void
    {
        var packer:TexturePacker = new TexturePacker();
        var textures:Vector.<AtlasTexture> = new Vector.<AtlasTexture>();
        for (var emitterId:* in _projectModel.emitterImages)
        {
            var images:Vector.<BitmapData> = _projectModel.emitterImages[emitterId];
            for (var i:int = 0; i < images.length; i++)
                textures.push(new AtlasTexture(images[i], emitterId, i));
        }
        var atlas:Atlas = packer.createAtlas(textures);
        if (atlas)
        {
            var bd:BitmapData = atlas.toBitmap();
            var bytes:ByteArray = new ByteArray();
            bd.encode(new Rectangle(0, 0, bd.width, bd.height), new PNGEncoderOptions(), bytes);
            zip.addFile(SDEConstants.ATLAS_IMAGE_NAME, bytes);
            zip.addFileFromString(SDEConstants.ATLAS_XML_NAME, '<?xml version="1.0" encoding="UTF-8"?>\n' + atlas.getXML().toString());
        }
        else
        {
            Alert.show("Failed to add images. Could not fit all images into a 2048x2048 texture atlas.");
        }
    }

    private function addEmittersToProjectFile(zip:Zip):void
    {
        for each (var emitterVO:EmitterValueObject in _projectModel.stadustSim.emitters)
        {
            if (emitterVO.emitterSnapshot)
                zip.addFile(SDEConstants.getParticleSnapshotName(emitterVO.id), emitterVO.emitterSnapshot, false);
            zip.addFileFromString(SDEConstants.getXMLName(emitterVO.id), XMLBuilder.buildXML(emitterVO.emitter).toString());
        }
    }

    private function addBackgroundToProjectFile(zip:Zip, descObj:Object):void
    {
        if (_projectModel.backgroundImage != null)
            zip.addFile(SimLoader.BACKGROUND_FILENAME, _projectModel.backgroundRawData);
        descObj.hasBackground = _projectModel.hasBackground ? "true" : "false";
        descObj.backgroundColor = _projectModel.backgroundColor;
    }
}
}
