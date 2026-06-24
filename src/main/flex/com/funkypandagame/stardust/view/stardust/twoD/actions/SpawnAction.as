package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.helpers.DropdownListVO;
import com.funkypandagame.stardust.helpers.Globals;
import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;
import com.funkypandagame.stardust.view.stardust.twoD.actions.triggers.ITriggerRenderer;

import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.PickerList;
import feathers.data.ListCollection;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import idv.cjcat.stardustextended.actions.Spawn;
import idv.cjcat.stardustextended.actions.triggers.Trigger;
import idv.cjcat.stardustextended.emitters.Emitter;

import starling.events.Event;

public class SpawnAction extends PropertyRendererBase
{
    private var _inheritVelocityCheck:Check;
    private var _inheritDirectionCheck:Check;
    private var _emitterPicker:PickerList;
    private var _triggerPicker:PickerList;
    private var _triggerContainer:LayoutGroup;
    private var _currentTriggerRenderer:ITriggerRenderer;
    private var _emitterCollection:ListCollection;
    private var _spawnData:Spawn;

    override protected function initialize():void
    {
        nameText = "Spawn";
        super.initialize();
    }

    override protected function createContent():void
    {
        var vLayout:VerticalLayout = new VerticalLayout();
        vLayout.gap = 4;
        contentContainer.layout = vLayout;

        var row1:LayoutGroup = _makeHRow();
        contentContainer.addChild(row1);
        _inheritVelocityCheck = new Check();
        _inheritVelocityCheck.label = "Inherit velocity";
        _inheritVelocityCheck.addEventListener(Event.CHANGE, _onCheckChange);
        row1.addChild(_inheritVelocityCheck);
        _inheritDirectionCheck = new Check();
        _inheritDirectionCheck.label = "Inherit direction";
        _inheritDirectionCheck.addEventListener(Event.CHANGE, _onCheckChange);
        row1.addChild(_inheritDirectionCheck);

        var row2:LayoutGroup = _makeHRow();
        contentContainer.addChild(row2);
        row2.addChild(_lbl("Emitter"));
        _emitterCollection = new ListCollection();
        _emitterPicker = new PickerList();
        _emitterPicker.dataProvider = _emitterCollection;
        _emitterPicker.labelField = "name";
        _emitterPicker.width = 160;
        _emitterPicker.addEventListener(Event.CHANGE, _onEmitterChange);
        row2.addChild(_emitterPicker);

        var row3:LayoutGroup = _makeHRow();
        contentContainer.addChild(row3);
        row3.addChild(_lbl("Trigger type:"));
        _triggerPicker = new PickerList();
        _triggerPicker.dataProvider = Globals.triggersCollection;
        _triggerPicker.labelField = "name";
        _triggerPicker.requireSelection = true;
        _triggerPicker.width = 160;
        _triggerPicker.addEventListener(Event.CHANGE, _onTriggerChange);
        row3.addChild(_triggerPicker);

        _triggerContainer = new LayoutGroup();
        _triggerContainer.layout = new HorizontalLayout();
        contentContainer.addChild(_triggerContainer);
    }

    private function _lbl(t:String):Label
    {
        var l:Label = new Label(); l.text = t; return l;
    }

    private function _makeHRow():LayoutGroup
    {
        var g:LayoutGroup = new LayoutGroup();
        var h:HorizontalLayout = new HorizontalLayout();
        h.verticalAlign = VerticalAlign.MIDDLE;
        h.gap = 6;
        g.layout = h;
        return g;
    }

    override protected function commitData():void
    {
        super.commitData();
        if (!_data || !_inheritVelocityCheck) return;
        _spawnData = Spawn(_data);

        _inheritVelocityCheck.isSelected = _spawnData.inheritVelocity;
        _inheritDirectionCheck.isSelected = _spawnData.inheritDirection;

        _buildEmitterList();

        var TriggerClass:Class = Class(getDefinitionByName(getQualifiedClassName(_spawnData.trigger)));
        var currentVO:DropdownListVO = Globals.triggersDict[TriggerClass];
        if (currentVO)
        {
            var trigIdx:int = Globals.triggersCollection.getItemIndex(currentVO);
            _triggerPicker.selectedIndex = trigIdx >= 0 ? trigIdx : 0;
        }
        _setTriggerRenderer(currentVO ? currentVO.viewClass : null, _spawnData.trigger);
    }

    private function _buildEmitterList():void
    {
        _emitterPicker.removeEventListener(Event.CHANGE, _onEmitterChange);
        _emitterCollection.removeAll();
        var model:* = Globals.projectModel;
        if (model && model.stadustSim)
        {
            var focusEmitter:* = model.emitterInFocus ? model.emitterInFocus.emitter : null;
            for each (var em:Emitter in model.stadustSim.emittersArr)
            {
                if (em !== focusEmitter)
                    _emitterCollection.addItem(em);
            }
        }
        if (_spawnData.spawnerEmitter)
        {
            var idx:int = _emitterCollection.getItemIndex(_spawnData.spawnerEmitter);
            if (idx >= 0) _emitterPicker.selectedIndex = idx;
        }
        _emitterPicker.addEventListener(Event.CHANGE, _onEmitterChange);
    }

    private function _setTriggerRenderer(RendererClass:Class, trigger:Trigger):void
    {
        _triggerContainer.removeChildren();
        _currentTriggerRenderer = null;
        if (!RendererClass) return;
        var renderer:ITriggerRenderer = new RendererClass();
        renderer.setData(trigger);
        _triggerContainer.addChild(renderer as feathers.core.FeathersControl);
        _currentTriggerRenderer = renderer;
    }

    private function _onCheckChange(e:Event):void
    {
        if (!_spawnData) return;
        _spawnData.inheritVelocity = _inheritVelocityCheck.isSelected;
        _spawnData.inheritDirection = _inheritDirectionCheck.isSelected;
    }

    private function _onEmitterChange(e:Event):void
    {
        if (!_spawnData) return;
        var em:Emitter = _emitterPicker.selectedItem as Emitter;
        if (_spawnData.spawnerEmitter)
            _spawnData.spawnerEmitter.active = true;
        _spawnData.spawnerEmitter = em;
        if (em) em.active = false;
    }

    private function _onTriggerChange(e:Event):void
    {
        if (!_spawnData) return;
        var vo:DropdownListVO = DropdownListVO(_triggerPicker.selectedItem);
        var trigger:Trigger = new vo.stardustClass();
        _spawnData.trigger = trigger;
        _setTriggerRenderer(vo.viewClass, trigger);
    }

    override protected function onRemoveButtonTriggered(e:Event):void
    {
        if (_spawnData && _spawnData.spawnerEmitter)
        {
            _spawnData.spawnerEmitter.active = true;
            _spawnData.spawnerEmitter = null;
        }
        super.onRemoveButtonTriggered(e);
    }
}
}
