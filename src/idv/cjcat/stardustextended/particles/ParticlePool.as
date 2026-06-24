package idv.cjcat.stardustextended.particles
{

/**
 * This is an object pool for particle objects.
 *
 * <p>
 * Be sure to recycle a particle after getting it from the pool.
 * </p>
 */
public class ParticlePool
{

    protected static const _recycled : Vector.<Particle> = new <Particle>[];

    [Inline]
    public static function get() : Particle
    {
        if (_recycled.length > 0)
        {
            return _recycled.pop();
        }
        else
        {
            return new Particle();
        }
    }

    [Inline]
    public static function recycle(particle : Particle) : void
    {
        _recycled.push(particle);
    }
}
}