package idv.cjcat.stardustextended.handlers
{

public interface ISpriteSheetHandler
{

    function set spriteSheetAnimationSpeed(spriteSheetAnimationSpeed : uint) : void;

    function get spriteSheetAnimationSpeed() : uint;

    function set spriteSheetStartAtRandomFrame(spriteSheetStartAtRandomFrame : Boolean) : void;

    function get spriteSheetStartAtRandomFrame() : Boolean;

    function get smoothing() : Boolean;

    function set smoothing(value : Boolean) : void;

    function get isSpriteSheet() : Boolean;

    function set blendMode(blendMode : String) : void;

    function get blendMode() : String;
}
}
