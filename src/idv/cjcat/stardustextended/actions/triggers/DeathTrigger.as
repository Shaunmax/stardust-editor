package idv.cjcat.stardustextended.actions.triggers
{
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * This action trigger return true if a particle is dead.
 */
public class DeathTrigger extends Trigger
{

    override public final function testTrigger(emitter : Emitter, particle : Particle, time : Number) : Boolean
    {
        return particle.isDead;
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "DeathTrigger";
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}