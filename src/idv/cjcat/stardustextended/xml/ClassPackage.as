package idv.cjcat.stardustextended.xml
{

/**
 * An <code>XMLBuilder</code> object needs to know the mapping between an XML tag's name and an actual class.
 * This class encapsulates multiple classes for the <code>XMLBuilder.registerClassesFromClassPackage()</code> method
 * to register multiple classes (i.e. build the mapping relations).
 */
public class ClassPackage
{
    protected var classes : Vector.<Class>;

    public function ClassPackage()
    {
        classes = new Vector.<Class>();
        populateClasses();
    }

    /**
     * Returns an array of classes.
     * @return
     */
    public final function getClasses() : Vector.<Class>
    {
        return classes.concat();
    }

    /**
     * [Abstract Method] Populates classes.
     */
    protected function populateClasses() : void
    {

    }
}
}