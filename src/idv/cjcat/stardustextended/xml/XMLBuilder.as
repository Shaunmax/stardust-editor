package idv.cjcat.stardustextended.xml
{
import flash.errors.IllegalOperationError;
import flash.utils.Dictionary;

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.Stardust;

/**
 * <code>XMLBuilder</code> can generate Stardust elements' XML representations and reconstruct elements from existing XML data.
 *
 * <p>
 * Every <code>StardustElement</code> objects can generate its XML representation through the <code>StardustElement.toXML()</code> method.
 * And they can reconstruct configurations from existing XML data through the <code>StardustElement.parseXML()</code> method.
 * </p>
 */
public class XMLBuilder
{

    //XML building
    //------------------------------------------------------------------------------------------------

    /**
     * Generate the XML representation of an Stardust element.
     *
     * <p>
     * All related elements' would be included in the XML representation.
     * </p>
     * @param    rootElement
     * @return
     */
    public static function buildXML(rootElement : StardustElement) : XML
    {
        const root : XML = <StardustParticleSystem/>;
        root.@version = Stardust.VERSION.toString();

        const relatedElements : Dictionary = new Dictionary();
        traverseRelatedObjects(rootElement, relatedElements);

        const relatedElementsArray : Vector.<StardustElement> = new Vector.<StardustElement>();
        var element : StardustElement;
        for each (element in relatedElements) {
            relatedElementsArray.push(element);
        }
        relatedElementsArray.sort(elementTypeSorter);

        for each (element in relatedElementsArray) {
            var elementXML : XML = element.toXML();
            var typeXML : XML = element.getElementTypeXMLTag();

            if (root[typeXML.name()].length() == 0) root.appendChild(typeXML);
            root[typeXML.name()].appendChild(elementXML);
        }

        return root;
    }

    private static function elementTypeSorter(e1 : StardustElement, e2 : StardustElement) : Number
    {
        if (e1.getXMLTagName() > e2.getXMLTagName()) return 1;
        else if (e1.getXMLTagName() < e2.getXMLTagName())  return -1;
        if (e1.name > e2.name) return 1;
        return -1;
    }

    private static function traverseRelatedObjects(element : StardustElement, relatedElements : Dictionary) : void
    {
        if (!element) return;

        if (relatedElements[element.name] != undefined) {
            if (relatedElements[element.name] != element) {
                throw new Error("Duplicate element name: " + element.name + " " + relatedElements[element.name]);
            }
        } else {
            relatedElements[element.name] = element;
        }
        for each (var e : StardustElement in element.getRelatedObjects()) {
            traverseRelatedObjects(e, relatedElements);
        }
    }

    //------------------------------------------------------------------------------------------------
    //end of XML building


    private var elementClasses : Dictionary;
    private var elements : Dictionary;

    public function XMLBuilder()
    {
        elementClasses = new Dictionary();
        elements = new Dictionary();
    }

    /**
     * To use <code>XMLBuilder</code> with your custom subclasses of Stardust elements,
     * you must register your class and XML tag name first.
     *
     * <p>
     * For example, if you register the <code>MyAction</code> class with XML tag name "HelloWorld",
     * <code>XMLBuilder</code> knows you are referring to the <code>MyAction</code> class when a &ltHelloWorld&gt tag
     * appears in the XML representation.
     * </p>
     * @param    elementClass
     */
    public function registerClass(elementClass : Class) : void
    {
        var element : StardustElement = (new elementClass() as StardustElement);
        if (!element) {
            throw new IllegalOperationError(elementClass + " is not a subclass of the StardustElement class.");
        }
        const tagName : String = element.getXMLTagName();
        if (elementClasses[tagName] != undefined) {
            throw new IllegalOperationError("This element class name is already registered: " + element.getXMLTagName());
        }
        elementClasses[tagName] = elementClass;
    }

    /**
     * Registers multiple classes.
     * @param    classes
     */
    public function registerClasses(classes : Vector.<Class>) : void
    {
        for each (var c : Class in classes) {
            registerClass(c);
        }
    }

    /**
     * Registers multiple classes from a <code>ClassPackage</code> object.
     * @param    classPackage
     */
    public function registerClassesFromClassPackage(classPackage : ClassPackage) : void
    {
        registerClasses(classPackage.getClasses());
    }

    /**
     * Undos the XML tag name registration.
     * @param    name
     */
    public function unregisterClass(name : String) : void
    {
        delete elementClasses[name];
    }

    /**
     * After reconstructing elements through the <code>buildFromXML()</code> method,
     * reconstructed elements can be extracted through this method.
     *
     * <p>
     * Each Stardust element has a name; this name is used to identify elements.
     * </p>
     * @param name
     * @return
     */
    public function getElementByName(name : String) : StardustElement
    {
        if (elements[name] == undefined) {
            throw new IllegalOperationError("Element not found: " + name);
        }
        return elements[name];
    }

    public function getElementsByClass(cl : Class) : Vector.<StardustElement>
    {
        var ret : Vector.<StardustElement> = new Vector.<StardustElement>();
        for (var key : * in elements) {
            if (elements[key] is cl) {
                ret.push(elements[key]);
            }
        }
        return ret;
    }

    /**
     * Reconstructs elements from XML representations.
     *
     * <p>
     * After calling this method, you may extract constructed elements through the <code>getElementByName()</code> method.
     * </p>
     * @param    xml
     */
    public function buildFromXML(xml : XML) : void
    {
        elements = new Dictionary();

        var element : StardustElement;
        var node : XML;
        for each (node in xml.*.*) {
            try {
                var NodeClass : Class = elementClasses[node.name().toString()];
                element = StardustElement(new NodeClass());
            }
            catch (err : TypeError) {
                throw new Error("Unable to instantiate class " + node.name().toString() + ". Perhaps you forgot to " +
                                "call XMLBuilder.registerClass for this type? Original error: " + err.toString());
            }
            if (elements[node.@name] != undefined) {
                throw new Error("Duplicate element name: " + node.@name + " " + element.name);
            }
            elements[node.@name.toString()] = element;
        }
        for each (node in xml.*.*) {
            element = StardustElement(elements[node.@name.toString()]);
            element.parseXML(node, this);
        }
        for each (var stardustElement : StardustElement in elements) {
            stardustElement.onXMLInitComplete();
        }
    }
}
}