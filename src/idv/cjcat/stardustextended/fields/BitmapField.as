package idv.cjcat.stardustextended.fields
{
import flash.display.BitmapData;
import flash.geom.Point;

import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;

/**
 * Vector field based on a BitmapData.
 *
 * <p>
 * For instance, if a pixel at (10, 12) has a color of "R = 100, G = 50, B = 0",
 * and the values of the <code>channelX</code> and <code>channelY</code> are 1 (red) and 2(green), respectively (blue is 4),
 * then the coordinate (10, 12) of the field corresponds to a <code>MotionData2D</code> object with X and Y components equal to
 * "max * (100 - 128) / 255" and "max * (50 - 128) / 255", respectively.
 * </p>
 *
 * <p>
 * This field can be combined with Perlin noise bitmaps to create turbulence vector fields.
 * </p>
 */
public class BitmapField extends Field
{

    /**
     * The X coordinate of the top-left coordinate.
     */
    public var x : Number;
    /**
     * The Y coordinate of the top-left coordinate.
     */
    public var y : Number;
    /**
     * The color channel for the horizontal direction.
     */
    public var channelX : uint;
    /**
     * The color channel for the vertical direction.
     */
    public var channelY : uint;
    /**
     * The maximum value of the returned <code>MotionData2D</code> object's components.
     */
    public var max : Number;
    /**
     * The horizontal scale of the bitmap.
     */
    public var scaleX : Number;
    /**
     * The vertical scale of the bitmap.
     */
    public var scaleY : Number;
    /**
     * Whether the bitmap tiles (i.e. repeats) infinitely.
     */
    public var tile : Boolean;

    private var _bitmapData : BitmapData;

    public function BitmapField(x : Number = 0, y : Number = 0, max : Number = 1, channelX : uint = 1, channelY : uint = 2)
    {
        this.x = x;
        this.y = y;
        this.max = max;
        this.channelX = channelX;
        this.channelY = channelY;
        this.scaleX = 1;
        this.scaleY = 1;
        this.tile = true;

        update();
    }

    public function update(bitmapData : BitmapData = null) : void
    {
        if (!bitmapData) bitmapData = new BitmapData(1, 1, false, 0x808080);
        _bitmapData = bitmapData;
    }

    override protected function calculateMotionData2D(particle : Particle) : MotionData2D
    {
        var px : Number = particle.x / scaleX;
        var py : Number = particle.y / scaleY;

        if (tile) {
            px = StardustMath.mod(px, _bitmapData.width);
            py = StardustMath.mod(py, _bitmapData.height);
        } else {
            if ((px < 0) || (px >= _bitmapData.width) || (py < 0) || (py >= _bitmapData.height)) {
                return null;
            }
        }
        var finalX : Number;
        var finalY : Number;
        var color : uint = _bitmapData.getPixel(int(px), int(py));
        switch (channelX) {
            case 1:
                finalX = 2 * ((((color & 0xFF0000) >> 16) / 255) - 0.5) * max;
                break;
            case 2:
                finalX = 2 * ((((color & 0x00FF00) >> 8) / 255) - 0.5) * max;
                break;
            case 4:
                finalX = 2 * (((color & 0x0000FF) / 255) - 0.5) * max;
                break;
        }

        switch (channelY) {
            case 1:
                finalY = 2 * ((((color & 0xFF0000) >> 16) / 255) - 0.5) * max;
                break;
            case 2:
                finalY = 2 * ((((color & 0x00FF00) >> 8) / 255) - 0.5) * max;
                break;
            case 4:
                finalY = 2 * (((color & 0x0000FF) / 255) - 0.5) * max;
                break;
        }

        return MotionData2DPool.get(finalX, finalY);
    }

    override public function setPosition(xc : Number, yc : Number) : void
    {
        x = xc;
        y = yc;
    }

    override public function getPosition() : Point
    {
        position.setTo(x, y);
        return position;
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "BitmapField";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();

        xml.@x = x;
        xml.@y = y;
        xml.@channelX = channelX;
        xml.@channelY = channelY;
        xml.@max = max;
        xml.@scaleX = scaleX;
        xml.@scaleY = scaleY;

        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        if (xml.@x.length()) x = parseFloat(xml.@x);
        if (xml.@y.length()) y = parseFloat(xml.@y);
        if (xml.@channelX.length()) channelX = parseFloat(xml.@channelX);
        if (xml.@channelY.length()) channelY = parseFloat(xml.@channelY);
        if (xml.@max.length()) max = parseFloat(xml.@max);
        if (xml.@scaleX.length()) scaleX = parseFloat(xml.@scaleX);
        if (xml.@scaleY.length()) scaleY = parseFloat(xml.@scaleY);
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}