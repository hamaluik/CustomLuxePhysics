package ;

import luxe.Color;
import luxe.Debug;
import luxe.Physics;
import luxe.Rectangle;
import luxe.Vector;

class PhysicsMD extends PhysicsEngine {
	public static var instance:PhysicsMD;

	public var colliders:Array<Collider> = new Array<Collider>();

	public var staticColour:Color = new Color(0.5, 0.5, 0.5);
	public var dynamicColour:Color = new Color(0.267, 1, 0.769);

	// this is a cached minkowski difference rectangle
	private var mdResult:Rectangle = new Rectangle();
	private var penetration:Vector = new Vector();
	private var _minDist:Float = 0;
	private var _dist:Float = 0;

	public function new() {
		super( );
		instance = this;
	}

	override public function render() {
		if(!draw) {
			return;
		}

		for(collider in colliders) {
			// draw it!
			Luxe.draw.rectangle( {
				immediate: true,
				rect: collider.aabb.rectangle,
				color: collider.isDynamic ? dynamicColour : staticColour
			});
		}
	}

	private inline function minkowskiDifference(a:Rectangle, b:Rectangle) {
		mdResult.x = a.x - (b.x + b.w);
		mdResult.y = a.y - (b.y + b.h);
		mdResult.w = a.w + b.w;
		mdResult.h = a.h + b.h;
	}

	private function calculatePenetration() {
		_minDist = Math.abs(mdResult.x);
		penetration.x = mdResult.x;
		penetration.y = 0;

		_dist = Math.abs(mdResult.x + mdResult.w);
		if(_dist < _minDist) {
			_minDist = _dist;
			penetration.x = mdResult.x + mdResult.w;
			penetration.y = 0;
		}

		_dist = Math.abs(mdResult.y);
		if(_dist < _minDist) {
			_minDist = _dist;
			penetration.x = 0;
			penetration.y = mdResult.y;
		}

		_dist = Math.abs(mdResult.y + mdResult.h);
		if(_dist < _minDist) {
			_minDist = _dist;
			penetration.x = 0;
			penetration.y = mdResult.y + mdResult.h;
		}
	}

	override public function update() {
		if(paused) {
			return;
		}

		// loop through all the dynamic colliders and naivelly attempt to collide them with each static collider
		for(collider in colliders) {
			if(!collider.isDynamic) {
				continue;
			}

			// loop through all the static colliders
			for(staticCollider in colliders) {
				// skip ourselves
				// and any dynamic colliders
				if(collider == staticCollider || staticCollider.isDynamic) {
					continue;
				}

				// calculate the minkowski difference
				minkowskiDifference(collider.aabb.rectangle, staticCollider.aabb.rectangle);

				// see if they overlap!
				if(mdResult.x <= 0 && (mdResult.x + mdResult.w) >= 0 && mdResult.y <= 0 && (mdResult.y + mdResult.h) >= 0) {
					// yup, they're colliding!
					// calculate the penetration vector
					calculatePenetration();

					// don't do anything if the penetration is 0
					if(penetration.x == 0 && penetration.y == 0) {
						continue;
					}

					// remove the normal velocity
					var tangent:Vector = new Vector(-penetration.y, penetration.x).normalized;
					var dp:Float = (collider.vel.v.x * tangent.x) + (collider.vel.v.y * tangent.y);
					collider.vel.v.x = tangent.x * dp;
					collider.vel.v.y = tangent.y * dp;

					// and push it out
					collider.aabb.move(-penetration.x, -penetration.y);
				}
			}
		}
	}
}