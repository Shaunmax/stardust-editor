package idv.cjcat.stardustextended.actions
{
import idv.cjcat.stardustextended.fields.Field;

public interface IFieldContainer
{
    function get fields() : Vector.<Field>;

    function set fields(value : Vector.<Field>) : void;
}
}
