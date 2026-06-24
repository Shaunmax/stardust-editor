package idv.cjcat.stardustextended.events
{

import flash.events.Event;

import idv.cjcat.stardustextended.actions.Action;

public class StardustActionEvent extends Event
{

    public static const PRIORITY_CHANGE : String = "PRIORITY_CHANGE";
    public static const ADD : String = "ADD";
    public static const REMOVE : String = "REMOVE";

    private var _action : Action;

    public function StardustActionEvent(_type : String, action : Action)
    {
        super(_type);
        _action = action;
    }

    public function get action() : Action
    {
        return _action;
    }

    override public function clone() : Event
    {
        return new StardustActionEvent(type, _action);
    }
}
}
