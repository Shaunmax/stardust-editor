package idv.cjcat.stardustextended.actions
{
import idv.cjcat.stardustextended.actions.Action;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Limits a particle's maximum traveling speed.
 */
public class SpeedLimit extends Action
{

    /**
     * The speed limit.
     */
    public var limit : Number;

    public function SpeedLimit(limit : Number = Number.MAX_VALUE)
    {
        this.limit = limit;
    }

    override public function preUpdate(emitter : Emitter, time : Number) : void
    {
        limitSQ = limit * limit;
    }

    private var speedSQ : Number;
    private var limitSQ : Number;
    private var factor : Number;

    override public function update(emitter : Emitter, particle : Particle, timeDelta : Number, currentTime : Number) : void
    {
        speedSQ = particle.vx * particle.vx + particle.vy * particle.vy;
        if (speedSQ > limitSQ) {
            factor = limit / Math.sqrt(speedSQ);
            particle.vx *= factor;
            particle.vy *= factor;
        }
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "SpeedLimit";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();

        xml.@limit = limit;

        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        if (xml.@limit.length()) limit = parseFloat(xml.@limit);
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}