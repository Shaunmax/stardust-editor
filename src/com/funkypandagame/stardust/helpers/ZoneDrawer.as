package com.funkypandagame.stardust.helpers
{

import flash.display.Graphics;
import flash.geom.Point;

import idv.cjcat.stardustextended.actions.Action;
import idv.cjcat.stardustextended.actions.waypoints.Waypoint;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.initializers.Initializer;
import idv.cjcat.stardustextended.actions.Deflect;
import idv.cjcat.stardustextended.actions.FollowWaypoints;
import idv.cjcat.stardustextended.actions.IZoneContainer;
import idv.cjcat.stardustextended.deflectors.CircleDeflector;
import idv.cjcat.stardustextended.deflectors.Deflector;
import idv.cjcat.stardustextended.deflectors.LineDeflector;
import idv.cjcat.stardustextended.deflectors.WrappingBox;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;
import idv.cjcat.stardustextended.initializers.PositionAnimated;
import idv.cjcat.stardustextended.zones.CircleContour;
import idv.cjcat.stardustextended.zones.CircleZone;
import idv.cjcat.stardustextended.zones.Composite;
import idv.cjcat.stardustextended.zones.Line;
import idv.cjcat.stardustextended.zones.RectContour;
import idv.cjcat.stardustextended.zones.RectZone;
import idv.cjcat.stardustextended.zones.Sector;
import idv.cjcat.stardustextended.zones.SinglePoint;
import idv.cjcat.stardustextended.zones.Zone;

public class ZoneDrawer
{
    private static var emitter:Emitter;
    private static var graphics:Graphics;

    public static function init(e:Emitter, g:Graphics):void
    {
        emitter = e;
        graphics = g;
    }

    public static function drawEmitterZones():void
    {
        if (emitter == null || graphics == null) return;
        graphics.clear();
        for each (var init:Initializer in emitter.initializers)
        {
            if (init is PositionAnimated)
                drawZones(graphics, PositionAnimated(init).zones, 0x75FF56, PositionAnimated(init).currentPosition);
        }
        for each (var act:Action in emitter.actions)
        {
            if (act is IZoneContainer)
                drawZones(graphics, IZoneContainer(act).zones, 0xE03535, null);
            else if (act is Deflect)
                drawDeflector(graphics, Deflect(act), 0x6D83FF);
            else if (act is FollowWaypoints)
                drawWaypoints(graphics, FollowWaypoints(act), 0xFFFB30);
        }
    }

    private static function drawWaypoints(g:Graphics, wps:FollowWaypoints, color:uint):void
    {
        for each (var wp:Waypoint in wps.waypoints)
        {
            g.beginFill(color, 0.7);
            g.lineStyle(2, darkenColor(color, 50));
            g.drawCircle(wp.x, wp.y, wp.radius);
            g.endFill();
        }
    }

    private static function drawDeflector(g:Graphics, d:Deflect, color:uint):void
    {
        g.lineStyle(2, darkenColor(color, 50));
        for each (var def:Deflector in d.deflectors)
        {
            if (def is CircleDeflector)
            {
                g.beginFill(color, 0.7);
                var cd:CircleDeflector = CircleDeflector(def);
                g.drawCircle(cd.x, cd.y, cd.radius);
                g.endFill();
            }
            else if (def is WrappingBox)
            {
                g.beginFill(color, 0.7);
                var wb:WrappingBox = WrappingBox(def);
                g.drawRect(wb.x, wb.y, wb.width, wb.height);
                g.endFill();
            }
            else if (def is LineDeflector)
            {
                var ld:LineDeflector = LineDeflector(def);
                g.moveTo(ld.x - ld.normal.y * 500, ld.y + ld.normal.x * 500);
                g.lineTo(ld.x + ld.normal.y * 500, ld.y - ld.normal.x * 500);
            }
        }
    }

    private static function drawZones(g:Graphics, zones:Vector.<Zone>, color:uint, offset:Point):void
    {
        if (offset == null) offset = new Point(0, 0);
        g.lineStyle(2, darkenColor(color, 50));

        for each (var z:Zone in zones)
        {
            if (z is SinglePoint)
            {
                g.beginFill(color, 0.7);
                var sp:SinglePoint = SinglePoint(z);
                g.drawCircle(sp.x - 1 + offset.x, sp.y - 1 + offset.y, 2);
            }
            else if (z is Line)
            {
                var li:Line = Line(z);
                g.moveTo(li.x + offset.x, li.y + offset.y);
                g.lineTo(li.x2 + offset.x, li.y2 + offset.y);
            }
            else if (z is RectZone)
            {
                g.beginFill(color, 0.7);
                var re:RectZone = RectZone(z);
                var topRight:Vec2D = Vec2DPool.get(re.width, 0).rotate(re.rotation);
                var bottomRight:Vec2D = Vec2DPool.get(re.width, re.height).rotate(re.rotation);
                var bottomLeft:Vec2D = Vec2DPool.get(0, re.height).rotate(re.rotation);
                g.moveTo(re.x + offset.x, re.y + offset.y);
                g.lineTo(re.x + offset.x + topRight.x, re.y + offset.y + topRight.y);
                g.lineTo(re.x + offset.x + bottomRight.x, re.y + offset.y + bottomRight.y);
                g.lineTo(re.x + offset.x + bottomLeft.x, re.y + offset.y + bottomLeft.y);
                g.lineTo(re.x + offset.x, re.y + offset.y);
                Vec2DPool.recycle(topRight);
                Vec2DPool.recycle(bottomRight);
                Vec2DPool.recycle(bottomLeft);
            }
            else if (z is RectContour)
            {
                g.endFill();
                var rc:RectContour = RectContour(z);
                var tr2:Vec2D = Vec2DPool.get(rc.width, 0).rotate(rc.rotation);
                var br2:Vec2D = Vec2DPool.get(rc.width, rc.height).rotate(rc.rotation);
                var bl2:Vec2D = Vec2DPool.get(0, rc.height).rotate(rc.rotation);
                g.moveTo(rc.x + offset.x, rc.y + offset.y);
                g.lineTo(rc.x + offset.x + tr2.x, rc.y + offset.y + tr2.y);
                g.lineTo(rc.x + offset.x + br2.x, rc.y + offset.y + br2.y);
                g.lineTo(rc.x + offset.x + bl2.x, rc.y + offset.y + bl2.y);
                g.lineTo(rc.x + offset.x, rc.y + offset.y);
                Vec2DPool.recycle(tr2);
                Vec2DPool.recycle(br2);
                Vec2DPool.recycle(bl2);
            }
            else if (z is CircleZone)
            {
                g.beginFill(color, 0.7);
                var cz:CircleZone = CircleZone(z);
                g.drawCircle(cz.x + offset.x, cz.y + offset.y, cz.radius);
            }
            else if (z is CircleContour)
            {
                g.endFill();
                var cc:CircleContour = CircleContour(z);
                g.drawCircle(cc.x + offset.x, cc.y + offset.y, cc.radius);
            }
            else if (z is Sector)
            {
                g.beginFill(color, 0.7);
                var se:Sector = Sector(z);
                drawSector(g, se.x + offset.x, se.y + offset.y, se.minRadius, se.maxRadius, se.minAngle, se.maxAngle);
            }
            else if (z is Composite)
            {
                drawZones(g, Composite(z).zones, color, offset);
            }
            else
            {
                trace("ZoneDrawer: unknown zone " + z);
            }
            g.endFill();
        }
    }

    private static function darkenColor(hexColor:Number, percent:Number):Number
    {
        if (isNaN(percent)) percent = 0;
        if (percent > 100) percent = 100;
        if (percent < 0) percent = 0;
        var factor:Number = 1 - (percent / 100);
        var r:Number = ((hexColor & 0xff0000) >> 16) * factor;
        var g:Number = ((hexColor & 0x00ff00) >> 8) * factor;
        var b:Number = (hexColor & 0x0000ff) * factor;
        return (Math.round(r) << 16 | Math.round(g) << 8 | Math.round(b));
    }

    private static function drawSector(g:Graphics, cx:Number, cy:Number,
                                       innerRadius:Number, outerRadius:Number,
                                       startAngle:Number, endAngle:Number):void
    {
        startAngle = startAngle / 360;
        endAngle = endAngle / 360;
        const steps:int = 30;
        const twoPI:Number = 2 * Math.PI;
        const angleStep:Number = (endAngle - startAngle) / steps;

        var xx:Number = cx + Math.cos(startAngle * twoPI) * innerRadius;
        var yy:Number = cy + Math.sin(startAngle * twoPI) * innerRadius;
        const startPoint:Point = new Point(xx, yy);
        g.moveTo(xx, yy);

        for (var i:int = 1; i <= steps; i++)
        {
            var angle:Number = (startAngle + i * angleStep) * twoPI;
            g.lineTo(cx + Math.cos(angle) * innerRadius, cy + Math.sin(angle) * innerRadius);
        }
        for (i = 0; i <= steps; i++)
        {
            angle = (endAngle - i * angleStep) * twoPI;
            g.lineTo(cx + Math.cos(angle) * outerRadius, cy + Math.sin(angle) * outerRadius);
        }
        g.lineTo(startPoint.x, startPoint.y);
    }
}
}
