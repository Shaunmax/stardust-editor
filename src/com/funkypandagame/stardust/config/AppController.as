package com.funkypandagame.stardust.config {

import com.funkypandagame.stardust.controller.AddEmitterCommand;
import com.funkypandagame.stardust.controller.ChangeBackgroundCommand;
import com.funkypandagame.stardust.controller.ChangeEmitterInFocusCommand;
import com.funkypandagame.stardust.controller.CloneEmitterCommand;
import com.funkypandagame.stardust.controller.ConvertOldSimCommand;
import com.funkypandagame.stardust.controller.FileLoadCommand;
import com.funkypandagame.stardust.controller.ImportEmitterCommand;
import com.funkypandagame.stardust.controller.InitializeZoneDrawerFromEmitterCommand;
import com.funkypandagame.stardust.controller.LoadEmitterImageFromFileReferenceCommand;
import com.funkypandagame.stardust.controller.LoadEmitterPathCommand;
import com.funkypandagame.stardust.controller.LoadSimCommand;
import com.funkypandagame.stardust.controller.MainEnterFrameLoopService;
import com.funkypandagame.stardust.controller.OnActionACAddCommand;
import com.funkypandagame.stardust.controller.OnActionACRemoveCommand;
import com.funkypandagame.stardust.controller.OnInitializerACAddCommand;
import com.funkypandagame.stardust.controller.OnInitializerACRemoveCommand;
import com.funkypandagame.stardust.controller.RegenerateEmitterTexturesCommand;
import com.funkypandagame.stardust.controller.RemoveEmitterCommand;
import com.funkypandagame.stardust.controller.SaveSimCommand;
import com.funkypandagame.stardust.controller.StartSimCommand;
import com.funkypandagame.stardust.controller.StoreParticleSnapshotCommand;
import com.funkypandagame.stardust.controller.UpdateEmitterDropDownListCommand;
import com.funkypandagame.stardust.controller.events.BackgroundChangeEvent;
import com.funkypandagame.stardust.controller.events.ChangeEmitterInFocusEvent;
import com.funkypandagame.stardust.controller.events.CloneEmitterEvent;
import com.funkypandagame.stardust.controller.events.ConvertOldSimEvent;
import com.funkypandagame.stardust.controller.events.EmitterChangeEvent;
import com.funkypandagame.stardust.controller.events.EmitterImportedEvent;
import com.funkypandagame.stardust.controller.events.FileLoadEvent;
import com.funkypandagame.stardust.controller.events.ImportSimEvent;
import com.funkypandagame.stardust.controller.events.InitalizeZoneDrawerEvent;
import com.funkypandagame.stardust.controller.events.OpenImportPopupEvent;
import com.funkypandagame.stardust.controller.events.InitCompleteEvent;
import com.funkypandagame.stardust.controller.events.LoadSimEvent;
import com.funkypandagame.stardust.controller.events.RefreshFPSTextEvent;
import com.funkypandagame.stardust.controller.events.RegenerateEmitterTexturesEvent;
import com.funkypandagame.stardust.controller.events.SaveSimEvent;
import com.funkypandagame.stardust.controller.events.SetClockEvent;
import com.funkypandagame.stardust.controller.events.SetParticleHandlerEvent;
import com.funkypandagame.stardust.controller.events.SetResultsForEmitterDropDownListEvent;
import com.funkypandagame.stardust.controller.events.ShowSetEmitterImagePopupEvent;
import com.funkypandagame.stardust.controller.events.SnapshotEvent;
import com.funkypandagame.stardust.controller.events.StartSimEvent;
import com.funkypandagame.stardust.controller.events.UpdateEmitterDropDownListEvent;
import com.funkypandagame.stardust.controller.events.UpdateEmitterFromViewUICollectionsEvent;
import com.funkypandagame.stardust.helpers.Globals;
import com.funkypandagame.stardust.model.ProjectModel;
import com.funkypandagame.stardust.view.BackgroundProvider;
import com.funkypandagame.stardust.view.EmittersUIView;
import com.funkypandagame.stardust.view.ParticleHandlerContainer;
import com.funkypandagame.stardust.view.SetEmitterImagePopup;
import com.funkypandagame.stardust.view.StardusttoolMainView;
import com.funkypandagame.stardust.view.events.InitializeZoneDrawerFromEmitterGroupEvent;
import com.funkypandagame.stardust.view.events.LoadEmitterImageFromFileEvent;
import com.funkypandagame.stardust.view.events.OnActionACChangeEvent;
import com.funkypandagame.stardust.view.events.OnInitializerACChangeEvent;
import com.funkypandagame.stardust.view.events.PositionInitializerEmitterPathEvent;
import com.funkypandagame.stardust.view.events.RefreshBackgroundViewEvent;
import com.funkypandagame.stardust.view.importSim.ImportSimPopup;
import com.funkypandagame.stardust.view.importSim.ImportedEmitter;
import com.funkypandagame.stardust.view.stardust.common.clocks.ClockContainer;
import com.funkypandagame.stardust.view.stardust.twoD.initializers.UnifiedInitializer;
import com.funkypandagame.stardustplayer.SimLoader;
import com.funkypandagame.stardustplayer.SimPlayer;
import com.funkypandagame.stardustplayer.sequenceLoader.SequenceLoader;

import feathers.core.PopUpManager;

import flash.display.Graphics;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

import starling.core.Starling;
import starling.display.Sprite;

public class AppController {
    [Embed(source="../../../../resources/stardustProjectDEFAULT.sde", mimeType="application/octet-stream")]
    private static const DefaultSDE:Class;

    public static var instance:AppController;

    private var _bus:EventDispatcher;
    private var _projectModel:ProjectModel;
    private var _simLoader:SimLoader;
    private var _simPlayer:SimPlayer;
    private var _sequenceLoader:SequenceLoader;
    private var _mainLoop:MainEnterFrameLoopService;
    private var _starlingRoot:starling.display.Sprite;
    private var _overlay:flash.display.Sprite;

    private var _mainView:StardusttoolMainView;
    private var _emittersUIView:EmittersUIView;
    private var _backgroundProvider:BackgroundProvider;
    private var _particleHandlerContainer:ParticleHandlerContainer;
    private var _clockContainer:ClockContainer;
    private var _unifiedInitializer:UnifiedInitializer;
    private var _importSimPopup:ImportSimPopup;

    public function AppController(starlingRoot:starling.display.Sprite, overlay:flash.display.Sprite) {
        instance = this;
        _starlingRoot = starlingRoot;
        _overlay = overlay;

        _bus = new EventDispatcher();
        _projectModel = new ProjectModel();
        Globals.projectModel = _projectModel;
        _simLoader = new SimLoader();
        _simPlayer = new SimPlayer();
        _sequenceLoader = new SequenceLoader();
        _mainLoop = new MainEnterFrameLoopService(_projectModel, _simPlayer);
    }

    public function start():void {
        wireCommands();
        wireViewUpdates();
        createUI();
    }

    // ── Command wiring ────────────────────────────────────────────────────────

    private function wireCommands():void {
        _bus.addEventListener(StartSimEvent.START, _onStartSim);
        _bus.addEventListener(EmitterChangeEvent.ADD, _onAddEmitter);
        _bus.addEventListener(EmitterChangeEvent.REMOVE, _onRemoveEmitter);
        _bus.addEventListener(ChangeEmitterInFocusEvent.CHANGE, _onChangeEmitterInFocus);
        _bus.addEventListener(UpdateEmitterDropDownListEvent.UPDATE, _onUpdateEmitterDropDownList);
        _bus.addEventListener(OnActionACChangeEvent.ADD, _onActionACAdd);
        _bus.addEventListener(OnActionACChangeEvent.REMOVE, _onActionACRemove);
        _bus.addEventListener(OnInitializerACChangeEvent.ADD, _onInitializerACAdd);
        _bus.addEventListener(OnInitializerACChangeEvent.REMOVE, _onInitializerACRemove);
        _bus.addEventListener(LoadEmitterImageFromFileEvent.TYPE, _onLoadEmitterImageFromFile);
        _bus.addEventListener(SaveSimEvent.SAVE, _onSaveSim);
        _bus.addEventListener(LoadSimEvent.LOAD, _onLoadSim);
        _bus.addEventListener(FileLoadEvent.LOAD, _onFileLoad);
        _bus.addEventListener(BackgroundChangeEvent.TYPE, _onBackgroundChange);
        _bus.addEventListener(PositionInitializerEmitterPathEvent.LOAD, _onLoadEmitterPath);
        _bus.addEventListener(InitializeZoneDrawerFromEmitterGroupEvent.INITIALIZE, _onInitializeZoneDrawer);
        _bus.addEventListener(SnapshotEvent.TYPE, _onSnapshot);
        _bus.addEventListener(RegenerateEmitterTexturesEvent.TYPE, _onRegenerateEmitterTextures);
        _bus.addEventListener(CloneEmitterEvent.TYPE, _onCloneEmitter);
        _bus.addEventListener(ImportSimEvent.LOAD, _onImportSim);
        _bus.addEventListener(ConvertOldSimEvent.TYPE, _onConvertOldSim);
        _bus.addEventListener(ShowSetEmitterImagePopupEvent.SHOW_SET_EMITTER_IMAGE_POPUP, _onShowSetEmitterImagePopup);
        _bus.addEventListener(OpenImportPopupEvent.TYPE, _onOpenImportPopup);
    }

    private function _onStartSim(e:Event):void {
        new StartSimCommand(_bus, _projectModel, _mainLoop).execute();
    }

    private function _onAddEmitter(e:Event):void {
        new AddEmitterCommand(_bus, _projectModel).execute();
    }

    private function _onRemoveEmitter(e:Event):void {
        new RemoveEmitterCommand(_bus, _projectModel).execute();
    }

    private function _onChangeEmitterInFocus(e:ChangeEmitterInFocusEvent):void {
        new ChangeEmitterInFocusCommand(_bus, _projectModel, e).execute();
    }

    private function _onUpdateEmitterDropDownList(e:Event):void {
        new UpdateEmitterDropDownListCommand(_bus, _projectModel).execute();
    }

    private function _onActionACAdd(e:OnActionACChangeEvent):void {
        new OnActionACAddCommand(_projectModel, e).execute();
    }

    private function _onActionACRemove(e:OnActionACChangeEvent):void {
        new OnActionACRemoveCommand(_projectModel, e).execute();
    }

    private function _onInitializerACAdd(e:OnInitializerACChangeEvent):void {
        new OnInitializerACAddCommand(_projectModel, e).execute();
    }

    private function _onInitializerACRemove(e:OnInitializerACChangeEvent):void {
        new OnInitializerACRemoveCommand(_projectModel, e).execute();
    }

    private function _onLoadEmitterImageFromFile(e:Event):void {
        new LoadEmitterImageFromFileReferenceCommand(_bus, _sequenceLoader, _projectModel).execute();
    }

    private function _onSaveSim(e:Event):void {
        new SaveSimCommand(_projectModel).execute();
    }

    private function _onLoadSim(e:LoadSimEvent):void {
        new LoadSimCommand(_bus, _simLoader, _projectModel, _simPlayer, e).execute();
    }

    private function _onFileLoad(e:Event):void {
        new FileLoadCommand(_bus).execute();
    }

    private function _onBackgroundChange(e:BackgroundChangeEvent):void {
        new ChangeBackgroundCommand(_bus, _sequenceLoader, _projectModel, e).execute();
    }

    private function _onLoadEmitterPath(e:PositionInitializerEmitterPathEvent):void {
        new LoadEmitterPathCommand(_projectModel, e).execute();
    }

    private function _onInitializeZoneDrawer(e:InitializeZoneDrawerFromEmitterGroupEvent):void {
        new InitializeZoneDrawerFromEmitterCommand(_projectModel, e).execute();
    }

    private function _onSnapshot(e:SnapshotEvent):void {
        new StoreParticleSnapshotCommand(_projectModel, e).execute();
    }

    private function _onRegenerateEmitterTextures(e:Event):void {
        new RegenerateEmitterTexturesCommand(_projectModel).execute();
    }

    private function _onCloneEmitter(e:Event):void {
        new CloneEmitterCommand(_bus, _projectModel).execute();
    }

    private function _onImportSim(e:ImportSimEvent):void {
        new ImportEmitterCommand(_bus, _simLoader, e).execute();
    }

    private function _onConvertOldSim(e:Event):void {
        new ConvertOldSimCommand(_bus, _projectModel).execute();
    }

    private function _onShowSetEmitterImagePopup(e:ShowSetEmitterImagePopupEvent):void {
        var popup:SetEmitterImagePopup = new SetEmitterImagePopup();
        popup.setImageSlices(e.rawData[0], e.onClosed);
        PopUpManager.addPopUp(popup, true, true);
    }

    private function _onOpenImportPopup(e:Event):void {
        if (_importSimPopup == null) {
            _importSimPopup = new ImportSimPopup();
            _importSimPopup.openFileCallback = function ():void {
                _bus.dispatchEvent(new ImportSimEvent());
            };
            _importSimPopup.importCallback = _onImportSelected;
        }
        PopUpManager.addPopUp(_importSimPopup, true, true);
    }

    private function _onImportSelected(emitters:Vector.<ImportedEmitter>):void {
        for each (var ie:ImportedEmitter in emitters) {
            _projectModel.stadustSim.emitters[ie.emitterVo.id] = ie.emitterVo;
            _projectModel.emitterImages[ie.emitterVo.id] = ie.emitterImages;
        }
        _bus.dispatchEvent(new UpdateEmitterDropDownListEvent(UpdateEmitterDropDownListEvent.UPDATE));
        PopUpManager.removePopUp(_importSimPopup);
    }

    // ── View-update wiring ────────────────────────────────────────────────────

    private function wireViewUpdates():void {
        _bus.addEventListener(SetResultsForEmitterDropDownListEvent.UPDATE, _onSetResultsForEmitterDDL);
        _bus.addEventListener(RefreshFPSTextEvent.TYPE, _onRefreshFPSText);
        _bus.addEventListener(SetClockEvent.TYPE, _onSetClock);
        _bus.addEventListener(SetParticleHandlerEvent.TYPE, _onSetParticleHandler);
        _bus.addEventListener(RefreshBackgroundViewEvent.CHANGE, _onRefreshBackgroundView);
        _bus.addEventListener(ChangeEmitterInFocusEvent.CHANGE, _onChangeEmitterInFocusViewUpdate);
        _bus.addEventListener(UpdateEmitterFromViewUICollectionsEvent.UPDATE, _onUpdateEmitterFromViewUICollections);
        _bus.addEventListener(InitalizeZoneDrawerEvent.RESET, _onResetZoneDrawer);
        _bus.addEventListener(EmitterImportedEvent.TYPE, _onEmitterImported);
        _bus.addEventListener(InitCompleteEvent.TYPE, _onInitComplete);
    }

    private function _onSetResultsForEmitterDDL(e:SetResultsForEmitterDropDownListEvent):void {
        if (_emittersUIView) _emittersUIView.setDropDownListResult(e.list, e.emitterInFocus);
    }

    private function _onRefreshFPSText(e:Event):void {
        if (_emittersUIView && _projectModel.stadustSim)
            _emittersUIView.refreshFPSText(_projectModel.stadustSim.fps);
    }

    private function _onSetClock(e:Event):void {
        if (_clockContainer && _projectModel.emitterInFocus)
            _clockContainer.setData(_projectModel.emitterInFocus.emitter);
    }

    private function _onSetParticleHandler(e:SetParticleHandlerEvent):void {
        if (_particleHandlerContainer && _projectModel.emitterInFocus)
            _particleHandlerContainer.setHandler(e.handler, _projectModel.emitterImages[_projectModel.emitterInFocus.id]);
    }

    private function _onRefreshBackgroundView(e:Event):void {
        if (_backgroundProvider)
            _backgroundProvider.setData(_projectModel.hasBackground, _projectModel.backgroundColor, _projectModel.backgroundImage);
    }

    private function _onChangeEmitterInFocusViewUpdate(e:ChangeEmitterInFocusEvent):void {
        if (_unifiedInitializer && e.emitter) _unifiedInitializer.setData(e.emitter.emitter);
    }

    private function _onUpdateEmitterFromViewUICollections(e:UpdateEmitterFromViewUICollectionsEvent):void {
        if (_unifiedInitializer && e.emitterInFocus) _unifiedInitializer.setData(e.emitterInFocus.emitter);
        if (_mainView && e.emitterInFocus) _mainView.updateActionAndInitializerLists(e.emitterInFocus);
    }

    private function _onResetZoneDrawer(e:Event):void {
        _bus.dispatchEvent(new InitializeZoneDrawerFromEmitterGroupEvent(
                InitializeZoneDrawerFromEmitterGroupEvent.INITIALIZE, _overlay.graphics));
    }

    private function _onEmitterImported(e:EmitterImportedEvent):void {
        if (_importSimPopup) _importSimPopup.onEmitterImported(e.emitters);
    }

    private function _onInitComplete(e:Event):void {
        if (_mainView) _mainView.startEnterFrame(_mainLoop);
    }

    // ── UI creation ───────────────────────────────────────────────────────────

    private function createUI():void {
        _mainView = new StardusttoolMainView(_bus, _overlay);
        _mainView.width = Starling.current.stage.stageWidth;
        _mainView.height = Starling.current.stage.stageHeight;
        _starlingRoot.addChild(_mainView);
        Starling.current.nativeStage.addEventListener(Event.RESIZE, _onStageResize);

        _emittersUIView = _mainView.emittersUIView;
        _backgroundProvider = _mainView.backgroundProvider;
        _particleHandlerContainer = _mainView.particleHandlerContainer;
        _clockContainer = _mainView.clockContainer;
        _unifiedInitializer = _mainView.unifiedInitializer;

        _emittersUIView.fpsChangedCallback = function (newFPS:Number):void {
            if (_projectModel.stadustSim) _projectModel.stadustSim.fps = newFPS;
        };

        _mainView.updateStagePosition();
        loadDefaultSim();
    }

    private function _onStageResize(e:Event):void {
        var w:Number = Starling.current.nativeStage.stageWidth;
        var h:Number = Starling.current.nativeStage.stageHeight;
        Starling.current.stage.stageWidth = w;
        Starling.current.stage.stageHeight = h;
        Starling.current.viewPort = new Rectangle(0, 0, w, h);
        if (_mainView) {
            _mainView.width = w;
            _mainView.height = h;
            _mainView.updateStagePosition();
        }
    }

    private function loadDefaultSim():void {
        var bytes:ByteArray = new DefaultSDE() as ByteArray;
        _bus.dispatchEvent(new LoadSimEvent(bytes, "default"));
    }

    public function loadExternalSim(bytes:ByteArray, name:String):void {
        _bus.dispatchEvent(new LoadSimEvent(bytes, name));
    }
}
}
