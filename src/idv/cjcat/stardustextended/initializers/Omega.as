package idv.cjcat.stardustextended.initializers
{

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Sets a particle's omega value (rotation speed), in degrees per second, based on the <code>random</code> property.
 */
public class Omega extends Initializer
{

    private var _random : Random;

    public function Omega(random : Random = null)
    {
        this.random = random;
    }

    override public function initialize(particle : Particle) : void
    {
        particle.omega = _random.random();
    }

    public function get random() : Random
    {
        return _random;
    }

    public function set random(value : Random) : void
    {
        if (!value) value = new UniformRandom(0, 0);
        _random = value;
    }


    //XML
    //------------------------------------------------------------------------------------------------

    override public function getRelatedObjects() : Vector.<StardustElement>
    {
        return new <StardustElement>[_random];
    }

    override public function getXMLTagName() : String
    {
        return "Omega";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();

        xml.@random = _random.name;

        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        if (xml.@random.length()) random = builder.getElementByName(xml.@random) as Random;
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}