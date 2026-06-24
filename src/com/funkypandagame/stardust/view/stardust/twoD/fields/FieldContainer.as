package com.funkypandagame.stardust.view.stardust.twoD.fields
{

import com.funkypandagame.stardust.helpers.DropdownListVO;

import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.controls.PickerList;
import feathers.data.ListCollection;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import idv.cjcat.stardustextended.fields.BitmapField;
import idv.cjcat.stardustextended.fields.Field;
import idv.cjcat.stardustextended.fields.RadialField;
import idv.cjcat.stardustextended.fields.UniformField;

import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import starling.events.Event;

public class FieldContainer extends LayoutGroup
{
    private static const _FIELD_DICT:Object = {};
    private static var _FIELD_COLLECTION:ListCollection;

    private var _fieldDropdown:PickerList;
    private var _addBtn:Button;
    private var _renderersGroup:LayoutGroup;
    private var _renderers:Vector.<FieldRendererBase> = new Vector.<FieldRendererBase>();
    private var _hasOnlyOneField:Boolean = false;

    public function FieldContainer()
    {
        super();
        if (!_FIELD_COLLECTION)
        {
            _FIELD_DICT[UniformField] = new DropdownListVO("Uniform", UniformField, UniformFieldRenderer);
            _FIELD_DICT[RadialField]  = new DropdownListVO("Radial",  RadialField,  RadialFieldRenderer);
            _FIELD_DICT[BitmapField]  = new DropdownListVO("Bitmap",  BitmapField,  BitmapFieldRenderer);
            _FIELD_COLLECTION = new ListCollection([
                _FIELD_DICT[UniformField],
                _FIELD_DICT[RadialField],
                _FIELD_DICT[BitmapField]
            ]);
        }
    }

    public function set hasOnlyOneField(val:Boolean):void
    {
        _hasOnlyOneField = val;
        if (val && _renderers.length > 1)
        {
            var keep:FieldRendererBase = _renderers[0];
            _clearRenderers();
            _addRenderer(Field(keep.data));
        }
        if (_addBtn) _addBtn.isEnabled = !val || _renderers.length == 0;
    }

    override protected function initialize():void
    {
        super.initialize();

        var vLayout:VerticalLayout = new VerticalLayout();
        vLayout.gap = 3;
        this.layout = vLayout;

        var headerGroup:LayoutGroup = new LayoutGroup();
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 4;
        headerGroup.layout = hLayout;
        headerGroup.layoutData = new HorizontalLayoutData(100);
        addChild(headerGroup);

        _fieldDropdown = new PickerList();
        _fieldDropdown.dataProvider = _FIELD_COLLECTION;
        _fieldDropdown.labelField = "name";
        _fieldDropdown.selectedIndex = 0;
        _fieldDropdown.width = 140;
        headerGroup.addChild(_fieldDropdown);

        _addBtn = new Button();
        _addBtn.label = "Add field";
        _addBtn.addEventListener(Event.TRIGGERED, _onAddField);
        headerGroup.addChild(_addBtn);

        _renderersGroup = new LayoutGroup();
        var rLayout:VerticalLayout = new VerticalLayout();
        rLayout.gap = 3;
        _renderersGroup.layout = rLayout;
        _renderersGroup.layoutData = new HorizontalLayoutData(100);
        addChild(_renderersGroup);
    }

    public function setData(fields:Vector.<Field>):void
    {
        _clearRenderers();
        for (var i:int = 0; i < fields.length; i++)
            _addRenderer(fields[i]);
        if (_addBtn) _addBtn.isEnabled = !_hasOnlyOneField || _renderers.length == 0;
    }

    public function getData():Vector.<Field>
    {
        var result:Vector.<Field> = new Vector.<Field>();
        for (var i:int = 0; i < _renderers.length; i++)
            result.push(Field(_renderers[i].data));
        return result;
    }

    private function _onAddField(e:Event):void
    {
        if (!_fieldDropdown.selectedItem) return;
        if (_hasOnlyOneField && _renderers.length > 0) return;
        var cl:Class = DropdownListVO(_fieldDropdown.selectedItem).stardustClass;
        _addRenderer(new cl());
        if (_addBtn) _addBtn.isEnabled = !_hasOnlyOneField || _renderers.length == 0;
        dispatchEventWith(Event.CHANGE);
    }

    private function _addRenderer(field:Field):void
    {
        var ddl:DropdownListVO = _FIELD_DICT[Class(getDefinitionByName(getQualifiedClassName(field)))];
        if (!ddl) return;
        var RendererClass:Class = ddl.viewClass;
        var renderer:FieldRendererBase = new RendererClass();
        renderer.onRemove = _onRemoveField;
        renderer.data = field;
        _renderersGroup.addChild(renderer);
        _renderers.push(renderer);
    }

    private function _onRemoveField(renderer:FieldRendererBase):void
    {
        var idx:int = _renderers.indexOf(renderer);
        if (idx < 0) return;
        _renderers.splice(idx, 1);
        _renderersGroup.removeChild(renderer, true);
        if (_addBtn) _addBtn.isEnabled = !_hasOnlyOneField || _renderers.length == 0;
        dispatchEventWith(Event.CHANGE);
    }

    private function _clearRenderers():void
    {
        for (var i:int = 0; i < _renderers.length; i++)
            _renderersGroup.removeChild(_renderers[i], true);
        _renderers.length = 0;
    }
}
}
