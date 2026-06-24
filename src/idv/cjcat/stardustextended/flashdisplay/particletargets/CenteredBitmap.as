package idv.cjcat.stardustextended.flashdisplay.particletargets
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;

public class CenteredBitmap extends Sprite
{
    private var bmp : Bitmap;

    public function CenteredBitmap()
    {
        bmp = new Bitmap();
        addChild(bmp);
    }

    public function get smoothing() : Boolean
    {
        return bmp.smoothing;
    }

    public function set smoothing(value : Boolean) : void
    {
        bmp.smoothing = value;
    }

    public function get bitmapData() : BitmapData
    {
        return bmp.bitmapData;
    }

    public function set bitmapData(value : BitmapData) : void
    {
        bmp.bitmapData = value;
        bmp.x = -bmp.width * 0.5;
        bmp.y = -bmp.height * 0.5;
    }
}
}
