package com.funkypandagame.stardust.view.stardust.twoD
{

import feathers.controls.Button;
import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.List;
import feathers.controls.renderers.LayoutGroupListItemRenderer;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;

import starling.events.Event;

public class PropertyRendererBase extends LayoutGroupListItemRenderer
{
    protected var contentContainer:LayoutGroup;
    public var onRemove:Function;

    private var _enabledCheck:Check;
    private var _nameLabel:Label;
    private var _removeButton:Button;
    private var _nameText:String = "";
    private var _showRemoveButton:Boolean = true;

    override protected function initialize():void
    {
        super.initialize();

        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 3;
        hLayout.paddingLeft = 2;
        hLayout.paddingRight = 2;
        this.layout = hLayout;

        _enabledCheck = new Check();
        _enabledCheck.label = "";
        _enabledCheck.addEventListener(Event.CHANGE, _onEnabledChange);
        addChild(_enabledCheck);

        _nameLabel = new Label();
        _nameLabel.text = _nameText;
        addChild(_nameLabel);

        contentContainer = new LayoutGroup();
        contentContainer.layoutData = new HorizontalLayoutData(100);
        addChild(contentContainer);

        if (_showRemoveButton)
        {
            _removeButton = new Button();
            _removeButton.label = "Remove";
            _removeButton.addEventListener(Event.TRIGGERED, _onRemoveClick);
            addChild(_removeButton);
        }

        createContent();
    }

    protected function createContent():void {}

    override protected function draw():void
    {
        if (isInvalid(INVALIDATION_FLAG_DATA))
            commitData();
        super.draw();
    }

    override protected function commitData():void
    {
        if (_data && _enabledCheck)
            _enabledCheck.isSelected = Boolean(_data.active);
    }

    private function _onEnabledChange(e:Event):void
    {
        if (_data) _data.active = _enabledCheck.isSelected;
    }

    private function _onRemoveClick(e:Event):void
    {
        onRemoveButtonTriggered(e);
    }

    protected function onRemoveButtonTriggered(e:Event):void
    {
        if (onRemove != null)
            onRemove(this);
        else if (_owner)
            _owner.dataProvider.removeItemAt(_index);
    }

    public function set nameText(val:String):void
    {
        _nameText = val;
        if (_nameLabel) _nameLabel.text = val;
    }

    public function set showRemoveButton(val:Boolean):void
    {
        _showRemoveButton = val;
    }
}
}
