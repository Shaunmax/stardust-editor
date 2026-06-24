package com.funkypandagame.stardust.view.importSim
{

import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.List;
import feathers.controls.Panel;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import feathers.core.PopUpManager;

import starling.events.Event;

public class ImportSimPopup extends Panel
{
    private var _importList:List;
    private var _importBtn:Button;
    private var _emitterCollection:ListCollection = new ListCollection();

    public var openFileCallback:Function;       // called when "Open file" is clicked
    public var importCallback:Function;         // function(emitters:Vector.<ImportedEmitter>):void

    public function ImportSimPopup()
    {
        super();
        title = "Import emitter (BETA)";
        width = 750;
    }

    override protected function initialize():void
    {
        super.initialize();

        var v:VerticalLayout = new VerticalLayout();
        v.gap = 4; v.paddingLeft = 5; v.paddingRight = 5;
        v.paddingTop = 5; v.paddingBottom = 5;
        layout = v;

        var topRow:LayoutGroup = new LayoutGroup();
        var th:HorizontalLayout = new HorizontalLayout();
        th.verticalAlign = VerticalAlign.MIDDLE; th.gap = 4;
        topRow.layout = th;
        addChild(topRow);

        var topLbl:Label = new Label(); topLbl.text = "Select an .sde file to load emitter from";
        topRow.addChild(topLbl);

        var openBtn:Button = new Button(); openBtn.label = "Open file";
        openBtn.addEventListener(Event.TRIGGERED, _onOpenFile);
        topRow.addChild(openBtn);

        var selLbl:Label = new Label(); selLbl.text = "Select the emitter(s) to import";
        addChild(selLbl);

        _importList = new List();
        _importList.dataProvider = _emitterCollection;
        _importList.allowMultipleSelection = true;
        _importList.height = 125;
        _importList.itemRendererType = ImportEmitterRenderer;
        addChild(_importList);

        var btnRow:LayoutGroup = new LayoutGroup();
        var bh:HorizontalLayout = new HorizontalLayout(); bh.gap = 4;
        btnRow.layout = bh;
        addChild(btnRow);

        _importBtn = new Button(); _importBtn.label = "import";
        _importBtn.isEnabled = false;
        _importBtn.addEventListener(Event.TRIGGERED, _onImport);
        btnRow.addChild(_importBtn);

        var cancelBtn:Button = new Button(); cancelBtn.label = "cancel";
        cancelBtn.addEventListener(Event.TRIGGERED, _onClose);
        btnRow.addChild(cancelBtn);

        _importList.addEventListener(Event.CHANGE, _onSelectionChange);
    }

    public function onEmitterImported(emitters:Vector.<ImportedEmitter>):void
    {
        _emitterCollection.removeAll();
        for each (var e:ImportedEmitter in emitters) _emitterCollection.addItem(e);
        _importBtn.isEnabled = false;
    }

    private function _onSelectionChange(e:Event):void
    {
        _importBtn.isEnabled = (_importList.selectedItems != null && _importList.selectedItems.length > 0);
    }

    private function _onOpenFile(e:Event):void
    {
        if (openFileCallback != null) openFileCallback();
    }

    private function _onImport(e:Event):void
    {
        if (importCallback != null)
        {
            var selected:Vector.<ImportedEmitter> = new <ImportedEmitter>[];
            for each (var item:Object in _importList.selectedItems)
                selected.push(ImportedEmitter(item));
            importCallback(selected);
        }
    }

    private function _onClose(e:Event):void
    {
        PopUpManager.removePopUp(this);
    }
}
}
