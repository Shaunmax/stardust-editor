package com.funkypandagame.stardust.controller
{

import com.funkypandagame.stardust.controller.events.SnapshotEvent;
import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardustplayer.Particle2DSnapshot;
import com.funkypandagame.stardustplayer.emitter.EmitterValueObject;

import flash.net.registerClassAlias;
import flash.utils.ByteArray;
import flash.utils.getQualifiedClassName;

import idv.cjcat.stardustextended.particles.Particle;

public class StoreParticleSnapshotCommand
{
    private var _projectModel:ProjectModel;
    private var _event:SnapshotEvent;

    public function StoreParticleSnapshotCommand(model:ProjectModel, event:SnapshotEvent)
    {
        _projectModel = model;
        _event = event;
    }

    public function execute():void
    {
        for each (var emitterVO:EmitterValueObject in _projectModel.stadustSim.emitters)
        {
            if (_event.takeSnapshot)
            {
                registerClassAlias(getQualifiedClassName(Particle2DSnapshot), Particle2DSnapshot);
                var particlesData:Array = [];
                for each (var p:Particle in emitterVO.emitter.particles)
                {
                    var snap:Particle2DSnapshot = new Particle2DSnapshot();
                    snap.storeParticle(p);
                    particlesData.push(snap);
                }
                var ba:ByteArray = new ByteArray();
                ba.writeObject(particlesData);
                emitterVO.emitterSnapshot = ba;
            }
            else
            {
                emitterVO.emitterSnapshot = null;
            }
        }
    }
}
}
