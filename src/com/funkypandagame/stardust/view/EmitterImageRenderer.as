package com.funkypandagame.stardust.view
{

import feathers.controls.ImageLoader;
import feathers.controls.renderers.LayoutGroupListItemRenderer;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import flash.display.BitmapData;

import starling.textures.Texture;

public class EmitterImageRenderer extends LayoutGroupListItemRenderer
{
    private var _image:ImageLoader;
    private var _texture:Texture;

    override protected function initialize():void
    {
        super.initialize();
        width = 35; height = 35;
        layout = new AnchorLayout();

        _image = new ImageLoader();
        _image.layoutData = new AnchorLayoutData(0, 0, 0, 0);
        _image.maintainAspectRatio = true;
        addChild(_image);
    }

    override protected function commitData():void
    {
        super.commitData();
        if (_texture) { _texture.dispose(); _texture = null; }
        if (_data is BitmapData)
        {
            _texture = Texture.fromBitmapData(BitmapData(_data));
            _image.source = _texture;
        }
        else
        {
            _image.source = null;
        }
    }
}
}
