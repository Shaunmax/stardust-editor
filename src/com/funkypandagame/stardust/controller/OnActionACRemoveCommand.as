package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardust.view.events.OnActionACChangeEvent;

import idv.cjcat.stardustextended.actions.Action;

public class OnActionACRemoveCommand
{
    private var _project:ProjectModel;
    private var _event:OnActionACChangeEvent;

    public function OnActionACRemoveCommand(project:ProjectModel, event:OnActionACChangeEvent)
    {
        _project = project;
        _event = event;
    }

    public function execute():void
    {
        _project.emitterInFocus.emitter.removeAction(Action(_event.action));
    }
}
}
