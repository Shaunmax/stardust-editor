package idv.cjcat.stardustextended.actions.triggers
{

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.actions.IZoneContainer;
import idv.cjcat.stardustextended.zones.RectZone;
import idv.cjcat.stardustextended.zones.Zone;
import idv.cjcat.stardustextended.zones.ZoneCollection;

/**
 * This trigger is triggered when a particle is contained in a zone.
 */
public class ZoneTrigger extends Trigger implements IZoneContainer
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

    public function ZoneTrigger(zones : Vector.<Zone> = null)
    {
        zoneCollection = new ZoneCollection();
        if (zones) {
            zoneCollection.zones = zones;
        }
        else {
            zoneCollection.zones.push(new RectZone())
        }
    }


    override public function testTrigger(emitter : Emitter, particle : Particle, time : Number) : Boolean
    {
        return zoneCollection.contains(particle.x, particle.y);
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getRelatedObjects() : Vector.<StardustElement>
    {
        return Vector.<StardustElement>(zoneCollection.zones);
    }

    override public function getXMLTagName() : String
    {
        return "ZoneTrigger";
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
            zoneCollection.zones = Vector.<Zone>(builder.getElementByName(xml.@zone) as Zone);
        }
        else {
            zoneCollection.parseFromStardustXML(xml, builder);
        }
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}