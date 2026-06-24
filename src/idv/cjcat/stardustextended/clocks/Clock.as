package idv.cjcat.stardustextended.clocks
{
import idv.cjcat.stardustextended.StardustElement;

/**
 * A clock is used by an emitter to determine how frequently particles are created.
 *
 * @see idv.cjcat.stardustextended.emitters.Emitter
 */
public class Clock extends StardustElement
{

    public function Clock()
    {
    }

    /**
     * [Template Method] On each <code>Emitter.step()</code> call, this method is called.
     *
     * The returned value tells the emitter how many particles it should create.
     *
     * @param time The timespan the emitter emitter's step.
     * @return
     */
    public function getTicks(time : Number) : int
    {
        return 0;
    }

    public function reset() : void
    {
        // override it if needed
    }


    //XML
    //------------------------------------------------------------------------------------------------

    override public function getElementTypeXMLTag() : XML
    {
        return <clocks/>;
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}