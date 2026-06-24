package com.funkypandagame.stardust.view
{

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Radio;
import feathers.core.ToggleGroup;
import feathers.layout.VerticalLayout;

import starling.events.Event;

public class CanvasPositionView extends LayoutGroup
{
    private var _mainView:StardusttoolMainView;
    private var _topRadio:Radio;
    private var _centerRadio:Radio;
    private var _toggleGroup:ToggleGroup;

    public function CanvasPositionView()
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

        var lbl:Label = new Label(); lbl.text = "Stage 0,0 position";
        addChild(lbl);

        _toggleGroup = new ToggleGroup();
        _toggleGroup.addEventListener(Event.CHANGE, _onChange);

        _topRadio = new Radio(); _topRadio.label = "Top Left";
        _topRadio.toggleGroup = _toggleGroup;
        addChild(_topRadio);

        _centerRadio = new Radio(); _centerRadio.label = "Center";
        _centerRadio.toggleGroup = _toggleGroup;
        addChild(_centerRadio);

        _toggleGroup.selectedIndex = 1; // default: Center
    }

    public function set mainView(view:StardusttoolMainView):void
    {
        _mainView = view;
    }

    public function get isCenterSelected():Boolean
    {
        return _centerRadio && _centerRadio.isSelected;
    }

    private function _onChange(e:Event):void
    {
        if (_mainView) _mainView.updateStagePosition();
    }
}
}
