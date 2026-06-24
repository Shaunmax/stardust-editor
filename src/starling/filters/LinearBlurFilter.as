package starling.filters
{
    import starling.rendering.FilterEffect;
    import starling.rendering.Painter;
    import starling.textures.Texture;

    /**
     * LinearBlurFilter works exactly like BlurFilter — blurX controls horizontal extent,
     * blurY controls vertical extent — except the <code>angle</code> property rotates the
     * entire blur coordinate system.
     *
     * <p>At angle=0 it is identical to BlurFilter. Rotating it lets you aim the blur in any
     * direction without changing the blur amounts.</p>
     *
     * <ul>
     *   <li><b>blurX</b>  – blur extent along the primary (rotated) axis, in pixels.</li>
     *   <li><b>blurY</b>  – blur extent along the perpendicular axis, in pixels. When 0 only
     *       one pass is used.</li>
     *   <li><b>angle</b>  – rotation of the blur axes in degrees (0 = horizontal).</li>
     *   <li><b>samples</b> – samples per pass; set at construction time.</li>
     * </ul>
     *
     * <listing version="3.0">
     * // Identical to BlurFilter(20, 5):
     * sprite.filter = new LinearBlurFilter(20, 5);
     *
     * // Same blur rotated 45 degrees:
     * sprite.filter = new LinearBlurFilter(20, 5, 45);
     *
     * // Pure directional motion blur at 45 degrees:
     * sprite.filter = new LinearBlurFilter(20, 0, 45);
     *
     * // Drive from velocity each frame:
     * filter.angle = Math.atan2(dy, dx) * 180 / Math.PI;
     * filter.blurX = speed * 0.4;
     * </listing>
     */
    public class LinearBlurFilter extends FragmentFilter
    {
        private static const DEG2RAD:Number = Math.PI / 180;

        private var _blurX:Number;
        private var _blurY:Number;
        private var _angle:Number;
        private var _samples:int;

        /**
         * @param blurX   Blur along the primary (rotated) axis in pixels.
         * @param blurY   Blur along the perpendicular axis in pixels. Default 0 (single pass).
         * @param angle   Rotation of the blur axes in degrees.
         * @param samples Samples per pass (quality vs. GPU cost).
         */
        public function LinearBlurFilter(blurX:Number = 10, blurY:Number = 0,
                                         angle:Number = 0, samples:int = 8)
        {
            _blurX   = blurX;
            _blurY   = blurY;
            _angle   = angle;
            _samples = samples;
            updatePadding();
        }

        /** @private */
        override protected function createEffect():FilterEffect
        {
            return new LinearBlurEffect(_samples);
        }

        /** @private
         *  Two passes when blurY > 0: pass 1 along angle, pass 2 perpendicular. */
        override public function get numPasses():int
        {
            return (_blurY > 0) ? 2 : 1;
        }

        /** @private */
        override public function process(painter:Painter, helper:IFilterHelper,
                                         input0:Texture = null, input1:Texture = null,
                                         input2:Texture = null, input3:Texture = null):Texture
        {
            // Access via the protected getter — this triggers createEffect() on first call,
            // ensuring _effect is never null when we set per-pass properties below.
            var e:LinearBlurEffect = effect as LinearBlurEffect;

            var rad:Number  = _angle * DEG2RAD;
            var cosA:Number = Math.cos(rad);
            var sinA:Number = Math.sin(rad);

            var outTexture:Texture = input0;
            var inTexture:Texture;

            // Pass 1 — blur blurX pixels along the angle direction
            e.dirX       = cosA;
            e.dirY       = sinA;
            e.blurPixels = _blurX;

            inTexture  = outTexture;
            outTexture = super.process(painter, helper, inTexture);
            if (inTexture != input0) helper.putTexture(inTexture);

            // Pass 2 — blur blurY pixels along the perpendicular direction
            if (_blurY > 0)
            {
                e.dirX       = -sinA;
                e.dirY       =  cosA;
                e.blurPixels = _blurY;

                inTexture  = outTexture;
                outTexture = super.process(painter, helper, inTexture);
                if (inTexture != input0) helper.putTexture(inTexture);
            }

            return outTexture;
        }

        // Padding covers the screen-space projection of both blur extents so the
        // smear is never clipped regardless of angle.
        private function updatePadding():void
        {
            var rad:Number  = _angle * DEG2RAD;
            var cosA:Number = Math.abs(Math.cos(rad));
            var sinA:Number = Math.abs(Math.sin(rad));
            // horizontal screen extent = blurX projected onto X + blurY projected onto X
            var padH:Number = cosA * _blurX * 0.5 + sinA * _blurY * 0.5;
            // vertical screen extent = blurX projected onto Y + blurY projected onto Y
            var padV:Number = sinA * _blurX * 0.5 + cosA * _blurY * 0.5;
            padding.setTo(padH, padH, padV, padV);
        }

        // ---- public API ----

        /** Blur extent along the primary (rotated) axis, in pixels. */
        public function get blurX():Number { return _blurX; }
        public function set blurX(value:Number):void
        {
            if (_blurX == value) return;
            _blurX = value;
            updatePadding();
        }

        /** Blur extent along the perpendicular axis, in pixels. */
        public function get blurY():Number { return _blurY; }
        public function set blurY(value:Number):void
        {
            if (_blurY == value) return;
            _blurY = value;
            updatePadding();
        }

        /** Rotation of the blur axes in degrees. */
        public function get angle():Number { return _angle; }
        public function set angle(value:Number):void
        {
            if (_angle == value) return;
            _angle = value;
            updatePadding();
        }

        /** Number of samples per pass (read-only after construction). */
        public function get samples():int { return _samples; }
    }
}

// ---------------------------------------------------------------------------

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import starling.rendering.FilterEffect;
import starling.rendering.Program;

/**
 * Single-pass directional blur effect.
 * The filter sets dirX/dirY (normalised direction) and blurPixels before each pass;
 * beforeDraw converts those to UV-space steps using the actual texture dimensions.
 */
class LinearBlurEffect extends FilterEffect
{
    /** Normalised direction X component (set by filter before each pass). */
    public var dirX:Number       = 1;
    /** Normalised direction Y component (set by filter before each pass). */
    public var dirY:Number       = 0;
    /** Blur extent in pixels for this pass (set by filter before each pass). */
    public var blurPixels:Number = 10;

    private var _samples:int;

    // fc0: [0, 0, 1/samples, 0]  — zero for accumulator init; z for averaging
    // fc1: [startOffsetX, startOffsetY, stepX, stepY]
    private var _fc0:Vector.<Number> = new <Number>[0.0, 0.0, 0.0, 0.0];
    private var _fc1:Vector.<Number> = new <Number>[0.0, 0.0, 0.0, 0.0];

    public function LinearBlurEffect(samples:int)
    {
        _samples = samples;
        _fc0[2]  = 1.0 / samples;
    }

    /** @private */
    override protected function createProgram():Program
    {
        return Program.fromSource(STD_VERTEX_SHADER, buildShader());
    }

    /** @private */
    override protected function beforeDraw(context:Context3D):void
    {
        super.beforeDraw(context);

        var nativeW:Number = texture.root.nativeWidth;
        var nativeH:Number = texture.root.nativeHeight;

        // UV-space step along the blur direction for one sample interval
        var stepX:Number = dirX * blurPixels / (nativeW * _samples);
        var stepY:Number = dirY * blurPixels / (nativeH * _samples);

        // Start offset to centre the blur on the current pixel
        _fc1[0] = stepX * -(_samples - 1) * 0.5;
        _fc1[1] = stepY * -(_samples - 1) * 0.5;
        _fc1[2] = stepX;
        _fc1[3] = stepY;

        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fc0, 1);
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, _fc1, 1);
    }

    // Shader loop unrolled at AS3 compile time — AGAL has no loop instruction.
    private function buildShader():String
    {
        var s:String = "";

        // ft0 = colour accumulator; fc0.x is always 0.0
        s += "mov ft0.xyzw, fc0.xxxx \n";

        // ft1.xy = current sample UV = pixel UV + start offset
        s += "mov ft1.xy, v0.xy          \n";
        s += "add ft1.xy, ft1.xy, fc1.xy \n";

        for (var i:int = 0; i < _samples; i++)
        {
            s += "tex ft2, ft1.xy, fs0<2d, nomip, clamp> \n";
            s += "add ft0, ft0, ft2                       \n";
            if (i < _samples - 1)
                s += "add ft1.xy, ft1.xy, fc1.zw \n";
        }

        // average
        s += "mul oc, ft0, fc0.zzzz \n";

        return s;
    }
}
