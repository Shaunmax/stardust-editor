package com.funkypandagame.stardust.view.stardust.twoD.actions
{

import com.funkypandagame.stardust.view.stardust.twoD.PropertyRendererBase;

public class DeathLifeAction extends PropertyRendererBase
{
    override protected function initialize():void
    {
        nameText = "Die when life is zero";
        super.initialize();
    }
}
}
