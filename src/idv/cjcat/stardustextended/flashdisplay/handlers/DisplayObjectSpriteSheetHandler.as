package idv.cjcat.stardustextended.flashdisplay.handlers
{

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.geom.ColorTransform;

import idv.cjcat.stardustextended.emitters.Emitter;

import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.flashdisplay.particletargets.CenteredBitmap;
import idv.cjcat.stardustextended.flashdisplay.utils.DisplayObjectPool;
import idv.cjcat.stardustextended.handlers.ISpriteSheetHandler;

public class DisplayObjectSpriteSheetHandler extends DisplayObjectHandler implements ISpriteSheetHandler
{
    private var _spriteSheetStartAtRandomFrame : Boolean;
    private var _smoothing : Boolean;
    private var _spriteSheetAnimationSpeed : Number;
    private var _pool : DisplayObjectPool;
    private var _totalFrames : uint;
    private var _isSpriteSheet : Boolean;
    private var _images : Vector.<BitmapData>;

    public function DisplayObjectSpriteSheetHandler(container : DisplayObjectContainer = null,
                                                    blendMode : String = "normal",
                                                    addChildMode : int = 0)
    {
        super(container, blendMode, addChildMode);
        _pool = new DisplayObjectPool();
        _pool.reset(CenteredBitmap, null);
    }

    override public function stepEnd(emitter : Emitter, particles : Vector.<Particle>, time : Number) : void
    {
        super.stepEnd(emitter, particles, time);
        for each (var particle : Particle in particles) {
            var bmp : CenteredBitmap = CenteredBitmap(particle.target);
            if (_isSpriteSheet && _spriteSheetAnimationSpeed > 0) {
                var currFrame : uint = particle.currentAnimationFrame;
                var nextFrame : uint = (currFrame + time) % _totalFrames;
                var nextImageIndex : uint = uint(nextFrame / _spriteSheetAnimationSpeed);
                var currImageIndex : uint = uint(currFrame / _spriteSheetAnimationSpeed);
                if (nextImageIndex != currImageIndex) {
                    bmp.bitmapData = _images[nextImageIndex];
                    bmp.smoothing = _smoothing;
                }
                particle.currentAnimationFrame = nextFrame;
            }
            // optimize this if possible
            bmp.transform.colorTransform = new ColorTransform(particle.colorR, particle.colorG, particle.colorB, particle.alpha);
        }
    }

    override public function particleAdded(particle : Particle) : void
    {
        var bmp : CenteredBitmap = CenteredBitmap(_pool.get());
        particle.target = bmp;

        if (_isSpriteSheet) {
            makeSpriteSheetCache();
            var currFrame : uint = 0;
            if (_spriteSheetStartAtRandomFrame) {
                currFrame = Math.random() * _totalFrames;
            }
            if (_spriteSheetAnimationSpeed > 0) {
                bmp.bitmapData = _images[uint(currFrame / _spriteSheetAnimationSpeed)];
            }
            else {
                bmp.bitmapData = _images[currFrame];
            }
            particle.currentAnimationFrame = currFrame;
        }
        else {
            bmp.bitmapData = _images[0];
        }
        bmp.smoothing = _smoothing;

        bmp.transform.colorTransform = new ColorTransform(particle.colorR, particle.colorG, particle.colorB, particle.alpha);

        super.particleAdded(particle);
    }

    override public function particleRemoved(particle : Particle) : void
    {
        super.particleRemoved(particle);
        var obj : DisplayObject = DisplayObject(particle.target);
        if (obj) {
            _pool.recycle(obj);
        }
    }

    public function setImages(images : Vector.<BitmapData>) : void
    {
        _images = images;
        makeSpriteSheetCache();
    }

    public function set spriteSheetAnimationSpeed(spriteSheetAnimationSpeed : uint) : void
    {
        _spriteSheetAnimationSpeed = spriteSheetAnimationSpeed;
        makeSpriteSheetCache();
    }

    public function get spriteSheetAnimationSpeed() : uint
    {
        return _spriteSheetAnimationSpeed;
    }

    public function set spriteSheetStartAtRandomFrame(spriteSheetStartAtRandomFrame : Boolean) : void
    {
        _spriteSheetStartAtRandomFrame = spriteSheetStartAtRandomFrame;
    }

    public function get spriteSheetStartAtRandomFrame() : Boolean
    {
        return _spriteSheetStartAtRandomFrame;
    }

    public function get isSpriteSheet() : Boolean
    {
        return _isSpriteSheet;
    }

    public function get smoothing() : Boolean
    {
        return _smoothing;
    }

    public function set smoothing(value : Boolean) : void
    {
        _smoothing = value;
    }

    private function makeSpriteSheetCache() : void
    {
        if (_images == null) {
            return;
        }
        _isSpriteSheet = _images.length > 1;
        var numStates : uint = _spriteSheetAnimationSpeed;
        if (numStates == 0) {
            numStates = 1; // frame can only change at particle birth
        }
        _totalFrames = numStates * _images.length;
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "DisplayObjectSpriteSheetHandler";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();
        xml.@spriteSheetAnimationSpeed = _spriteSheetAnimationSpeed;
        xml.@spriteSheetStartAtRandomFrame = _spriteSheetStartAtRandomFrame;
        xml.@smoothing = _smoothing;
        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);
        _spriteSheetAnimationSpeed = xml.@spriteSheetAnimationSpeed;
        _spriteSheetStartAtRandomFrame = (xml.@spriteSheetStartAtRandomFrame == "true");
        _smoothing = (xml.@smoothing == "true");
        makeSpriteSheetCache();
    }

    //------------------------------------------------------------------------------------------------
}
}
