package com.funkypandagame.stardust.view.stardust.twoD.fields
{

import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.controls.renderers.LayoutGroupListItemRenderer;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;

import starling.events.Event;

public class FieldRendererBase extends LayoutGroupListItemRenderer
{
    protected var contentContainer:LayoutGroup;
    public var onRemove:Function;
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

        contentContainer = new LayoutGroup();
        contentContainer.layoutData = new HorizontalLayoutData(100);
        addChild(contentContainer);

        var removeBtn:Button = new Button();
        removeBtn.label = "Remove";
        removeBtn.addEventListener(Event.TRIGGERED, _onRemoveClick);
        addChild(removeBtn);

        createContent();
    }

    protected function createContent():void {}

    override protected function draw():void
    {
        if (isInvalid(INVALIDATION_FLAG_DATA))
            commitData();
        super.draw();
    }

    override protected function commitData():void {}

    private function _onRemoveClick(e:Event):void
    {
        if (onRemove != null) onRemove(this);
    }
}
}
