package idv.cjcat.stardustextended.flashdisplay
{

import idv.cjcat.stardustextended.xml.ClassPackage;
import idv.cjcat.stardustextended.flashdisplay.handlers.BitmapHandler;
import idv.cjcat.stardustextended.flashdisplay.handlers.DisplayObjectHandler;
import idv.cjcat.stardustextended.flashdisplay.handlers.DisplayObjectSpriteSheetHandler;
import idv.cjcat.stardustextended.flashdisplay.handlers.SingularBitmapHandler;

/**
 * Packs together classes for the classic display list.
 */
public class FlashDisplayClassPackage extends ClassPackage
{

    private static var _instance : FlashDisplayClassPackage;

    public static function getInstance() : FlashDisplayClassPackage
    {
        if (!_instance) _instance = new FlashDisplayClassPackage();
        return _instance;
    }

    override protected final function populateClasses() : void
    {
        //2D particle handlers
        classes.push(BitmapHandler);
        classes.push(DisplayObjectHandler);
        classes.push(SingularBitmapHandler);
        classes.push(DisplayObjectSpriteSheetHandler);
    }
}
}