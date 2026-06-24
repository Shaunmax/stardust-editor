package idv.cjcat.stardustextended.handlers
{
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.StardustElement;

/**
 * A particle handler is assigned to a particle by using the <code>Handler</code> initializer.
 * A handler monitors the beginning of an emitter step, the end of an emitter step,
 * the adding of a new particle, and the removal of a dead particle.
 * Also, the <code>readParticle()<code> method is used to read data out of <code>Particle</code>
 * objects when each particle is completely updated by actions.
 */
public class ParticleHandler extends StardustElement
{
    public function reset() : void
    {

    }
    /**
     * [Abstract Method] Invoked when each emitter step begins.
     * @param    emitter
     * @param    particles
     * @param    time
     */
    public function stepBegin(emitter : Emitter, particles : Vector.<Particle>, time : Number) : void
    {

    }

    /**
     * [Abstract Method] Invoked when each emitter step ends. Particles are at their final position and ready to be
     * rendered.
     * @param    emitter
     * @param    particles
     * @param    time
     */
    public function stepEnd(emitter : Emitter, particles : Vector.<Particle>, time : Number) : void
    {

    }

    /**
     * [Abstract Method] Invoked for each particle added.
     * Handle particle creation in this method.
     * @param    particle
     */
    public function particleAdded(particle : Particle) : void
    {

    }

    /**
     * [Abstract Method] Invoked for each particle removed.
     * Handle particle removal in this method.
     * @param    particle
     */
    public function particleRemoved(particle : Particle) : void
    {

    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "ParticleHandler";
    }

    override public function getElementTypeXMLTag() : XML
    {
        return <handlers/>;
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}