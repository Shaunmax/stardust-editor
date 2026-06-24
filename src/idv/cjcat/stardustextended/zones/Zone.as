package idv.cjcat.stardustextended.zones
{

import flash.geom.Point;

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.interfaces.IPosition;
import idv.cjcat.stardustextended.geom.MotionData2D;

/**
 * This class defines a 2D zone.
 *
 * <p>
 * The <code>calculateMotionData2D()</code> method returns a <code>MotionData2D</code> object
 * which corresponds to a random point within the zone.
 * </p>
 */
public class Zone extends StardustElement implements IPosition
{

    protected var _rotation : Number;
    protected var angleCos : Number;
    protected var angleSin : Number;
    protected var area : Number;

    protected const position : Point = new Point();

    protected var _x : Number;
    public function get x() : Number
    {
        return _x;
    }

    public function set x(value : Number) : void
    {
        _x = value
    }

    protected var _y : Number;
    public function get y() : Number
    {
        return _y;
    }

    public function set y(value : Number) : void
    {
        _y = value;
    }

    public function Zone()
    {
        rotation = 0;
    }

    /**
     * [Abstract Method] Updates the area of the zone.
     */
    protected function updateArea() : void
    {
        //abstract method
    }

    /**
     * [Abstract Method] Determines if a point is contained in the zone, true if contained.
     * @param    x
     * @param    y
     * @return
     */
    public function contains(x : Number, y : Number) : Boolean
    {
        //abstract method
        return false;
    }

    /**
     * Returns a random point in the zone.
     * @return
     */
    public function getPoint() : MotionData2D
    {
        var md2D : MotionData2D = calculateMotionData2D();
        if (_rotation != 0) {
            var originalX : Number = md2D.x;
            md2D.x = originalX * angleCos - md2D.y * angleSin;
            md2D.y = originalX * angleSin + md2D.y * angleCos;
        }
        md2D.x = _x + md2D.x;
        md2D.y = _y + md2D.y;
        return md2D;
    }

    public function get rotation() : Number
    {
        return _rotation;
    }

    public function set rotation(value : Number) : void
    {
        var valInRad : Number = value * StardustMath.DEGREE_TO_RADIAN;
        angleCos = Math.cos(valInRad);
        angleSin = Math.sin(valInRad);
        _rotation = value;
    }

    /**
     * [Abstract Method] Returns a <code>MotionData2D</code> object representing a random point in the zone
     * without rotation and translation
     * @return
     */
    public function calculateMotionData2D() : MotionData2D
    {
        throw new Error("calculateMotionData2D() must be overridden in the subclasses");
    }

    /**
     * Returns the area of the zone.
     * Areas are used by the <code>CompositeZone</code> class to determine which area is bigger and deserves more weight.
     * @return
     */
    public final function getArea() : Number
    {
        return area;
    }

    /**
     * Sets the position of this zone.
     */
    public function setPosition(xc : Number, yc : Number) : void
    {
        x = xc;
        y = yc;
    }

    /**
     * Gets the position of this Deflector.
     */
    public function getPosition() : Point
    {
        position.setTo(x, y);
        return position;
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "Zone";
    }

    override public function getElementTypeXMLTag() : XML
    {
        return <zones/>;
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();
        xml.@rotation = _rotation;
        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        rotation = parseFloat(xml.@rotation);
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}