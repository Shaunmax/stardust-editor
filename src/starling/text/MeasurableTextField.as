// =================================================================================================
//
//	Starling Framework — MeasurableTextField extension
//	Adds Flash-text-layout measurement APIs to Starling's TextField without modifying it.
//
// =================================================================================================

package starling.text
{
    import flash.geom.Rectangle;
    import flash.text.AntiAliasType;
    import flash.text.TextLineMetrics;

    import starling.core.Starling;
    import starling.utils.SystemUtil;

    /**
     * A drop-in replacement for <code>starling.text.TextField</code> that exposes
     * per-line and per-character layout measurement APIs, mirroring the classic
     * <code>flash.text.TextField</code> measurement interface.
     *
     * <p>Measurement is performed on a hidden <code>flash.text.TextField</code>
     * configured identically to what <code>TrueTypeCompositor</code> uses internally,
     * so positions match the rendered output.</p>
     *
     * <p>All returned values are in <strong>Starling points</strong> (logical pixels),
     * not physical pixels.</p>
     *
     * <listing version="3.0">
     * var label:MeasurableTextField = new MeasurableTextField(400, 60, "Hello World");
     * label.format.font = "Arial";
     * label.format.size = 32;
     * addChild(label);
     *
     * trace(label.numLines);              // 1
     * trace(label.getLineText(0));        // "Hello World"
     * trace(label.getLineMetrics(0).width); // line width in Starling points
     * </listing>
     */
    public class MeasurableTextField extends TextField
    {
        // Shared across all instances — AS3 is single-threaded so no race risk.
        private static var sMeasureTF:flash.text.TextField      = new flash.text.TextField();
        private static var sMeasureFormat:flash.text.TextFormat = new flash.text.TextFormat();

        // ── constructor ──────────────────────────────────────────────────────

        /** Identical signature to <code>starling.text.TextField</code>. */
        public function MeasurableTextField(width:int, height:int, text:String = "",
                                            format:TextFormat = null,
                                            options:TextOptions = null)
        {
            super(width, height, text, format, options);
        }

        // ── public measurement API ───────────────────────────────────────────

        /** Number of lines in the current layout (respects wordWrap and dimensions). */
        public function get numLines():int
        {
            configureMeasureTF();
            return sMeasureTF.numLines;
        }

        /** Text content of line <code>line</code> (zero-based index). */
        public function getLineText(line:int):String
        {
            configureMeasureTF();
            return sMeasureTF.getLineText(line);
        }

        /** Character index of the first character of line <code>line</code>. */
        public function getLineOffset(line:int):int
        {
            configureMeasureTF();
            return sMeasureTF.getLineOffset(line);
        }

        /**
         * Metrics for line <code>line</code> in Starling points.
         * All fields (x, width, height, ascent, descent, leading) are divided by
         * <code>Starling.contentScaleFactor</code> before being returned.
         */
        public function getLineMetrics(line:int):TextLineMetrics
        {
            configureMeasureTF();
            var scale:Number      = Starling.contentScaleFactor;
            var m:TextLineMetrics = sMeasureTF.getLineMetrics(line);
            return new TextLineMetrics(
                m.x       / scale,
                m.width   / scale,
                m.height  / scale,
                m.ascent  / scale,
                m.descent / scale,
                m.leading / scale
            );
        }

        /**
         * Bounding rectangle of the character at <code>charIndex</code>, in local Starling
         * points.  Returns <code>null</code> for out-of-range indices or soft line-break
         * positions (same behaviour as <code>flash.text.TextField.getCharBoundaries</code>).
         *
         * @param out  Optional Rectangle to reuse; a new one is created if null.
         */
        public function getCharBounds(charIndex:int, out:Rectangle = null):Rectangle
        {
            configureMeasureTF();
            var scale:Number              = Starling.contentScaleFactor;
            var r:flash.geom.Rectangle    = sMeasureTF.getCharBoundaries(charIndex);
            if (r == null) return null;
            if (out == null) out = new Rectangle();
            out.setTo(r.x / scale, r.y / scale, r.width / scale, r.height / scale);
            return out;
        }

        /**
         * The tightest rectangle enclosing all rendered text, in local Starling points.
         *
         * <p>The <code>x</code> and <code>y</code> values are typically small negative
         * numbers — Flash adds an internal ~2 px glyph offset that causes text to start
         * slightly to the left / above the TextField origin.
         * <code>SplitStarlingTextField</code> uses this to anchor the first character.</p>
         *
         * @param out  Optional Rectangle to reuse; a new one is created if null.
         */
        public function getMeasurementBounds(out:Rectangle = null):Rectangle
        {
            configureMeasureTF();
            var scale:Number           = Starling.contentScaleFactor;
            var r:flash.geom.Rectangle = sMeasureTF.getBounds(sMeasureTF);
            if (out == null) out = new Rectangle();
            out.setTo(r.x / scale, r.y / scale, r.width / scale, r.height / scale);
            return out;
        }

        // ── private ──────────────────────────────────────────────────────────

        private function configureMeasureTF():void
        {
            var scale:Number = Starling.contentScaleFactor;

            // getBounds(this) with identity transform returns the logical (unscaled) size.
            var logicalBounds:flash.geom.Rectangle = getBounds(this);

            format.toNativeFormat(sMeasureFormat);
            sMeasureFormat.size    = Number(sMeasureFormat.size) * scale;
            sMeasureFormat.leading = 0;

            sMeasureTF.embedFonts        = SystemUtil.isEmbeddedFont(
                                               format.font, format.bold, format.italic);
            sMeasureTF.defaultTextFormat = sMeasureFormat;
            sMeasureTF.width             = logicalBounds.width  * scale;
            sMeasureTF.height            = logicalBounds.height * scale;
            sMeasureTF.wordWrap          = this.wordWrap;
            sMeasureTF.multiline         = true;
            sMeasureTF.selectable        = false;
            sMeasureTF.antiAliasType     = AntiAliasType.ADVANCED;
            sMeasureTF.text              = this.text;
            sMeasureTF.appendText("");   // forces numLines refresh (Flash Player bug)
        }
    }
}
