package idv.cjcat.stardustextended.flashdisplay.initializers
{
import idv.cjcat.stardustextended.initializers.Initializer;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.flashdisplay.utils.construct;

/**
 * Assigns a display object to the <code>target</code> properties of a particle.
 * This information can be visualized by <code>DisplayObjectRenderer</code> and <code>BitmapRenderer</code>.
 *
 * <p>
 * Default priority = 1;
 * </p>
 *
 */
public class DisplayObjectClass extends Initializer
{

    public var displayObjectClass : Class;
    public var constructorParams : Array;

    public function DisplayObjectClass(displayObjectClass : Class = null, constructorParams : Array = null)
    {
        priority = 1;

        this.displayObjectClass = displayObjectClass;
        this.constructorParams = constructorParams;
    }

    override public function initialize(p : Particle) : void
    {
        if (!displayObjectClass) return;
        p.target = construct(displayObjectClass, constructorParams);
    }


    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "DisplayObjectClass";
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}