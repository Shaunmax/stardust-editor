package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.helpers.DropdownListVO;
import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;
import com.funkypandagame.stardust.view.stardust.twoD.actions.deflectors.CircleDeflectorRenderer;
import com.funkypandagame.stardust.view.stardust.twoD.actions.deflectors.DeflectorRendererBase;
import com.funkypandagame.stardust.view.stardust.twoD.actions.deflectors.LineDeflectorRenderer;
import com.funkypandagame.stardust.view.stardust.twoD.actions.deflectors.WrappingBoxRenderer;

import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.controls.PickerList;
import feathers.data.ListCollection;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import idv.cjcat.stardustextended.actions.Deflect;
import idv.cjcat.stardustextended.deflectors.CircleDeflector;
import idv.cjcat.stardustextended.deflectors.Deflector;
import idv.cjcat.stardustextended.deflectors.LineDeflector;
import idv.cjcat.stardustextended.deflectors.WrappingBox;

import starling.events.Event;

public class DeflectAction extends PropertyRendererBase
{
    private static const _DEFLECTOR_DICT:Dictionary = new Dictionary();
    private static var _deflectorDDL:ListCollection;

    private var _dropdown:PickerList;
    private var _renderersGroup:LayoutGroup;
    private var _renderers:Vector.<DeflectorRendererBase> = new <DeflectorRendererBase>[];

    private static function _initDict():void
    {
        if (_deflectorDDL) return;
        _DEFLECTOR_DICT[CircleDeflector] = new DropdownListVO("Circle", CircleDeflector, CircleDeflectorRenderer);
        _DEFLECTOR_DICT[WrappingBox] = new DropdownListVO("Wrapping box", WrappingBox, WrappingBoxRenderer);
        _DEFLECTOR_DICT[LineDeflector] = new DropdownListVO("Line", LineDeflector, LineDeflectorRenderer);
        _deflectorDDL = new ListCollection();
        for (var key:Object in _DEFLECTOR_DICT)
            _deflectorDDL.addItem(_DEFLECTOR_DICT[key]);
    }

    override protected function initialize():void
    {
        nameText = "Deflect";
        _initDict();
        super.initialize();
    }

    override protected function createContent():void
    {
        var vLayout:VerticalLayout = new VerticalLayout();
        vLayout.gap = 4;
        contentContainer.layout = vLayout;

        var topRow:LayoutGroup = new LayoutGroup();
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 6;
        topRow.layout = hLayout;
        contentContainer.addChild(topRow);

        _dropdown = new PickerList();
        _dropdown.dataProvider = _deflectorDDL;
        _dropdown.labelField = "name";
        _dropdown.selectedIndex = 0;
        _dropdown.width = 160;
        topRow.addChild(_dropdown);

        var addBtn:Button = new Button();
        addBtn.label = "Add deflector";
        addBtn.addEventListener(Event.TRIGGERED, _onAdd);
        topRow.addChild(addBtn);

        _renderersGroup = new LayoutGroup();
        var rvLayout:VerticalLayout = new VerticalLayout();
        rvLayout.gap = 3;
        _renderersGroup.layout = rvLayout;
        contentContainer.addChild(_renderersGroup);
    }

    override protected function commitData():void
    {
        super.commitData();
        if (!_data || !_renderersGroup) return;
        _clearRenderers();
        var d:Deflect = Deflect(_data);
        for (var i:int = 0; i < d.deflectors.length; i++)
            _addDeflectorRenderer(d.deflectors[i]);
    }

    private function _addDeflectorRenderer(deflector:Deflector):void
    {
        var vo:DropdownListVO = _DEFLECTOR_DICT[Class(getDefinitionByName(getQualifiedClassName(deflector)))];
        if (!vo) return;
        var RendererClass:Class = vo.viewClass;
        var renderer:DeflectorRendererBase = new RendererClass();
        renderer.onRemove = _onRemoveDeflector;
        _renderersGroup.addChild(renderer);
        renderer.setData(deflector);
        _renderers.push(renderer);
    }

    private function _clearRenderers():void
    {
        for (var i:int = 0; i < _renderers.length; i++)
            _renderersGroup.removeChild(_renderers[i]);
        _renderers.length = 0;
    }

    private function _onAdd(e:Event):void
    {
        if (!_data) return;
        var vo:DropdownListVO = DropdownListVO(_dropdown.selectedItem);
        var DeflectorClass:Class = vo.stardustClass;
        var deflector:Deflector = new DeflectorClass();
        Deflect(_data).addDeflector(deflector);
        _addDeflectorRenderer(deflector);
    }

    private function _onRemoveDeflector(renderer:DeflectorRendererBase):void
    {
        var idx:int = _renderers.indexOf(renderer);
        if (idx < 0) return;
        var deflector:Deflector = renderer.data as Deflector;
        if (_data && deflector) Deflect(_data).removeDeflector(deflector);
        _renderersGroup.removeChild(renderer);
        _renderers.splice(idx, 1);
    }
}
}
