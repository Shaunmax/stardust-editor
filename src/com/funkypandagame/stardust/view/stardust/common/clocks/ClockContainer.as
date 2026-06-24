package com.funkypandagame.stardust.view.stardust.common.clocks
{

import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.PickerList;
import feathers.data.ListCollection;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import com.funkypandagame.stardust.helpers.DropdownListVO;

import idv.cjcat.stardustextended.clocks.Clock;
import idv.cjcat.stardustextended.clocks.ImpulseClock;
import idv.cjcat.stardustextended.clocks.SteadyClock;
import idv.cjcat.stardustextended.emitters.Emitter;

import starling.events.Event;

public class ClockContainer extends LayoutGroup
{
    private static const CLOCKS_COLLECTION:ListCollection = new ListCollection([
        new DropdownListVO("Constant",  SteadyClock,  SteadyClockRenderer),
        new DropdownListVO("Impulses",  ImpulseClock, ImpulseClockRenderer)
    ]);

    private var _ddl:PickerList;
    private var _activeCheck:Check;
    private var _contentGroup:LayoutGroup;
    private var _clockRenderer:IClockRenderer;
    private var _emitter:Emitter;

    public function ClockContainer()
    {
        super();
        var v:VerticalLayout = new VerticalLayout();
        v.gap = 2; v.paddingLeft = 4; v.paddingRight = 4;
        v.paddingTop = 4; v.paddingBottom = 4;
        layout = v;
    }

    override protected function initialize():void
    {
        super.initialize();

        var headerRow:LayoutGroup = new LayoutGroup();
        var h:HorizontalLayout = new HorizontalLayout();
        h.verticalAlign = VerticalAlign.MIDDLE; h.gap = 4;
        headerRow.layout = h;
        addChild(headerRow);

        var lbl:Label = new Label(); lbl.text = "Particle generation pattern:";
        headerRow.addChild(lbl);

        _ddl = new PickerList();
        _ddl.dataProvider = CLOCKS_COLLECTION;
        _ddl.labelField = "name";
        _ddl.selectedIndex = 0;
        _ddl.addEventListener(Event.CHANGE, _onClockTypeChange);
        headerRow.addChild(_ddl);

        _activeCheck = new Check();
        _activeCheck.label = "Active";
        _activeCheck.addEventListener(Event.CHANGE, _onActiveChange);
        headerRow.addChild(_activeCheck);

        _contentGroup = new LayoutGroup();
        addChild(_contentGroup);
    }

    public function setData(emitter:Emitter):void
    {
        _emitter = emitter;
        _activeCheck.isSelected = emitter.active;

        if (emitter.clock is SteadyClock)
            _ddl.selectedIndex = 0;
        else if (emitter.clock is ImpulseClock)
            _ddl.selectedIndex = 1;

        _populateContent();
    }

    private function _onClockTypeChange(e:Event):void
    {
        if (!_emitter) return;
        var ddlVO:DropdownListVO = DropdownListVO(_ddl.selectedItem);
        _emitter.clock = Clock(new ddlVO.stardustClass());
        _populateContent();
    }

    private function _onActiveChange(e:Event):void
    {
        if (_emitter) _emitter.active = _activeCheck.isSelected;
    }

    private function _populateContent():void
    {
        while (_contentGroup.numChildren > 0)
            _contentGroup.removeChildAt(0, true);

        var ddlVO:DropdownListVO = DropdownListVO(_ddl.selectedItem);
        var RendererClass:Class = ddlVO.viewClass;
        var renderer:IClockRenderer = new RendererClass();
        _clockRenderer = renderer;
        _contentGroup.addChild(LayoutGroup(renderer));
        renderer.setData(_emitter.clock);
    }
}
}
