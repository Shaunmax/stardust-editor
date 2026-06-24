package idv.cjcat.stardustextended.deflectors
{
import flash.geom.Point;

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.interfaces.IPosition;
import idv.cjcat.stardustextended.geom.MotionData4D;

/**
 * Used along with the <code>Deflect</code> action.
 *
 * @see idv.cjcat.stardustextended.actions.Deflect
 */
public class Deflector extends StardustElement implements IPosition
{

    public var active : Boolean;
    public var bounce : Number;
    protected const position : Point = new Point();
    /**
     * Determines how slippery the surfaces are. A value of 1 (default) means that the surface is fully slippery,
     * a value of 0 means that particles will not slide on its surface at all.
     */
    public var slipperiness : Number;

    public function Deflector()
    {
        active = true;
        bounce = 0.8;
        slipperiness = 1;
    }

    public final function getMotionData4D(particle : Particle) : MotionData4D
    {
        if (active) {
            return calculateMotionData4D(particle);
        }
        return null;
    }

    /**
     * [Abstract Method] Returns a <code>MotionData4D</code> object representing the deflected position and velocity coordinates for a particle.
     * Returns null if no deflection occurred. A non-null value can trigger the <code>DeflectorTrigger</code> action trigger.
     * @param    particle
     * @return
     * @see idv.cjcat.stardustextended.actions.triggers.DeflectorTrigger
     */
    protected function calculateMotionData4D(particle : Particle) : MotionData4D
    {
        //abstract method
        return null;
    }

    /**
     * [Abstract Method] Sets the position of this Deflector.
     */
    public function setPosition(xc : Number, yc : Number) : void
    {
        throw new Error("This method must be overridden by subclasses");
    }

    /**
     * [Abstract Method] Gets the position of this Deflector.
     */
    public function getPosition() : Point
    {
        throw new Error("This method must be overridden by subclasses");
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "Deflector";
    }

    override public function getElementTypeXMLTag() : XML
    {
        return <deflectors/>;
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();
        xml.@active = active;
        xml.@bounce = bounce;
        xml.@slipperiness = slipperiness;
        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        if (xml.@active.length()) active = (xml.@active == "true");
        if (xml.@bounce.length()) bounce = parseFloat(xml.@bounce);
        if (xml.@slipperiness.length()) slipperiness = parseFloat(xml.@slipperiness);
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}