package idv.cjcat.stardustextended.flashdisplay.bursters
{
import flash.display.BitmapData;

import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.utils.ColorUtil;

public class PixelBurster extends Burster
{

    /**
     * The X coordinate of the top-left corner of the top-left cell.
     */
    public var offsetX : Number;
    /**
     * The Y coordinate of the top-left corner of the top-left cell.
     */
    public var offsetY : Number;

    public var bitmapData : BitmapData;

    public function PixelBurster(offsetX : Number = 0, offsetY : Number = 0)
    {
        this.offsetX = offsetX;
        this.offsetY = offsetY;
    }

    override public function createParticles(currentTime : Number) : Vector.<Particle>
    {
        if (!bitmapData) return null;

        var rows : int = bitmapData.height;
        var columns : int = bitmapData.width;
        var particles : Vector.<Particle> = factory.createParticles(rows * columns, currentTime);

        var index : int = 0;
        var p : Particle;
        var inv255 : Number = 1 / 255;
        for (var j : int = 0; j < rows; j++) {
            for (var i : int = 0; i < columns; i++) {
                p = particles[index];
                var color : uint = bitmapData.getPixel32(i, j);
                p.alpha = Number(uint(color & 0xFF000000) >> 24) * inv255;
                if (!p.alpha) continue;
                const colorNoAlpha : uint = color & 0xFFFFFF;
                p.colorR = ColorUtil.extractRed(colorNoAlpha);
                p.colorG = ColorUtil.extractGreen(colorNoAlpha);
                p.colorB = ColorUtil.extractBlue(colorNoAlpha);
                p.x = i + offsetX;
                p.y = j + offsetY;

                index++;
            }
        }

        return particles;
    }
}
}