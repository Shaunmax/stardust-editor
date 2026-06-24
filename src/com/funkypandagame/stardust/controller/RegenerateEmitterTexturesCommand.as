package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardust.textures.Atlas;
import com.funkypandagame.stardust.textures.AtlasTexture;
import com.funkypandagame.stardust.textures.TexturePacker;
import com.funkypandagame.stardustplayer.SDEConstants;
import com.funkypandagame.stardustplayer.emitter.EmitterValueObject;

import feathers.controls.Alert;

import flash.display.BitmapData;

import idv.cjcat.stardustextended.handlers.starling.StarlingHandler;

import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

public class RegenerateEmitterTexturesCommand
{
    private var _projectModel:ProjectModel;

    public function RegenerateEmitterTexturesCommand(model:ProjectModel)
    {
        _projectModel = model;
    }

    public function execute():void
    {
        var packer:TexturePacker = new TexturePacker();
        var tmpTextures:Vector.<AtlasTexture> = new Vector.<AtlasTexture>();
        for (var emitterId:* in _projectModel.emitterImages)
        {
            var images:Vector.<BitmapData> = _projectModel.emitterImages[emitterId];
            for (var i:int = 0; i < images.length; i++)
                tmpTextures.push(new AtlasTexture(images[i], emitterId, i));
        }
        var atlas:Atlas = packer.createAtlas(tmpTextures);
        if (!atlas)
        {
            Alert.show("Failed to add images. Could not fit all images into a 2048x2048 texture atlas.");
            return;
        }
        var atlasTex:Texture = Texture.fromBitmapData(atlas.toBitmap(), false);
        var tmpAtlas:TextureAtlas = new TextureAtlas(atlasTex, atlas.getXML());
        for each (var emitterVO:EmitterValueObject in _projectModel.stadustSim.emitters)
        {
            var texs:Vector.<Texture> = tmpAtlas.getTextures(SDEConstants.getSubTexturePrefix(emitterVO.id));
            var texs2:Vector.<SubTexture> = new Vector.<SubTexture>();
            for (var k:int = 0; k < texs.length; k++)
                texs2.push(texs[k] as SubTexture);
            if (texs2.length == 0) continue;
            StarlingHandler(emitterVO.emitter.particleHandler).setTextures(texs2);
        }
    }
}
}
