package idv.cjcat.stardustextended.zones
{

import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;

/**
 * Circular zone.
 */
public class CircleZone extends Zone
{

    private var _radius : Number;
    private var _radiusSQ : Number;

    public function CircleZone(x : Number = 0, y : Number = 0, radius : Number = 100)
    {
        this._x = x;
        this._y = y;
        this.radius = radius;
    }

    /**
     * The radius of the zone.
     */
    public function get radius() : Number
    {
        return _radius;
    }

    public function set radius(value : Number) : void
    {
        _radius = value;
        _radiusSQ = value * value;
        updateArea();
    }

    override public function calculateMotionData2D() : MotionData2D
    {
        var theta : Number = StardustMath.TWO_PI * Math.random();
        var r : Number = _radius * Math.sqrt(Math.random());
        return MotionData2DPool.get(r * Math.cos(theta), r * Math.sin(theta));
    }

    override public function contains(x : Number, y : Number) : Boolean
    {
        var dx : Number = this._x - x;
        var dy : Number = this._y - y;
        return ((dx * dx + dy * dy) <= _radiusSQ) ? (true) : (false);
    }

    override protected function updateArea() : void
    {
        area = _radiusSQ * Math.PI;
    }


    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "CircleZone";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();
        xml.@x = _x;
        xml.@y = _y;
        xml.@radius = radius;
        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        if (xml.@x.length()) _x = parseFloat(xml.@x);
        if (xml.@y.length()) _y = parseFloat(xml.@y);
        if (xml.@radius.length()) radius = parseFloat(xml.@radius);
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}