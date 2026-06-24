package idv.cjcat.stardustextended.initializers
{

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.actions.IZoneContainer;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;
import idv.cjcat.stardustextended.zones.SinglePoint;
import idv.cjcat.stardustextended.zones.Zone;
import idv.cjcat.stardustextended.zones.ZoneCollection;

/**
 * Sets a particle's velocity based on the <code>zone</code> property.
 *
 * <p>
 * A particle's velocity is determined by a random point in the zone.
 * (The vector pointing from the origin to the random point).
 * </p>
 */
public class Velocity extends Initializer implements IZoneContainer
{

    protected var zoneCollection : ZoneCollection;

    public function get zones() : Vector.<Zone>
    {
        return zoneCollection.zones;
    }

    public function set zones(value : Vector.<Zone>) : void
    {
        zoneCollection.zones = value;
    }

    public function Velocity(zones : Vector.<Zone> = null)
    {
        zoneCollection = new ZoneCollection();
        if (zones) {
            zoneCollection.zones = zones;
        }
        else {
            zoneCollection.zones.push(new SinglePoint(0, 0));
        }
    }

    override public function initialize(particle : Particle) : void
    {
        var md2D : MotionData2D = zoneCollection.getRandomPointInZones();
        if (md2D) {
            particle.vx += md2D.x;
            particle.vy += md2D.y;
            MotionData2DPool.recycle(md2D);
        }
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getRelatedObjects() :  Vector.<StardustElement>
    {
        return Vector.<StardustElement>(zoneCollection.zones);
    }

    override public function getXMLTagName() : String
    {
        return "Velocity";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();
        zoneCollection.addToStardustXML(xml);
        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);
        if (xml.@zone.length()) {
            trace("WARNING: the simulation contains a deprecated property 'zone' for " + getXMLTagName());
            zoneCollection.zones = Vector.<Zone>([Zone(builder.getElementByName(xml.@zone))]);
        }
        else {
            zoneCollection.parseFromStardustXML(xml, builder);
        }
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}