package idv.cjcat.stardustextended.flashdisplay.handlers
{
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.ColorTransform;
import flash.geom.Matrix;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.handlers.ParticleHandler;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Similar to the <code>BitmapHandler</code>, but uses only one display object for drawing the target bitmap.
 *
 * @see idv.cjcat.stardustextended.flashdisplay.handlers.BitmapHandler
 */
public class SingularBitmapHandler extends ParticleHandler
{

    public var displayObject : DisplayObject;
    public var targetBitmapData : BitmapData;
    public var blendMode : String;

    public function SingularBitmapHandler(displayObject : DisplayObject = null, targetBitmapData : BitmapData = null, blendMode : String = "normal")
    {
        this.displayObject = displayObject;
        this.targetBitmapData = targetBitmapData;
        this.blendMode = blendMode;
    }

    private var mat : Matrix = new Matrix();
    private var colorTransform : ColorTransform = new ColorTransform(1, 1, 1);

    override public function stepEnd(emitter : Emitter, particles : Vector.<Particle>, time : Number) : void
    {
        for each (var particle : Particle in particles) {
            mat.identity();
            mat.scale(particle.scale, particle.scale);
            mat.rotate(particle.rotation * StardustMath.DEGREE_TO_RADIAN);
            mat.translate(particle.x, particle.y);

            colorTransform.alphaMultiplier = particle.alpha;

            targetBitmapData.draw(displayObject, mat, colorTransform, blendMode);
        }
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "SingularBitmapHandler";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();

        xml.@blendMode = blendMode;

        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        if (xml.@blendMode.length()) blendMode = xml.@blendMode;
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}