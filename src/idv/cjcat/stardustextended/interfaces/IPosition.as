package idv.cjcat.stardustextended.interfaces
{
import flash.geom.Point;

public interface IPosition
{
    function setPosition(xc : Number, yc : Number) : void;

    function getPosition() : Point;
}
}
