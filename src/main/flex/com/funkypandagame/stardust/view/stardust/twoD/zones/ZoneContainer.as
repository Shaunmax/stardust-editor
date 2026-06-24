package com.funkypandagame.stardust.view.stardust.twoD.zones
{

import com.funkypandagame.stardust.helpers.DropdownListVO;
import com.funkypandagame.stardust.helpers.Globals;

import feathers.controls.Button;
import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.PickerList;
import feathers.data.ListCollection;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import flash.geom.Point;

import idv.cjcat.stardustextended.actions.IZoneContainer;
import idv.cjcat.stardustextended.zones.Zone;

import starling.core.Starling;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class ZoneContainer extends LayoutGroup
{
    private var _zonesDropdown:PickerList;
    private var _followMouseCheck:Check;
    private var _renderersGroup:LayoutGroup;

    private var _itemWithZone:IZoneContainer;
    private var _renderers:Vector.<ZoneRendererBase> = new Vector.<ZoneRendererBase>();
    private var _storedPositions:Vector.<Point> = new Vector.<Point>();
    private var _zeroAreaZonesVisible:Boolean = true;

    public function ZoneContainer()
    {
        super();
    }

    public function set zeroAreaZonesVisible(val:Boolean):void
    {
        _zeroAreaZonesVisible = val;
    }

    override protected function initialize():void
    {
        super.initialize();

        var vLayout:VerticalLayout = new VerticalLayout();
        vLayout.gap = 3;
        this.layout = vLayout;

        // Header row
        var headerGroup:LayoutGroup = new LayoutGroup();
        var headerLayout:HorizontalLayout = new HorizontalLayout();
        headerLayout.verticalAlign = VerticalAlign.MIDDLE;
        headerLayout.gap = 4;
        headerGroup.layout = headerLayout;
        addChild(headerGroup);

        var addLabel:Label = new Label();
        addLabel.text = "Add new zone:";
        headerGroup.addChild(addLabel);

        _zonesDropdown = new PickerList();
        _zonesDropdown.labelField = "name";
        _zonesDropdown.width = 140;
        headerGroup.addChild(_zonesDropdown);

        var addBtn:Button = new Button();
        addBtn.label = "Add zone";
        addBtn.addEventListener(Event.TRIGGERED, _onAddZone);
        headerGroup.addChild(addBtn);

        _followMouseCheck = new Check();
        _followMouseCheck.label = "Follow mouse";
        _followMouseCheck.addEventListener(Event.CHANGE, _onFollowMouseChange);
        headerGroup.addChild(_followMouseCheck);

        // Renderers group
        _renderersGroup = new LayoutGroup();
        var rLayout:VerticalLayout = new VerticalLayout();
        rLayout.gap = 3;
        _renderersGroup.layout = rLayout;
        _renderersGroup.layoutData = new HorizontalLayoutData(100);
        addChild(_renderersGroup);

        _updateZonesDropdown();
    }

    private function _updateZonesDropdown():void
    {
        var coll:ListCollection = _zeroAreaZonesVisible ? Globals.zonesCollection : Globals.noZeroAreaZonesCollection;
        _zonesDropdown.dataProvider = coll;
        _zonesDropdown.selectedIndex = 0;
    }

    public function setData(itemWithZone:IZoneContainer):void
    {
        _stopFollowMouse();
        _itemWithZone = itemWithZone;
        _clearRenderers();
        for (var i:int = 0; i < itemWithZone.zones.length; i++)
            _addZoneRenderer(itemWithZone.zones[i]);
        _updateRemoveButtons();
    }

    private function _onAddZone(e:Event):void
    {
        if (_zonesDropdown.selectedItem == null) return;
        var cl:Class = DropdownListVO(_zonesDropdown.selectedItem).stardustClass;
        var zone:Zone = new cl();
        _itemWithZone.zones.push(zone);
        _addZoneRenderer(zone);
        _updateRemoveButtons();
    }

    private function _addZoneRenderer(zone:Zone):void
    {
        var ddl:DropdownListVO = Globals.zonesDict[Object(zone).constructor];
        if (!ddl) return;
        var RendererClass:Class = ddl.viewClass;
        var renderer:ZoneRendererBase = new RendererClass();
        renderer.onRemove = _onRemoveZone;
        renderer.getCollectionLength = function():int { return _renderers.length; };
        renderer.data = zone;
        _renderersGroup.addChild(renderer);
        _renderers.push(renderer);
    }

    private function _onRemoveZone(renderer:ZoneRendererBase):void
    {
        if (_renderers.length <= 1) return;
        var idx:int = _renderers.indexOf(renderer);
        if (idx < 0) return;
        _renderers.splice(idx, 1);
        _renderersGroup.removeChild(renderer, true);
        _rebuildZoneList();
        _updateRemoveButtons();
    }

    private function _rebuildZoneList():void
    {
        var newZones:Vector.<Zone> = new Vector.<Zone>();
        for (var i:int = 0; i < _renderers.length; i++)
            newZones.push(Zone(_renderers[i].data));
        _itemWithZone.zones = newZones;
    }

    private function _clearRenderers():void
    {
        for (var i:int = 0; i < _renderers.length; i++)
            _renderersGroup.removeChild(_renderers[i], true);
        _renderers.length = 0;
    }

    private function _updateRemoveButtons():void
    {
        for (var i:int = 0; i < _renderers.length; i++)
            _renderers[i].invalidate(INVALIDATION_FLAG_SIZE);
    }

    private function _onFollowMouseChange(e:Event):void
    {
        if (_followMouseCheck.isSelected)
        {
            _storedPositions = new Vector.<Point>();
            for (var i:int = 0; i < _renderers.length; i++)
            {
                var z:Zone = Zone(_renderers[i].data);
                _storedPositions.push(z.getPosition());
            }
            stage.addEventListener(TouchEvent.TOUCH, _onTouch);
            addEventListener(Event.ENTER_FRAME, _onEnterFrame);
        }
        else
        {
            _stopFollowMouse();
        }
    }

    private function _stopFollowMouse():void
    {
        if (_followMouseCheck && _followMouseCheck.isSelected)
        {
            _followMouseCheck.isSelected = false;
            _setZoneOffset(0, 0);
        }
        removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
        if (stage) stage.removeEventListener(TouchEvent.TOUCH, _onTouch);
    }

    private function _onTouch(e:TouchEvent):void
    {
        var touch:Touch = e.getTouch(stage, TouchPhase.BEGAN);
        if (touch && _followMouseCheck.isSelected)
        {
            _followMouseCheck.isSelected = false;
            _stopFollowMouse();
        }
    }

    private function _onEnterFrame(e:Event):void
    {
        var nativeStage:flash.display.Stage = Starling.current.nativeStage;
        _setZoneOffset(nativeStage.mouseX - Globals.starlingCanvas.x,
                       nativeStage.mouseY - Globals.starlingCanvas.y);
    }

    private function _setZoneOffset(xc:Number, yc:Number):void
    {
        if (_storedPositions.length == 0) return;
        for (var i:int = 0; i < _renderers.length; i++)
        {
            var z:Zone = Zone(_renderers[i].data);
            z.setPosition(_storedPositions[i].x + xc, _storedPositions[i].y + yc);
        }
    }
}
}
