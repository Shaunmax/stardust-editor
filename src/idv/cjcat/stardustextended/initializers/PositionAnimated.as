package idv.cjcat.stardustextended.initializers
{

import flash.geom.Point;
import flash.net.registerClassAlias;
import flash.utils.ByteArray;

import idv.cjcat.stardustextended.StardustElement;

import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.actions.IZoneContainer;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;
import idv.cjcat.stardustextended.utils.Base64;
import idv.cjcat.stardustextended.zones.RectZone;
import idv.cjcat.stardustextended.zones.Zone;
import idv.cjcat.stardustextended.zones.ZoneCollection;

/**
 * Sets a particle's initial position based on the zone plus on a value in the positions array.
 * The current position is: positions[currentFrame] + random point in the zone.
 */
public class PositionAnimated extends Initializer implements IZoneContainer
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

    public var inheritVelocity : Boolean = false;
    public var positions : Vector.<Point>;
    private var prevPos : uint;
    private var currentPos : uint;

    public function PositionAnimated(zones : Vector.<Zone> = null)
    {
        zoneCollection = new ZoneCollection();
        if (zones) {
            zoneCollection.zones = zones;
        }
        else {
            zoneCollection.zones.push(new RectZone())
        }
    }

    override public function doInitialize(particles : Vector.<Particle>, currentTime : Number) : void
    {
        if (positions) {
            currentPos = currentTime % positions.length;
            prevPos = (currentPos > 0) ? currentPos - 1 : positions.length - 1;
        }
        super.doInitialize(particles, currentTime);
    }

    override public function initialize(particle : Particle) : void
    {
        var md2D : MotionData2D = zoneCollection.getRandomPointInZones();
        if (md2D) {
            particle.x = md2D.x;
            particle.y = md2D.y;

            if (positions) {
                particle.x = md2D.x + positions[currentPos].x;
                particle.y = md2D.y + positions[currentPos].y;

                if (inheritVelocity) {
                    particle.vx += positions[currentPos].x - positions[prevPos].x;
                    particle.vy += positions[currentPos].y - positions[prevPos].y;
                }
            }
            else {
                particle.x = md2D.x;
                particle.y = md2D.y;
            }
            MotionData2DPool.recycle(md2D);
        }
    }

    public function get currentPosition() : Point
    {
        if (positions) {
            return positions[currentPos];
        }
        return null;
    }


    //XML
    //------------------------------------------------------------------------------------------------
    override public function getRelatedObjects() : Vector.<StardustElement>
    {
        return Vector.<StardustElement>(zoneCollection.zones);
    }

    override public function getXMLTagName() : String
    {
        return "PositionAnimated";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();
        zoneCollection.addToStardustXML(xml);
        xml.@inheritVelocity = inheritVelocity;
        if (positions && positions.length > 0) {
            registerClassAlias("String", String);
            registerClassAlias("Point", Point);
            registerClassAlias("VecPoint", Vector.<Point> as Class);
            var ba : ByteArray = new ByteArray();
            ba.writeObject(positions);
            xml.@positions = Base64.encode(ba);
        }
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
        if (xml.@positions.length()) {
            registerClassAlias("String", String);
            registerClassAlias("Point", Point);
            registerClassAlias("VecPoint", Vector.<Point> as Class);
            const ba : ByteArray = Base64.decode(xml.@positions);
            ba.position = 0;
            positions = ba.readObject();
        }
        if (xml.@inheritVelocity.length()) {
            inheritVelocity = (xml.@inheritVelocity == "true");
        }
    }
}
}