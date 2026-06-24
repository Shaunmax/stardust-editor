package idv.cjcat.stardustextended.zones
{

import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;

/**
 * Single point zone.
 */
public class SinglePoint extends Contour
{

    public function SinglePoint(x : Number = 0, y : Number = 0)
    {
        _x = x;
        _y = y;
        updateArea();
    }

    override public function contains(x : Number, y : Number) : Boolean
    {
        if ((_x == x) && (_y == y)) return true;
        return false;
    }

    override public function calculateMotionData2D() : MotionData2D
    {
        return MotionData2DPool.get(0, 0);
    }

    override protected function updateArea() : void
    {
        area = virtualThickness * virtualThickness * Math.PI;
    }


    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "SinglePoint";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();
        xml.@x = _x;
        xml.@y = _y;
        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);
        if (xml.@x.length()) _x = parseFloat(xml.@x);
        if (xml.@y.length()) _y = parseFloat(xml.@y);
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}

}