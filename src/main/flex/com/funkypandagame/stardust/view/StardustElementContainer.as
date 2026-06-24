package com.funkypandagame.stardust.view
{

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.List;
import feathers.controls.PickerList;
import feathers.controls.ScrollContainer;
import feathers.data.ListCollection;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import com.funkypandagame.stardust.helpers.DropdownListVO;
import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.actions.ColorGradient;
import idv.cjcat.stardustextended.actions.Spawn;

import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

import starling.events.Event;

public class StardustElementContainer extends LayoutGroup
{
    private var _headerLabel:Label;
    private var _ddl:PickerList;
    private var _addBtn:Button;
    private var _renderersGroup:LayoutGroup;
    private var _renderers:Vector.<PropertyRendererBase> = new <PropertyRendererBase>[];

    private var _labelText:String = "";
    private var _fullCollection:ListCollection;   // all possible items (DropdownListVO)
    private var _filteredCollection:ListCollection;
    private var _dict:Dictionary;
    private var _data:Vector.<StardustElement> = new <StardustElement>[];

    /** Called when an element is added: function(item:StardustElement):void */
    public var onElementAdded:Function;
    /** Called when an element is removed: function(item:StardustElement):void */
    public var onElementRemoved:Function;

    public function StardustElementContainer()
    {
        super();
        var v:VerticalLayout = new VerticalLayout();
        v.gap = 0;
        layout = v;
    }

    public function set label(s:String):void
    {
        _labelText = s;
        if (_headerLabel) _headerLabel.text = s;
    }

    public function set fullCollection(col:ListCollection):void
    {
        _fullCollection = col;
        _rebuildFilteredCollection();
    }

    public function set dataproviderDict(dict:Dictionary):void
    {
        _dict = dict;
    }

    override protected function initialize():void
    {
        super.initialize();

        var header:LayoutGroup = new LayoutGroup();
        var hh:HorizontalLayout = new HorizontalLayout();
        hh.verticalAlign = VerticalAlign.MIDDLE; hh.gap = 4; hh.paddingLeft = 3;
        header.layout = hh;
        addChild(header);

        _headerLabel = new Label(); _headerLabel.text = _labelText;
        header.addChild(_headerLabel);

        _filteredCollection = new ListCollection();
        _ddl = new PickerList();
        _ddl.dataProvider = _filteredCollection;
        _ddl.labelField = "name";
        _ddl.selectedIndex = 0;
        header.addChild(_ddl);

        var spacer:LayoutGroup = new LayoutGroup();
        spacer.layoutData = new HorizontalLayoutData(100);
        header.addChild(spacer);

        _addBtn = new Button(); _addBtn.label = "Add"; _addBtn.width = 60;
        _addBtn.addEventListener(Event.TRIGGERED, _onAdd);
        header.addChild(_addBtn);

        _renderersGroup = new LayoutGroup();
        var v:VerticalLayout = new VerticalLayout(); v.gap = 0;
        _renderersGroup.layout = v;
        _renderersGroup.layoutData = new HorizontalLayoutData(100);
        addChild(_renderersGroup);

        if (_fullCollection) _rebuildFilteredCollection();
    }

    public function setData(elements:Vector.<StardustElement>):void
    {
        _data = elements;
        _rebuildRenderers();
        _rebuildFilteredCollection();
    }

    public function getData():Vector.<StardustElement>
    {
        return _data;
    }

    private function _rebuildRenderers():void
    {
        if (!_renderersGroup) return;
        while (_renderersGroup.numChildren > 0)
            _renderersGroup.removeChildAt(0, true);
        _renderers = new <PropertyRendererBase>[];

        for (var i:int = 0; i < _data.length; i++)
        {
            _addRendererForItem(_data[i]);
        }
    }

    private function _addRendererForItem(item:StardustElement):void
    {
        if (!_dict) return;
        var ddlVO:DropdownListVO = DropdownListVO(_dict[item.constructor]);
        if (!ddlVO) return;

        var RendererClass:Class = ddlVO.viewClass;
        var renderer:PropertyRendererBase = new RendererClass();
        renderer.data = item;
        renderer.onRemove = _onRemoveRenderer;
        _renderers.push(renderer);
        _renderersGroup.addChild(renderer);
    }

    private function _onAdd(e:Event):void
    {
        if (!_ddl.selectedItem) return;
        var ddlVO:DropdownListVO = DropdownListVO(_ddl.selectedItem);
        var StardustClass:Class = ddlVO.stardustClass;
        var instance:StardustElement;
        if (StardustClass == ColorGradient)
            instance = new ColorGradient(true);
        else
            instance = new StardustClass();

        _data.push(instance);
        _addRendererForItem(instance);
        _rebuildFilteredCollection();
        if (onElementAdded != null) onElementAdded(instance);
        dispatchEvent(new Event(Event.CHANGE, true));
    }

    private function _onRemoveRenderer(renderer:PropertyRendererBase):void
    {
        var idx:int = _renderers.indexOf(renderer);
        if (idx < 0) return;
        var removed:StardustElement = _data[idx];
        _renderers.splice(idx, 1);
        _data.splice(idx, 1);
        _renderersGroup.removeChild(renderer, true);
        _rebuildFilteredCollection();
        if (onElementRemoved != null) onElementRemoved(removed);
        dispatchEvent(new Event(Event.CHANGE, true));
    }

    private function _rebuildFilteredCollection():void
    {
        if (!_filteredCollection || !_fullCollection) return;
        _filteredCollection.removeAll();
        for (var i:int = 0; i < _fullCollection.length; i++)
        {
            var ddlVO:DropdownListVO = DropdownListVO(_fullCollection.getItemAt(i));
            if (_filterFn(ddlVO))
                _filteredCollection.addItem(ddlVO);
        }
        if (_ddl && _filteredCollection.length > 0)
            _ddl.selectedIndex = 0;
        if (_addBtn)
            _addBtn.isEnabled = (_filteredCollection.length > 0);
    }

    private function _filterFn(ddlVO:DropdownListVO):Boolean
    {
        var cls:Class = ddlVO.stardustClass;
        if (cls == Spawn) return true;
        for each (var item:StardustElement in _data)
        {
            if (item is cls) return false;
        }
        return true;
    }
}
}
