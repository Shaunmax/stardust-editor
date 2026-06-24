package idv.cjcat.stardustextended.events
{

import flash.events.Event;

import idv.cjcat.stardustextended.initializers.Initializer;

public class StardustInitializerEvent extends Event
{

    public static const PRIORITY_CHANGE : String = "PRIORITY_CHANGE";
    public static const ADD : String = "ADD";
    public static const REMOVE : String = "REMOVE";

    private var _initializer : Initializer;

    public function StardustInitializerEvent(_type : String, action : Initializer)
    {
        super(_type);
        _initializer = action;
    }

    public function get initializer() : Initializer
    {
        return _initializer;
    }

    override public function clone() : Event
    {
        return new StardustInitializerEvent(type, _initializer);
    }
}
}
