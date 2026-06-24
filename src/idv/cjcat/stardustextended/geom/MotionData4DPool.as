package idv.cjcat.stardustextended.geom
{

public class MotionData4DPool
{

    protected static const _recycled : Vector.<MotionData4D> = new <MotionData4D>[];

    [Inline]
    public static function get(x : Number = 0, y : Number = 0, vx : Number = 0, vy : Number = 0) : MotionData4D
    {
        var obj : MotionData4D;
        if (_recycled.length > 0) {
            obj = _recycled.pop();
            obj.x = x;
            obj.y = y;
            obj.vx = vx;
            obj.vy = vy;
        }
        else {
            obj = new MotionData4D(x, y, vx, vy);
        }
        return obj;
    }

    [Inline]
    public static function recycle(obj : MotionData4D) : void
    {
        _recycled.push(obj);
    }

}
}