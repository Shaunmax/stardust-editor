package idv.cjcat.stardustextended.deflectors
{
import flash.geom.Point;

import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData4D;
import idv.cjcat.stardustextended.geom.MotionData4DPool;

/**
 * Keeps particles inside a rectangular region.
 *
 * <p>
 * When a particle goes beyond a wall of the region, it reappears from the other side.
 * </p>
 */
public class WrappingBox extends Deflector
{

    /**
     * The X coordinate of the top-left corner.
     */
    public var x : Number;
    /**
     * The Y coordinate of the top-left corner.
     */
    public var y : Number;
    /**
     * The width of the region.
     */
    public var width : Number;
    /**
     * The height of the region.
     */
    public var height : Number;

    public function WrappingBox(x : Number = 0, y : Number = 0, width : Number = 640, height : Number = 480)
    {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }

    private var left : Number;
    private var right : Number;
    private var top : Number;
    private var bottom : Number;
    private var deflected : Boolean;
    private var newX : Number;
    private var newY : Number;

    override protected function calculateMotionData4D(particle : Particle) : MotionData4D
    {
        left = x;
        right = x + width;
        top = y;
        bottom = y + height;

        deflected = false;
        if (particle.x < x) deflected = true;
        else if (particle.x > (x + width)) deflected = true;
        if (particle.y < y) deflected = true;
        else if (particle.y > (y + height)) deflected = true;

        newX = StardustMath.mod(particle.x - x, width);
        newY = StardustMath.mod(particle.y - y, height);

        if (deflected) return MotionData4DPool.get(x + newX, y + newY, particle.vx, particle.vy);
        else return null;
    }

    override public function setPosition(xc : Number, yc : Number) : void
    {
        x = xc;
        y = yc;
    }

    override public function getPosition() : Point
    {
        position.setTo(x, y);
        return position;
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "WrappingBox";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();

        delete xml.@bounce;

        xml.@x = x;
        xml.@y = y;
        xml.@width = width;
        xml.@height = height;

        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        if (xml.@x.length()) x = parseFloat(xml.@x);
        if (xml.@y.length()) y = parseFloat(xml.@y);
        if (xml.@width.length()) width = parseFloat(xml.@width);
        if (xml.@height.length()) height = parseFloat(xml.@height);
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}