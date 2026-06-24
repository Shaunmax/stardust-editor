package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.helpers.ZoneDrawer;
import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardust.view.events.InitializeZoneDrawerFromEmitterGroupEvent;

public class InitializeZoneDrawerFromEmitterCommand
{
    private var _projectSettings:ProjectModel;
    private var _event:InitializeZoneDrawerFromEmitterGroupEvent;

    public function InitializeZoneDrawerFromEmitterCommand(projectSettings:ProjectModel, event:InitializeZoneDrawerFromEmitterGroupEvent)
    {
        _projectSettings = projectSettings;
        _event = event;
    }

    public function execute():void
    {
        if (_projectSettings.emitterInFocus == null) return;
        ZoneDrawer.init(_projectSettings.emitterInFocus.emitter, _event.targetGraphics);
    }
}
}
