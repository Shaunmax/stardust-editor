package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;
import com.funkypandagame.stardust.view.stardust.twoD.actions.waypoint.WaypointRenderer;

import feathers.controls.Button;
import feathers.controls.Check;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import idv.cjcat.stardustextended.actions.FollowWaypoints;
import idv.cjcat.stardustextended.actions.waypoints.Waypoint;

import starling.events.Event;

public class FollowWaypointsAction extends PropertyRendererBase
{
    private var _masslessCheck:Check;
    private var _loopCheck:Check;
    private var _renderersGroup:LayoutGroup;
    private var _renderers:Vector.<WaypointRenderer> = new <WaypointRenderer>[];

    override protected function initialize():void
    {
        nameText = "Waypoints";
        super.initialize();
    }

    override protected function createContent():void
    {
        var vLayout:VerticalLayout = new VerticalLayout();
        vLayout.gap = 4;
        contentContainer.layout = vLayout;

        var topRow:LayoutGroup = new LayoutGroup();
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.verticalAlign = VerticalAlign.MIDDLE;
        hLayout.gap = 6;
        topRow.layout = hLayout;
        contentContainer.addChild(topRow);

        var addBtn:Button = new Button();
        addBtn.label = "Add waypoint";
        addBtn.addEventListener(Event.TRIGGERED, _onAdd);
        topRow.addChild(addBtn);

        _masslessCheck = new Check();
        _masslessCheck.label = "Massless";
        _masslessCheck.addEventListener(Event.CHANGE, _onCheckChange);
        topRow.addChild(_masslessCheck);

        _loopCheck = new Check();
        _loopCheck.label = "Loop";
        _loopCheck.addEventListener(Event.CHANGE, _onCheckChange);
        topRow.addChild(_loopCheck);

        _renderersGroup = new LayoutGroup();
        var rvLayout:VerticalLayout = new VerticalLayout();
        rvLayout.gap = 3;
        _renderersGroup.layout = rvLayout;
        contentContainer.addChild(_renderersGroup);
    }

    override protected function commitData():void
    {
        super.commitData();
        if (!_data || !_renderersGroup) return;
        var d:FollowWaypoints = FollowWaypoints(_data);
        _masslessCheck.isSelected = d.massless;
        _loopCheck.isSelected = d.loop;
        _clearRenderers();
        for (var i:int = 0; i < d.waypoints.length; i++)
            _addWaypointRenderer(d.waypoints[i] as Waypoint);
    }

    private function _addWaypointRenderer(wp:Waypoint):void
    {
        var renderer:WaypointRenderer = new WaypointRenderer();
        renderer.onRemove = _onRemoveWaypoint;
        _renderersGroup.addChild(renderer);
        renderer.setData(wp);
        _renderers.push(renderer);
    }

    private function _clearRenderers():void
    {
        for (var i:int = 0; i < _renderers.length; i++)
            _renderersGroup.removeChild(_renderers[i]);
        _renderers.length = 0;
    }

    private function _onAdd(e:Event):void
    {
        if (!_data) return;
        var wp:Waypoint = new Waypoint();
        FollowWaypoints(_data).addWaypoint(wp);
        _addWaypointRenderer(wp);
    }

    private function _onCheckChange(e:Event):void
    {
        if (!_data) return;
        var d:FollowWaypoints = FollowWaypoints(_data);
        d.massless = _masslessCheck.isSelected;
        d.loop = _loopCheck.isSelected;
    }

    private function _onRemoveWaypoint(renderer:WaypointRenderer):void
    {
        var idx:int = _renderers.indexOf(renderer);
        if (idx < 0) return;
        var d:FollowWaypoints = FollowWaypoints(_data);
        var waypoints:Vector.<Waypoint> = d.waypoints;
        for (var i:int = 0; i < waypoints.length; i++)
        {
            if (waypoints[i] === renderer.data)
            {
                waypoints.splice(i, 1);
                break;
            }
        }
        _renderersGroup.removeChild(renderer);
        _renderers.splice(idx, 1);
    }
}
}
