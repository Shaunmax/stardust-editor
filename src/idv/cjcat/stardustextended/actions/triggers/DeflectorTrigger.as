package idv.cjcat.stardustextended.actions.triggers
{

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.deflectors.Deflector;

public class DeflectorTrigger extends Trigger
{

    public var deflector : Deflector;

    public function DeflectorTrigger(deflector : Deflector = null)
    {
        this.deflector = deflector;
    }

    override public function testTrigger(emitter : Emitter, particle : Particle, time : Number) : Boolean
    {
        return Boolean(particle.dictionary[deflector]);
    }


    //XML
    //------------------------------------------------------------------------------------------------

    override public function getRelatedObjects() : Vector.<StardustElement>
    {
        return new <StardustElement>[deflector];
    }

    override public function getXMLTagName() : String
    {
        return "DeflectorTrigger";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();
        if (deflector) xml.@deflector = deflector.name;
        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        if (xml.@deflector.length()) deflector = builder.getElementByName(xml.@deflector) as Deflector;
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}