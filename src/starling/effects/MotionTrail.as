package starling.effects
{
    import starling.display.DisplayObjectContainer;
    import starling.display.Image;
    import starling.filters.BlurFilter;
    import starling.textures.RenderTexture;

    /**
     * MotionTrail creates a ring buffer of ghost images that trail behind a Starling
     * <code>Image</code> giving a sense of motion.
     *
     * <p>Two modes, controlled by the <code>useRenderTexture</code> constructor flag:</p>
     * <ul>
     *   <li><b>false (default)</b> — ghosts share the target's raw texture. Zero extra GPU
     *       allocations; no blur on ghosts.</li>
     *   <li><b>true</b> — ghosts share one <code>RenderTexture</code> that is redrawn every
     *       frame with a fixed <code>BlurFilter(1,1)</code> baked in. One RT draw call per
     *       frame; ghosts appear softly blurred without per-ghost filter overhead.</li>
     * </ul>
     *
     * <p>Do not instantiate directly — use <code>MotionTrailPlugin</code>.</p>
     */
    public class MotionTrail
    {
        private static const ALPHA_CUTOFF:Number = 0.01;

        private var _ghosts:Vector.<Image>;
        private var _target:Image;
        private var _fadeFactor:Number;
        private var _count:int;
        private var _head:int = 0;

        // Ghosts stamp at the previous frame's position so no sharp copy sits directly
        // under the live (possibly filtered) sprite.
        private var _prevX:Number;
        private var _prevY:Number;

        // RT mode only — null when useRenderTexture is false.
        private var _blurRT:RenderTexture;
        private var _stampImage:Image;   // in display list (visible=false) so filter has a valid parent
        private var _pad:int;

        /**
         * @param target             Image to trail. Must have a parent in the display list.
         * @param fadeFactor         Per-frame alpha multiplier for ghost decay (0–1).
         * @param count              Ghost slots in the ring buffer.
         * @param useRenderTexture   true = bake BlurFilter(1,1) into a shared RT each frame.
         *                           false = ghosts share the target's raw texture (cheaper).
         */
        public function MotionTrail(target:Image, fadeFactor:Number = 0.85, count:int = 12,
                                    useRenderTexture:Boolean = false)
        {
            _target     = target;
            _fadeFactor = fadeFactor;
            _count      = count;
            _ghosts     = new Vector.<Image>(count, true);

            _prevX = target.x;
            _prevY = target.y;

            var parent:DisplayObjectContainer = target.parent;
            var index:int = parent.getChildIndex(target);

            if (useRenderTexture)
            {
                // BlurFilter(1,1) expands ~5px per side; 10px pad gives a comfortable margin.
                _pad = 10;
                var rtW:int = target.texture.width  + _pad * 2;
                var rtH:int = target.texture.height + _pad * 2;

                // Non-persistent: auto-cleared on every draw() call.
                _blurRT = new RenderTexture(rtW, rtH, false);

                // Stamp image lives in the display list (visible=false) so that
                // FragmentFilter.render() has a valid coordinate space via _target.parent.
                _stampImage        = new Image(target.texture);
                _stampImage.x      = _pad;
                _stampImage.y      = _pad;
                _stampImage.visible = false;
                _stampImage.filter = new BlurFilter(1, 1);
                parent.addChildAt(_stampImage, index);
            }

            for (var i:int = 0; i < count; i++)
            {
                var ghost:Image;

                if (useRenderTexture)
                {
                    ghost        = new Image(_blurRT);
                    ghost.pivotX = target.pivotX + _pad;
                    ghost.pivotY = target.pivotY + _pad;
                }
                else
                {
                    ghost        = new Image(target.texture);
                    ghost.pivotX = target.pivotX;
                    ghost.pivotY = target.pivotY;
                }

                ghost.scaleX   = target.scaleX;
                ghost.scaleY   = target.scaleY;
                ghost.rotation = target.rotation;
                ghost.alpha    = 0;
                ghost.visible  = false;
                parent.addChildAt(ghost, index);
                _ghosts[i] = ghost;
            }
        }

        /**
         * Stamp one frame: optionally bake the RT snapshot, place the head ghost at the
         * previous position, then fade all other active ghosts. Call once per frame.
         */
        public function advanceTime():void
        {
            if (_blurRT)
                _blurRT.draw(_stampImage); // non-persistent auto-clears; all ghosts see the update

            var head:Image = _ghosts[_head];
            head.x       = _prevX;
            head.y       = _prevY;
            head.alpha   = 1.0;
            head.visible = true;

            _prevX = _target.x;
            _prevY = _target.y;

            for (var i:int = 0; i < _count; i++)
            {
                if (i == _head) continue;
                var g:Image = _ghosts[i];
                if (!g.visible) continue;
                g.alpha *= _fadeFactor;
                if (g.alpha < ALPHA_CUTOFF)
                    g.visible = false;
            }

            _head = (_head + 1) % _count;
        }

        public function dispose():void
        {
            for (var i:int = 0; i < _count; i++)
                _ghosts[i].dispose();

            if (_stampImage) { _stampImage.dispose(); _stampImage = null; } // also disposes its BlurFilter
            if (_blurRT)     { _blurRT.dispose();     _blurRT = null;     }

            _ghosts = null;
            _target = null;
        }

        public function get fadeFactor():Number         { return _fadeFactor; }
        public function set fadeFactor(v:Number):void   { _fadeFactor = v; }
    }
}
