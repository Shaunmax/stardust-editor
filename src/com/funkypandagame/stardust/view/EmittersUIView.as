package com.funkypandagame.stardust.view
{

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.NumericStepper;
import feathers.controls.PickerList;
import feathers.data.ListCollection;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import com.funkypandagame.stardust.controller.events.ChangeEmitterInFocusEvent;
import com.funkypandagame.stardust.controller.events.CloneEmitterEvent;
import com.funkypandagame.stardust.controller.events.EmitterChangeEvent;
import com.funkypandagame.stardust.controller.events.SnapshotEvent;

import com.funkypandagame.stardustplayer.emitter.EmitterValueObject;

import flash.events.EventDispatcher;

import starling.events.Event;

public class EmittersUIView extends LayoutGroup
{
    private var _fpsStepper:NumericStepper;
    private var _emitterDDL:PickerList;
    private var _emitterCollection:ListCollection = new ListCollection();
    private var _pendingSelection:EmitterValueObject;

    public var bus:EventDispatcher;
    public var fpsChangedCallback:Function;  // function(fps:Number):void

    public function EmittersUIView()
    {
        super();
        var v:VerticalLayout = new VerticalLayout();
        v.gap = 2;
        layout = v;
    }

    override protected function initialize():void
    {
        super.initialize();

        // FPS row
        var fpsRow:LayoutGroup = new LayoutGroup();
        var fpsH:HorizontalLayout = new HorizontalLayout();
        fpsH.verticalAlign = VerticalAlign.MIDDLE; fpsH.gap = 4; fpsH.paddingLeft = 50;
        fpsRow.layout = fpsH;
        addChild(fpsRow);

        var fpsLbl:Label = new Label(); fpsLbl.text = "FPS:";
        fpsRow.addChild(fpsLbl);

        _fpsStepper = new NumericStepper();
        _fpsStepper.minimum = 10; _fpsStepper.maximum = 60; _fpsStepper.step = 1; _fpsStepper.width = 60;
        _fpsStepper.addEventListener(Event.CHANGE, _onFPSChange);
        fpsRow.addChild(_fpsStepper);

        var snapBtn:Button = new Button(); snapBtn.label = "Take snapshot";
        snapBtn.addEventListener(Event.TRIGGERED, _onSnapshot);
        fpsRow.addChild(snapBtn);

        var clearBtn:Button = new Button(); clearBtn.label = "Clear snapshot";
        clearBtn.addEventListener(Event.TRIGGERED, _onClearSnapshot);
        fpsRow.addChild(clearBtn);

        // Emitters row
        var emRow:LayoutGroup = new LayoutGroup();
        var emH:HorizontalLayout = new HorizontalLayout();
        emH.verticalAlign = VerticalAlign.MIDDLE; emH.gap = 4; emH.paddingLeft = 3;
        emRow.layout = emH;
        addChild(emRow);

        var emLbl:Label = new Label(); emLbl.text = "Emitters";
        emRow.addChild(emLbl);

        _emitterDDL = new PickerList();
        _emitterDDL.dataProvider = _emitterCollection;
        _emitterDDL.labelFunction = _emitterLabel;
        _emitterDDL.width = 220;
        _emitterDDL.addEventListener(Event.CHANGE, _onEmitterChange);
        emRow.addChild(_emitterDDL);
        if (_pendingSelection != null)
        {
            _emitterDDL.selectedItem = _pendingSelection;
            _pendingSelection = null;
        }

        var addBtn:Button = new Button(); addBtn.label = "Add"; addBtn.width = 60;
        addBtn.addEventListener(Event.TRIGGERED, _onAdd);
        emRow.addChild(addBtn);

        var removeBtn:Button = new Button(); removeBtn.label = "Remove";
        removeBtn.addEventListener(Event.TRIGGERED, _onRemove);
        emRow.addChild(removeBtn);

        var cloneBtn:Button = new Button(); cloneBtn.label = "Clone";
        cloneBtn.addEventListener(Event.TRIGGERED, _onClone);
        emRow.addChild(cloneBtn);
    }

    public function setDropDownListResult(list:Array, emitterInFocus:EmitterValueObject):void
    {
        if (_emitterDDL) _emitterDDL.removeEventListener(Event.CHANGE, _onEmitterChange);
        _emitterCollection.removeAll();
        for each (var item:Object in list) _emitterCollection.addItem(item);
        if (_emitterDDL && _emitterDDL.isInitialized)
            _emitterDDL.selectedItem = emitterInFocus;
        else
            _pendingSelection = emitterInFocus;
        if (_emitterDDL) _emitterDDL.addEventListener(Event.CHANGE, _onEmitterChange);
    }

    public function refreshFPSText(val:Number):void
    {
        if (_fpsStepper) _fpsStepper.value = val;
    }

    private static function _emitterLabel(item:Object):String
    {
        if (item == null) return "";
        var evo:EmitterValueObject = item as EmitterValueObject;
        if (evo == null || evo.emitter == null) return "";
        return evo.emitter.name;
    }

    private function _onFPSChange(e:Event):void
    {
        var fps:Number = _fpsStepper.value;
        if (fpsChangedCallback != null) fpsChangedCallback(fps);
    }

    private function _onEmitterChange(e:Event):void
    {
        var evo:EmitterValueObject = _emitterDDL.selectedItem as EmitterValueObject;
        if (evo == null) return;
        if (bus) bus.dispatchEvent(new ChangeEmitterInFocusEvent(ChangeEmitterInFocusEvent.CHANGE, evo));
    }

    private function _onAdd(e:Event):void
    {
        if (bus) bus.dispatchEvent(new EmitterChangeEvent(EmitterChangeEvent.ADD));
    }

    private function _onRemove(e:Event):void
    {
        if (bus) bus.dispatchEvent(new EmitterChangeEvent(EmitterChangeEvent.REMOVE));
    }

    private function _onClone(e:Event):void
    {
        if (bus) bus.dispatchEvent(new CloneEmitterEvent());
    }

    private function _onSnapshot(e:Event):void
    {
        if (bus) bus.dispatchEvent(new SnapshotEvent(true));
    }

    private function _onClearSnapshot(e:Event):void
    {
        if (bus) bus.dispatchEvent(new SnapshotEvent(false));
    }
}
}
