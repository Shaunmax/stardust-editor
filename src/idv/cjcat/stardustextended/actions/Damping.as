package idv.cjcat.stardustextended.actions
{

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Causes particles to decelerate.
 * Its recommended to use Accelerate with <0 values instead of this class.
 * <p>
 * Default priority = -1;
 * </p>
 */
public class Damping extends Action
{

    /**
     * In each emitter second, each particle's velocity is multiplied by this value.
     *
     * <p>
     * A value of 0 denotes no damping at all, and a value of 1 means all particles will not move at all.
     * </p>
     */
    public var damping : Number;

    public function Damping(damping : Number = 0.05)
    {
        priority = -1;

        this.damping = damping;
    }


    override public function preUpdate(emitter : Emitter, time : Number) : void
    {
        damp = 1;
        if (damping) damp = Math.pow(1 - damping, time * 60);
    }

    private var damp : Number;

    override public function update(emitter : Emitter, particle : Particle, timeDelta : Number, currentTime : Number) : void
    {
        particle.vx *= damp;
        particle.vy *= damp;
    }


    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "Damping";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();

        xml.@damping = damping;

        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        if (xml.@damping.length()) damping = parseFloat(xml.@damping);
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}