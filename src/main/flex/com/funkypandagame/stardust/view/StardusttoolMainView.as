package com.funkypandagame.stardust.view
{

import feathers.controls.Button;
import feathers.controls.Check;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ScrollContainer;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import feathers.core.PopUpManager;

import com.funkypandagame.stardust.controller.MainEnterFrameLoopService;
import com.funkypandagame.stardust.controller.events.ConvertOldSimEvent;
import com.funkypandagame.stardust.controller.events.FileLoadEvent;
import com.funkypandagame.stardust.controller.events.LoadSimEvent;
import com.funkypandagame.stardust.controller.events.OpenImportPopupEvent;
import com.funkypandagame.stardust.controller.events.SaveSimEvent;
import com.funkypandagame.stardust.controller.events.StartSimEvent;
import com.funkypandagame.stardust.helpers.Globals;
import com.funkypandagame.stardust.view.stardust.common.clocks.ClockContainer;
import com.funkypandagame.stardust.view.stardust.twoD.initializers.UnifiedInitializer;

import com.funkypandagame.stardustplayer.emitter.EmitterValueObject;

import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

import starling.core.Starling;
import starling.events.Event;

public class StardusttoolMainView extends LayoutGroup
{
    public static const LEFT_COLUMN_WIDTH:int = 600;

    // Sub-views exposed to AppController
    public var emittersUIView:EmittersUIView;
    public var backgroundProvider:BackgroundProvider;
    public var particleHandlerContainer:ParticleHandlerContainer;
    public var clockContainer:ClockContainer;
    public var unifiedInitializer:UnifiedInitializer;
    public var actionsContainer:StardustElementContainer;
    public var canvasPosition:CanvasPositionView;

    private var _zonesVisibleCheck:Check;
    private var _infoLabel:Label;
    private var _previewOverlay:Sprite;
    private var _bus:EventDispatcher;
    private var _mainLoop:MainEnterFrameLoopService;
    private var _examplesPopup:ExamplesPopup;

    /** Set by AppController to open the import popup */
    public var onOpenImportPopup:Function;

    public function StardusttoolMainView(bus:EventDispatcher, projectModel:ProjectModel, overlay:Sprite)
    {
        super();
        _bus = bus;
        _previewOverlay = overlay;
        layout = new AnchorLayout();
    }

    override protected function initialize():void
    {
        super.initialize();

        // Left column
        var leftCol:LayoutGroup = new LayoutGroup();
        var leftV:VerticalLayout = new VerticalLayout();
        leftV.gap = 2; leftV.paddingLeft = 3; leftV.paddingTop = 3; leftV.paddingBottom = 3;
        leftCol.layout = leftV;
        leftCol.layoutData = new AnchorLayoutData(0, NaN, 0, 0);
        leftCol.width = LEFT_COLUMN_WIDTH;
        addChild(leftCol);

        // Emitters row
        emittersUIView = new EmittersUIView();
        emittersUIView.bus = _bus;
        leftCol.addChild(emittersUIView);

        // Clock + particle handler block
        var clockHandlerGroup:LayoutGroup = new LayoutGroup();
        var chV:VerticalLayout = new VerticalLayout(); chV.gap = 0;
        clockHandlerGroup.layout = chV;
        leftCol.addChild(clockHandlerGroup);

        clockContainer = new ClockContainer();
        clockHandlerGroup.addChild(clockContainer);

        particleHandlerContainer = new ParticleHandlerContainer();
        particleHandlerContainer.bus = _bus;
        clockHandlerGroup.addChild(particleHandlerContainer);

        // Initializers label
        var initLabel:Label = new Label(); initLabel.text = "Initializers";
        leftCol.addChild(initLabel);

        // Initializers scroller (45% of remaining height approx)
        var initScroller:ScrollContainer = new ScrollContainer();
        initScroller.height = 200;
        initScroller.horizontalScrollPolicy = ScrollContainer.SCROLL_POLICY_OFF;
        leftCol.addChild(initScroller);

        unifiedInitializer = new UnifiedInitializer();
        initScroller.addChild(unifiedInitializer);

        // Actions container (takes remaining height)
        actionsContainer = new StardustElementContainer();
        actionsContainer.label = "Actions";
        actionsContainer.fullCollection = Globals.actionsCollection;
        actionsContainer.dataproviderDict = Globals.actionDict;
        actionsContainer.onElementAdded = function(item:StardustElement):void {
            _bus.dispatchEvent(new OnActionACChangeEvent(OnActionACChangeEvent.ADD, Action(item)));
        };
        actionsContainer.onElementRemoved = function(item:StardustElement):void {
            _bus.dispatchEvent(new OnActionACChangeEvent(OnActionACChangeEvent.REMOVE, Action(item)));
        };
        leftCol.addChild(actionsContainer);

        // Right column
        var rightCol:LayoutGroup = new LayoutGroup();
        var rightV:VerticalLayout = new VerticalLayout();
        rightV.gap = 4; rightV.paddingLeft = 3; rightV.paddingTop = 3; rightV.paddingRight = 3;
        rightCol.layout = rightV;
        rightCol.layoutData = new AnchorLayoutData(0, 0, NaN, NaN);
        addChild(rightCol);

        _btn("Restart sim", rightCol, _onRestart);
        _btn("Load", rightCol, _onLoad);
        _btn("Import", rightCol, _onImport);
        _btn("Save as..", rightCol, _onSave);
        _btn("Examples", rightCol, _onExamples);

        var spacer:LayoutGroup = new LayoutGroup(); spacer.height = 13;
        rightCol.addChild(spacer);

        _zonesVisibleCheck = new Check(); _zonesVisibleCheck.label = "Zones visible";
        rightCol.addChild(_zonesVisibleCheck);

        backgroundProvider = new BackgroundProvider();
        backgroundProvider.bus = _bus;
        rightCol.addChild(backgroundProvider);

        canvasPosition = new CanvasPositionView();
        canvasPosition.mainView = this;
        rightCol.addChild(canvasPosition);

        _btn("Convert to new format", rightCol, _onConvert);

        // Info label (bottom-right)
        _infoLabel = new Label();
        _infoLabel.layoutData = new AnchorLayoutData(NaN, 5, 5, NaN);
        addChild(_infoLabel);
    }

    private function _btn(lbl:String, parent:LayoutGroup, handler:Function):Button
    {
        var b:Button = new Button(); b.label = lbl;
        b.addEventListener(Event.TRIGGERED, handler);
        parent.addChild(b);
        return b;
    }

    // ── Public API for AppController ──────────────────────────────────────────

    public function get zonesVisible():Boolean
    {
        return _zonesVisibleCheck && _zonesVisibleCheck.isSelected;
    }

    public function set infoText(text:String):void
    {
        if (_infoLabel) _infoLabel.text = text;
    }

    public function get previewOverlay():Sprite
    {
        return _previewOverlay;
    }

    public function startEnterFrame(mainLoop:MainEnterFrameLoopService):void
    {
        _mainLoop = mainLoop;
        _mainLoop.init(
            _previewOverlay.graphics,
            function():Boolean { return _zonesVisibleCheck && _zonesVisibleCheck.isSelected; },
            function(text:String):void { if (_infoLabel) _infoLabel.text = text; }
        );
        addEventListener(Event.ENTER_FRAME, _onEnterFrame);
    }

    public function updateActionAndInitializerLists(emitterVo:EmitterValueObject):void
    {
        if (!emitterVo) return;
        var emitter:* = emitterVo.emitter;
        var actionsVec:Vector.<StardustElement> = new <StardustElement>[];
        for (var i:int = 0; i < emitter.actions.length; i++)
            actionsVec.push(StardustElement(emitter.actions[i]));
        actionsContainer.setData(actionsVec);
    }

    public function updateStagePosition():void
    {
        var isCentered:Boolean = canvasPosition && canvasPosition.isCenterSelected;
        if (isCentered)
        {
            var sw:Number = Starling.current.stage.stageWidth;
            var sh:Number = Starling.current.stage.stageHeight;
            Globals.starlingCanvas.x = (sw - LEFT_COLUMN_WIDTH) * 0.5 + LEFT_COLUMN_WIDTH;
            Globals.starlingCanvas.y = sh * 0.5;
        }
        else
        {
            Globals.starlingCanvas.x = LEFT_COLUMN_WIDTH;
            Globals.starlingCanvas.y = 0;
        }
        backgroundProvider.setBgImagePosition(
            Globals.starlingCanvas.x, Globals.starlingCanvas.y,
            Starling.current.stage.stageWidth - LEFT_COLUMN_WIDTH,
            Starling.current.stage.stageHeight
        );
        if (_previewOverlay)
        {
            _previewOverlay.x = Globals.starlingCanvas.x;
            _previewOverlay.y = Globals.starlingCanvas.y;
        }
    }

    // ── Private event handlers ─────────────────────────────────────────────────

    private function _onEnterFrame(e:Event):void
    {
        if (_mainLoop) _mainLoop.onEnterFrame();
    }

    private function _onRestart(e:Event):void
    {
        if (_bus) _bus.dispatchEvent(new StartSimEvent());
    }

    private function _onLoad(e:Event):void
    {
        if (_bus) _bus.dispatchEvent(new FileLoadEvent());
    }

    private function _onImport(e:Event):void
    {
        if (_bus) _bus.dispatchEvent(new OpenImportPopupEvent());
    }

    private function _onSave(e:Event):void
    {
        if (_bus) _bus.dispatchEvent(new SaveSimEvent(SaveSimEvent.SAVE));
    }

    private function _onExamples(e:Event):void
    {
        if (_examplesPopup == null)
        {
            _examplesPopup = new ExamplesPopup();
            _examplesPopup.callback = _onLoadExample;
        }
        PopUpManager.addPopUp(_examplesPopup, true, true);
    }

    private function _onLoadExample(sdeFile:ByteArray, name:String):void
    {
        if (_bus) _bus.dispatchEvent(new LoadSimEvent(sdeFile, name));
    }

    private function _onConvert(e:Event):void
    {
        if (_bus) _bus.dispatchEvent(new ConvertOldSimEvent());
    }
}
}
