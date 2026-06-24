package starling.filters
{
    import starling.display.BlendMode;
    import starling.filters.BlurFilter;
    import starling.filters.CompositeFilter;
    import starling.filters.FragmentFilter;
    import starling.filters.GlowFilter;
    import starling.filters.IFilterHelper;
    import starling.rendering.FilterEffect;
    import starling.rendering.Painter;
    import starling.textures.Texture;
    import starling.textures.TextureSmoothing;
    import starling.utils.MathUtil;
    import starling.utils.Padding;

    /**
     * Applies a contour line effect using Glow + SmoothThreshold + OptionalBlur + Mask + Composite.
     * Pass 1: Inner Glow Knockout.
     * Pass 2: Smooth Threshold the glow to create an anti-aliased line (_thresholdEffect via super.process).
     * Pass 3a: Optionally apply a Blur filter for extra smoothing (_smoothBlurFilter.process).
     * Pass 3b: Optionally mask the blurred contour using the original alpha (_maskEffect via super.process).
     * Pass 4: Composite original image with the final line (_compositeFilter.process).
     * Output: Original image with the contour line drawn over it (blur inside).
     */
    public class BevelFilter extends FragmentFilter
    {
        // --- Public Properties ---
        private var _color:uint;
        private var _size:Number;
        private var _alpha:Number;
        private var _smooth:Number;

        // --- Internal Filters & Effects ---
        private var _glowFilter:GlowFilter;
        private var _thresholdEffect:BevelEffect;
        private var _smoothBlurFilter:BlurFilter;
        private var _maskEffect:MaskEffect;
        private var _compositeFilter:CompositeFilter;

        private static const TRESHOLD_PASS_TYPE:uint = 1; // treshold
        private static const MASK_PASS_TYPE:uint = 2; // mask
        // --- State ---
        private var _currentPassType:uint = TRESHOLD_PASS_TYPE;

        // --- Constants ---
        private static const THRESHOLD_VALUE:Number = 0.1; // As confirmed working by user

        /** Constructor */
        public function BevelFilter(color:uint = 0x000000, size:Number = 1, alpha:Number = 1.0, smooth:Number = 0.0)
        {
            super();

            if (this.padding == null) this.padding = new Padding();

            // 1. GlowFilter
            _glowFilter = new GlowFilter(0, 5, Math.max(0.1, size), 2, true, true);
            _glowFilter.textureSmoothing = TextureSmoothing.BILINEAR;

            // 2. Threshold Effect - kreiran u createEffect()

            // 3. Smooth Blur Filter
            _smoothBlurFilter = new BlurFilter(smooth, smooth, 1);
            _smoothBlurFilter.textureSmoothing = TextureSmoothing.BILINEAR;

            // 5. CompositeFilter
            _compositeFilter = new CompositeFilter();
            _compositeFilter.setModeAt(1, BlendMode.NORMAL);

            // Set parameters via setters
            this.color = color;
            this.alpha = alpha;
            this.size = size;
            this.smooth = smooth;

            this.maintainResolutionAcrossPasses = true;
        }

        /** @inheritDoc */
        override public function dispose():void {
            if (_glowFilter) _glowFilter.dispose();
            if (_thresholdEffect) _thresholdEffect.dispose();
            if (_smoothBlurFilter) _smoothBlurFilter.dispose();
            if (_maskEffect) _maskEffect.dispose();
            if (_compositeFilter) _compositeFilter.dispose();
            _glowFilter = null; _thresholdEffect = null; _smoothBlurFilter = null; _maskEffect = null; _compositeFilter = null;
            super.dispose();
        }

        /** Creates the primary effect for this filter (ContourLineEffect). */
        override protected function createEffect():FilterEffect
        {
            if (_thresholdEffect == null)
                _thresholdEffect = new BevelEffect();
            return _thresholdEffect;
        }

        /** Returns the appropriate effect based on the current pass type. */
        override protected function get effect():FilterEffect
        {
            if (_currentPassType === TRESHOLD_PASS_TYPE)
            {
                if (_thresholdEffect == null) _thresholdEffect = this.createEffect() as BevelEffect;
                if (_thresholdEffect == null) throw new Error("_thresholdEffect is null!");
                return _thresholdEffect;
            }
            else if (_currentPassType === MASK_PASS_TYPE)
            {
                if (_maskEffect === null)
                {
                    _maskEffect = new MaskEffect();
                    _maskEffect.textureSmoothing = this.textureSmoothing;
                }
                return _maskEffect;
            }
            else
            {
                throw new Error("Unknown pass type: " + _currentPassType);
            }
        }

        /** Main filter processing method */
        override public function process(painter:Painter, helper:IFilterHelper,
                                         input0:Texture = null, input1:Texture = null,
                                         input2:Texture = null, input3:Texture = null):Texture
        {
            if (input0 === null || _glowFilter === null || _smoothBlurFilter === null || _compositeFilter === null) {
                return input0;
            }

            var glowKnockoutTexture:Texture = null;
            var semiSmoothContourTexture:Texture = null;
            var blurredContourTexture:Texture = null;
            var maskedBlurredContourTexture:Texture = null;
            var finalTexture:Texture = null;
            var textureForComposite:Texture = null;

            // --- Pass 1: Inner Glow Knockout ---
            glowKnockoutTexture = _glowFilter.process(painter, helper, input0);
            if (glowKnockoutTexture == null) { helper.putTexture(glowKnockoutTexture); return input0; }

            // --- Pass 2: Smooth Threshold ---
            _currentPassType = TRESHOLD_PASS_TYPE;
            if (_thresholdEffect == null) this.effect;
            _thresholdEffect.configureThreshold(_color, _alpha, THRESHOLD_VALUE);
            semiSmoothContourTexture = super.process(painter, helper, glowKnockoutTexture);
            helper.putTexture(glowKnockoutTexture);
            if (semiSmoothContourTexture == null) { return input0; }

            // --- Pass 3: Optional Smooth Blur & Masking ---
            if (_smooth > 0) {
                // Pass 3a: Blur the contour
                blurredContourTexture = _smoothBlurFilter.process(painter, helper, semiSmoothContourTexture);
                helper.putTexture(semiSmoothContourTexture);
                if (blurredContourTexture != null) {
                    // Pass 3b: Mask the blur using MaskEffect via super.process
                    _currentPassType = MASK_PASS_TYPE;

                    var maskEffectInstance:MaskEffect = this.effect as MaskEffect;
                    if (maskEffectInstance) {
                        maskEffectInstance.maskTexture = input0;
                    } else {
                        helper.putTexture(blurredContourTexture);
                        throw new Error("Could not get MaskEffect instance when expected!");
                        return input0;
                    }

                    // Call super.process. It will use _maskEffect.
                    maskedBlurredContourTexture = super.process(painter, helper, blurredContourTexture);
                    helper.putTexture(blurredContourTexture);

                    if (maskedBlurredContourTexture === null) {
                        return input0; // Masking failed
                    }
                    textureForComposite = maskedBlurredContourTexture;
                } else {
                    return input0;
                }
            } else {
                textureForComposite = semiSmoothContourTexture;
            }

            _currentPassType = TRESHOLD_PASS_TYPE;

            // --- Pass 4: Final Composite ---
            _compositeFilter.setModeAt(1, BlendMode.NORMAL);
            _compositeFilter.setAlphaAt(1, this.alpha);
            finalTexture = _compositeFilter.process(painter, helper, input0, textureForComposite);

            // Return last used texture in pool
            if (textureForComposite !== null && textureForComposite !== input0 && textureForComposite !== semiSmoothContourTexture) {
                helper.putTexture(textureForComposite);
            }

            if (finalTexture === null) { return input0; }

            return finalTexture;
        }

        private static var glowPasses:int
        private static var thresholdPasses:int = 1;
        private static var blurPasses:int = 0;
        private static var maskingPasses:int = 0;
        private static var compositePasses:int
        private static var totalPasses:int;

        /** Calculates the total number of passes */
        override public function get numPasses():int {
            glowPasses = _glowFilter ? _glowFilter.numPasses : 1;
            thresholdPasses = 1;
            blurPasses = 0;
            maskingPasses = 0;
            compositePasses = _compositeFilter ? _compositeFilter.numPasses : 1;

            if (_smooth > 0)
            {
                blurPasses = _smoothBlurFilter ? _smoothBlurFilter.numPasses : 0;
                maskingPasses = 1;
            }

            totalPasses = glowPasses + thresholdPasses + blurPasses + maskingPasses + compositePasses;

            // +1 for final pass
            return totalPasses + 1;
        }

        // --- Padding ---
        /** Updates padding based only on the internal GlowFilter's requirements. */
        private function calculateAndUpdatePadding():void {
            if (this.padding == null) this.padding = new Padding();
            if (_glowFilter == null) return; // Safety check
            this.padding.copyFrom(_glowFilter.padding);
            if (this.padding.left < 1) this.padding.left = this.padding.right = 1;
            if (this.padding.top < 1) this.padding.top = this.padding.bottom = 1;
        }

        // --- Getters & Setters ---

        /** The color of the contour line. */
        public function get color():uint { return _color; }
        public function set color(value:uint):void {
            if (_color != value) {
                _color = value;
                setRequiresRedraw();
                if (_thresholdEffect) _thresholdEffect.configureThreshold(_color, _alpha, THRESHOLD_VALUE);
            }
        }

        /** The alpha transparency of the contour line (range 0.0 to 1.0). */
        public function get alpha():Number { return _alpha; }
        public function set alpha(value:Number):void {
            value = MathUtil.clamp(value, 0.0, 1.0);
            if (_alpha != value) {
                _alpha = value;
                if (_compositeFilter) _compositeFilter.setAlphaAt(1, value);
                if (_thresholdEffect) _thresholdEffect.configureThreshold(_color, _alpha, THRESHOLD_VALUE);
                setRequiresRedraw();
            }
        }

        /** The thickness of the contour line (influences glow blur). Minimum 1. */
        public function get size():Number { return _size; }
        public function set size(value:Number):void {
            value = Math.max(1, value);
            if (_size != value) {
                _size = value;
                if (_glowFilter) _glowFilter.blur = Math.max(0.1, value);
                calculateAndUpdatePadding();
                setRequiresRedraw();
            }
        }

        /** The quality of the internal glow filter (range 0.1 to 1.0). */
        public function get quality():Number { return _glowFilter ? _glowFilter.quality : 1.0; }
        public function set quality(value:Number):void {
            if (_glowFilter && _glowFilter.quality != value) {
                _glowFilter.quality = value;
                calculateAndUpdatePadding();
                setRequiresRedraw();
            }
        }

        /** The amount of extra blur applied for additional smoothing (0.0 for none). */
        public function get smooth():Number { return _smooth; }
        public function set smooth(value:Number):void {
            value = Math.max(0.0, value);
            if (_smooth != value) {
                _smooth = value;
                if (_smoothBlurFilter) {
                    _smoothBlurFilter.blurX = value;
                    _smoothBlurFilter.blurY = value;
                }
                setRequiresRedraw();
            }
        }

    } // End ContourLineFilter class
} // End Package scope

// =====================================================
// Helper class - ContourLineEffect - SMOOTH THRESHOLD mod (v41 - Reverted static vars)
// =====================================================
import starling.utils.MathUtil;

/**
 * @private Effect for ContourLineFilter - handles Smooth Threshold mode. (v41)
 * Takes glow texture as input and outputs anti-aliased contour line with target alpha.
 * Uses local vectors in beforeDraw for safety.
 */
class BevelEffect extends FilterEffect
{
    // Internal variables for parameters
    private var _color:uint;
    private var _alpha:Number;
    private var _threshold:Number;

    // NO Static vectors

    /** Constructor */
    public function BevelEffect() {
        super();
        this.textureSmoothing = TextureSmoothing.BILINEAR;
    }

    /** @inheritDoc */
    override public function dispose():void {
        super.dispose();
    }

    // --- Configuration ---
    /** Configures the effect for the smooth threshold pass. */
    public function configureThreshold(color:uint, alpha:Number, threshold:Number):void {
        _color = color;
        _alpha = alpha;
        _threshold = threshold;
    }

    // --- Program Management ---
    /** Creates the smooth threshold program. */
    override protected function createProgram():Program {
        // Uses the fixed smoothstep AGAL from v36
        return createProgramSmoothThreshold_Fixed();
    }

    // --- Shader Creation ---
    /** Creates the AGAL program for smooth thresholding (fixed AGAL). */
    private function createProgramSmoothThreshold_Fixed():Program {
        var vertexShader:String = STD_VERTEX_SHADER_NO_NEIGHBOURS;
        var fragmentShader:String =
                "tex ft0, v0, fs0 <2d,linear,nomip>\n" +
                "sub ft1.x, ft0.w, fc0.x\n" +
                "mul ft1.x, ft1.x, fc0.y\n" +
                "sat ft1.x, ft1.x\n" +
                "mul ft2.y, ft1.x, fc2.y\n" +
                "sub ft2.y, fc2.x, ft2.y\n" +
                "mul ft2.z, ft1.x, ft1.x\n" +
                "mul ft1.x, ft2.z, ft2.y\n" +
                "mul oc, fc1, ft1.xxxx";

        return Program.fromSource(vertexShader, fragmentShader);
    }

    // --- STATIC Constants for calculations ---
    private static const THRESHOLD_WIDTH:Number = 0.4;
    private static const EPSILON:Number = 0.0001;
    private static const HALF_WIDTH:Number = THRESHOLD_WIDTH * 0.5;
    private static const INV_WIDTH_EPS:Number = 1.0 / Math.max(THRESHOLD_WIDTH, EPSILON);

    // --- STATIC Vectors for AGAL constants (Requested - UNSAFE for sFc0/sFc1) ---
    private static var sFc0Vec:Vector.<Number> = new <Number>[0, 0, 0, 0]; // {edge0, invWidthEps, 0, 0}
    private static var sFc1Vec:Vector.<Number> = new <Number>[0, 0, 0, 0]; // {r, g, b, a}
    private static var sFc2Vec:Vector.<Number> = new <Number>[3.0, 2.0, 0.0, 0.0]; // {3, 2, 0, 0} - Constant


    /** @inheritDoc */
    override protected function beforeDraw(context:Context3D):void
    {
        if (texture) RenderUtil.setSamplerStateAt(0, texture.mipMapping, this.textureSmoothing, false);
        else RenderUtil.setSamplerStateAt(0, false, this.textureSmoothing);

        super.beforeDraw(context);

        if (texture == null) return;

        sFc0Vec[0] = Math.max(0.0, _threshold - HALF_WIDTH);
        sFc0Vec[1] = INV_WIDTH_EPS;

        sFc1Vec[0] = ((_color >> 16) & 0xFF) / 255.0; // R
        sFc1Vec[1] = ((_color >> 8) & 0xFF) / 255.0;  // G

        sFc1Vec[2] = (_color & 0xFF) / 255.0;         // B
        sFc1Vec[3] = _alpha;                          // A

        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, sFc0Vec, 1); // fc0
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, sFc1Vec, 1); // fc1
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, sFc2Vec, 1); // fc2
    }

    // --- Clean up after drawing ---
    /** @inheritDoc */
    override protected function afterDraw(context:Context3D):void {
        RenderUtil.setSamplerStateAt(0, false, TextureSmoothing.BILINEAR, false);
        super.afterDraw(context);
    }

    // --- Vertex Shader Definition ---
    /** Standard vertex shader, passes position and texture coords. */
    private static const STD_VERTEX_SHADER_NO_NEIGHBOURS:String = FilterEffect.STD_VERTEX_SHADER;

} // End ContourLineEffect class

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;

import starling.rendering.FilterEffect;
import starling.rendering.Program;
import starling.textures.Texture;
import starling.utils.RenderUtil;
import starling.textures.TextureSmoothing;

/**
 * @private
 * Effect that masks its primary texture ('texture') based on the alpha channel
 * of a secondary texture ('maskTexture').
 * Output = texture.rgba * step(maskTexture.a, threshold)
 */
class MaskEffect extends FilterEffect
{
    // Mask texture for selective rendering
    public var maskTexture:Texture;

    // Alpha threshold in mask to determine visible areas
    private var _threshold:Number = 0.01; // Little treshold to avoid almost transparent pixels in mask

    private var _thresholdVector:Vector.<Number> = new <Number>[_threshold, 0, 0, 0];

    /** Constructor */
    public function MaskEffect()
    {
        super();
    }

    /** Threshold getter/setter */
    public function get threshold():Number { return _threshold; }
    public function set threshold(value:Number):void
    {
        value = MathUtil.clamp(value, 0.0, 1.0); // Clamp threshold
        if (_threshold != value)
        {
            _threshold = value;
            _thresholdVector[0] = value;
        }
    }

    private static var fragmentShader:String

    /** Kreira AGAL program */
    override protected function createProgram():Program
    {
        fragmentShader =
            "tex ft0, v0, fs0 <2d,linear,nomip>" + "\n" +
            "tex ft1, v0, fs1 <2d,linear,nomip>" + "\n" +
            "mov ft1.x, ft1.w" + "\n" +
            "sge ft2.x, ft1.x, fc0.x" + "\n" +
            "mul oc, ft0, ft2.xxxx";

        return Program.fromSource(STD_VERTEX_SHADER, fragmentShader);
    }

    /** Podešava konstante i teksture pre iscrtavanja */
    override protected function beforeDraw(context:Context3D):void
    {
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _thresholdVector, 1);

        if (maskTexture && maskTexture.base)
        {
            RenderUtil.setSamplerStateAt(1, maskTexture.mipMapping);
            context.setTextureAt(1, maskTexture.base);
        }
        else
        {
            context.setTextureAt(1, null);
        }
        super.beforeDraw(context);
    }

    /** Čisti stanje posle iscrtavanja */
    override protected function afterDraw(context:Context3D):void
    {
        context.setTextureAt(1, null);
        super.afterDraw(context);
    }

    /** @inheritDoc */
    override public function dispose():void {
        maskTexture = null;
        super.dispose();
    }
}
