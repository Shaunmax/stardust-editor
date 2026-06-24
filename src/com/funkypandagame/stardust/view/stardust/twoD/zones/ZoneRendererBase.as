package com.funkypandagame.stardust.view.stardust.twoD.zones
{

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.renderers.LayoutGroupListItemRenderer;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;

import starling.events.Event;

public class ZoneRendererBase extends LayoutGroupListItemRenderer
{
    protected var contentContainer:LayoutGroup;

    private var _nameLabel:Label;
    private var _removeButton:Button;
    private var _nameText:String = "";

    /** Assigned by ZoneContainer so Remove button can notify parent */
    public var onRemove:Function;

    /** Assigned by ZoneContainer so Remove button is disabled when only 1 zone */
    public var getCollectionLength:Function;

    override protected function initialize():void
    {
        super.initialize();

        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 3;
        hLayout.paddingLeft = 2;
        hLayout.paddingRight = 2;
        this.layout = hLayout;

        _nameLabel = new Label();
        _nameLabel.text = _nameText;
        addChild(_nameLabel);

        contentContainer = new LayoutGroup();
        contentContainer.layoutData = new HorizontalLayoutData(100);
        addChild(contentContainer);

        _removeButton = new Button();
        _removeButton.label = "Remove";
        _removeButton.addEventListener(Event.TRIGGERED, _onRemoveClick);
        addChild(_removeButton);

        createContent();
    }

    protected function createContent():void {}

    override protected function draw():void
    {
        if (isInvalid(INVALIDATION_FLAG_DATA))
            commitData();
        if (_removeButton && getCollectionLength != null)
            _removeButton.isEnabled = getCollectionLength() > 1;
        super.draw();
    }

    override protected function commitData():void {}

    private function _onRemoveClick(e:Event):void
    {
        if (onRemove != null) onRemove(this);
    }

    public function set nameText(val:String):void
    {
        _nameText = val;
        if (_nameLabel) _nameLabel.text = val;
    }
}
}
