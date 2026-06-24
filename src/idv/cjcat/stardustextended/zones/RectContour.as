package idv.cjcat.stardustextended.zones
{

import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Rectangular contour.
 */
public class RectContour extends Composite
{

    private var _virtualThickness : Number;

    private var _width : Number;
    private var _height : Number;

    private var _line1 : Line;
    private var _line2 : Line;
    private var _line3 : Line;
    private var _line4 : Line;

    public function RectContour(x : Number = 0, y : Number = 0, _width : Number = 200, _height : Number = 100)
    {
        _line1 = new Line();
        _line2 = new Line();
        _line3 = new Line();
        _line4 = new Line();

        addZone(_line1);
        addZone(_line2);
        addZone(_line3);
        addZone(_line4);

        virtualThickness = 1;

        _x = x;
        _y = y;
        width = _width;
        height = _height;

        updateArea();
    }

    override public function getPoint() : MotionData2D
    {
        var md2D : MotionData2D = super.getPoint();
        if (_rotation != 0) {
            var originalX : Number = md2D.x;
            md2D.x = originalX * angleCos - md2D.y * angleSin;
            md2D.y = originalX * angleSin + md2D.y * angleCos;
        }
        md2D.x = _x + md2D.x;
        md2D.y = _y + md2D.y;
        return md2D;
    }

    public function get width() : Number
    {
        return _width;
    }

    public function set width(value : Number) : void
    {
        _width = value;
        updateContour();
        updateArea();
    }

    public function get height() : Number
    {
        return _height;
    }

    public function set height(value : Number) : void
    {
        _height = value;
        updateContour();
        updateArea();
    }

    public function get virtualThickness() : Number
    {
        return _virtualThickness;
    }

    public function set virtualThickness(value : Number) : void
    {
        _virtualThickness = value;
        _line1.virtualThickness = value;
        _line2.virtualThickness = value;
        _line3.virtualThickness = value;
        _line4.virtualThickness = value;
        updateArea();
    }

    private function updateContour() : void
    {
        _line1.x = 0;
        _line1.y = 0;
        _line1.x2 = width;
        _line1.y2 = 0;

        _line2.x = 0;
        _line2.y = height;
        _line2.x2 = width;
        _line2.y2 = height;

        _line3.x = 0;
        _line3.y = 0;
        _line3.x2 = 0;
        _line3.y2 = height;

        _line4.x = width;
        _line4.y = 0;
        _line4.x2 = width;
        _line4.y2 = height;
    }

    override protected function updateArea() : void
    {
        area = 0;
        for each (var line : Line in zones) {
            area += line.getArea();
        }
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "RectContour";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();
        delete xml.zones;
        xml.@virtualThickness = virtualThickness;
        xml.@x = _x;
        xml.@y = _y;
        xml.@width = width;
        xml.@height = height;

        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);
        // parsing removes all zones, so we add them back
        addZone(_line1);
        addZone(_line2);
        addZone(_line3);
        addZone(_line4);

        if (xml.@virtualThickness.length()) virtualThickness = parseFloat(xml.@virtualThickness);

        if (xml.@x.length()) x = parseFloat(xml.@x);
        if (xml.@y.length()) y = parseFloat(xml.@y);
        if (xml.@width.length()) width = parseFloat(xml.@width);
        if (xml.@height.length()) height = parseFloat(xml.@height);
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}