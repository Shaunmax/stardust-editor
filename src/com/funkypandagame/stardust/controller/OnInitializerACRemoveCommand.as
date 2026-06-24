package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardust.view.events.OnInitializerACChangeEvent;

import idv.cjcat.stardustextended.initializers.Initializer;

public class OnInitializerACRemoveCommand
{
    private var _project:ProjectModel;
    private var _event:OnInitializerACChangeEvent;

    public function OnInitializerACRemoveCommand(project:ProjectModel, event:OnInitializerACChangeEvent)
    {
        _project = project;
        _event = event;
    }

    public function execute():void
    {
        _project.emitterInFocus.emitter.removeInitializer(Initializer(_event.initializer));
    }
}
}
