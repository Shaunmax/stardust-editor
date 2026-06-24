package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardust.view.events.OnActionACChangeEvent;

import idv.cjcat.stardustextended.actions.Action;

public class OnActionACAddCommand
{
    private var _project:ProjectModel;
    private var _event:OnActionACChangeEvent;

    public function OnActionACAddCommand(project:ProjectModel, event:OnActionACChangeEvent)
    {
        _project = project;
        _event = event;
    }

    public function execute():void
    {
        _project.emitterInFocus.emitter.addAction(Action(_event.action));
    }
}
}
