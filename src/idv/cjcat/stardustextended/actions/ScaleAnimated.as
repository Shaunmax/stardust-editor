package idv.cjcat.stardustextended.actions
{

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Alters a particle's scale during its lifetime based on a gradient defined by ratio/scale stops.
 * Ratios are 0-255 where 0 = birth and 255 = death.
 */
public class ScaleAnimated extends Action
{
    public var numSteps:uint = 500;

    private var _ratios:Array;
    private var _scales:Array;
    private var scaleValues:Vector.<Number>;

    public function ScaleAnimated() : void
    {
        super();
        setGradient([0, 255], [1, 1]);
    }

    public function get ratios() : Array { return _ratios; }
    public function get scales() : Array { return _scales; }

    public function setGradient(ratios:Array, scales:Array) : void
    {
        _ratios = ratios;
        _scales = scales;
        scaleValues = new Vector.<Number>(numSteps, true);
        for (var i:int = 0; i < numSteps; i++)
        {
            // index i = (numSteps-1)*life/initLife; i=numSteps-1 at birth, i=0 at death
            // map to user ratio space: ratio=0 at birth, ratio=255 at death
            var gradRatio:Number = (numSteps - 1 - i) * 255.0 / (numSteps - 1);
            scaleValues[i] = lerpGradient(gradRatio);
        }
    }

    private function lerpGradient(ratio:Number) : Number
    {
        if (ratio <= _ratios[0]) return _scales[0];
        var last:int = _ratios.length - 1;
        if (ratio >= _ratios[last]) return _scales[last];
        for (var i:int = 0; i < last; i++)
        {
            if (ratio >= _ratios[i] && ratio <= _ratios[i + 1])
            {
                var t:Number = (ratio - _ratios[i]) / (_ratios[i + 1] - _ratios[i]);
                return _scales[i] + t * (_scales[i + 1] - _scales[i]);
            }
        }
        return _scales[0];
    }

    override public final function update(emitter:Emitter, particle:Particle, timeDelta:Number, currentTime:Number) : void
    {
        var idx:uint = (numSteps - 1) * particle.life / particle.initLife;
        particle.scale = scaleValues[idx];
    }

    // XML
    override public function getXMLTagName() : String { return "ScaleAnimated"; }

    override public function toXML() : XML
    {
        var xml:XML = super.toXML();
        var ratiosStr:String = "";
        var scalesStr:String = "";
        for (var i:int = 0; i < _ratios.length; i++)
        {
            ratiosStr += _ratios[i] + (i < _ratios.length - 1 ? "," : "");
            scalesStr += _scales[i] + (i < _scales.length - 1 ? "," : "");
        }
        xml.@ratios = ratiosStr;
        xml.@scales = scalesStr;
        return xml;
    }

    override public function parseXML(xml:XML, builder:XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);
        if (xml.@ratios.length() && xml.@scales.length())
            setGradient(xml.@ratios.toString().split(","), xml.@scales.toString().split(","));
    }
}
}
