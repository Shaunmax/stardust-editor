package idv.cjcat.stardustextended.actions
{
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Causes particles' rotation to align to their velocities.
 *
 * <p>
 * Default priority = -6;
 * </p>
 */
public class Oriented extends Action
{

    /**
     * How fast the particles align to their velocities, 0 means no alignment at all.
     */
    public var factor : Number;
    /**
     * The rotation angle offset in degrees.
     */
    public var offset : Number;
    protected var _timeDeltaOneSec : Number;

    public function Oriented(factor : Number = 1, offset : Number = 0)
    {
        priority = -6;

        this.factor = factor;
        this.offset = offset;
    }

    private var f : Number;
    private var os : Number;

    override public function preUpdate(emitter : Emitter, time : Number) : void
    {
        f = Math.pow(factor, 0.1 / time);
        os = offset + 90;
        _timeDeltaOneSec = (time + Emitter.timeStepCorrectionOffset) * 60;
        if (_timeDeltaOneSec > 1)
        {
            _timeDeltaOneSec = 1; // to prevent overalignment
        }
    }

    override public function update(emitter : Emitter, particle : Particle, timeDelta : Number, currentTime : Number) : void
    {
        var displacement : Number = (Math.atan2(particle.vy, particle.vx) * StardustMath.RADIAN_TO_DEGREE + os) - particle.rotation;
        particle.rotation += f * displacement * _timeDeltaOneSec;
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "Oriented";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();

        xml.@factor = factor;
        xml.@offset = offset;

        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        if (xml.@factor.length()) factor = parseFloat(xml.@factor);
        if (xml.@offset.length()) offset = parseFloat(xml.@offset);
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}