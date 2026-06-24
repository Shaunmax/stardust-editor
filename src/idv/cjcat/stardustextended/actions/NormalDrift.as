package idv.cjcat.stardustextended.actions
{

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;

/**
 * Applies acceleration normal to a particle's velocity to the particle.
 */
public class NormalDrift extends Action
{

    /**
     * Whether the particles acceleration is divided by their masses before applied to them, true by default.
     * When set to true, it simulates a gravity that applies equal acceleration on all particles.
     */
    public var massless : Boolean;
    protected var _timeDeltaOneSec : Number;
    private var _random : Random;
    private var _max : Number;

    public function NormalDrift(max : Number = 1, random : Random = null)
    {
        this.massless = true;
        this.random = random;
        this.max = max;
    }

    /**
     * The acceleration ranges from -max to max.
     */
    public function get max() : Number
    {
        return _max;
    }

    public function set max(value : Number) : void
    {
        _max = value;
        if (_random && !isNaN(value)) {
            _random.setRange(-_max, _max);
        }
    }

    /**
     * The random object used to generate a random number for the acceleration in the range [-max, max], uniform random by default.
     * You don't have to set the random object's range. The range is automatically set each time before the random generation.
     */
    public function get random() : Random
    {
        return _random;
    }

    public function set random(value : Random) : void
    {
        if (!value) value = new UniformRandom();
        _random = value;
        if (!isNaN(_max)) {
            _random.setRange(-_max, _max);
        }
    }

    override public function preUpdate(emitter : Emitter, time : Number) : void
    {
        _timeDeltaOneSec = time * 60;
    }

    override public function update(emitter : Emitter, particle : Particle, timeDelta : Number, currentTime : Number) : void
    {
        var v : Vec2D = Vec2DPool.get(particle.vy, particle.vx);
        v.length = _random.random();
        if (!massless) v.length /= particle.mass;
        particle.vx += v.x * _timeDeltaOneSec;
        particle.vy += v.y * _timeDeltaOneSec;
        Vec2DPool.recycle(v);
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getRelatedObjects() : Vector.<StardustElement>
    {
        return new <StardustElement>[_random];
    }

    override public function getXMLTagName() : String
    {
        return "NormalDrift";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();

        xml.@massless = massless;
        xml.@max = _max;
        xml.@random = _random.name;

        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        if (xml.@massless.length()) massless = (xml.@massless == "true");
        if (xml.@max.length()) max = parseFloat(xml.@max);
        if (xml.@random.length()) random = builder.getElementByName(xml.@random) as Random;
    }

    //------------------------------------------------------------------------------------------------
    //end of XML

}
}