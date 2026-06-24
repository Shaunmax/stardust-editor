package idv.cjcat.stardustextended.actions
{
import idv.cjcat.stardustextended.zones.Zone;

public interface IZoneContainer
{
    function get zones() : Vector.<Zone>;

    function set zones(value : Vector.<Zone>) : void;
}
}
