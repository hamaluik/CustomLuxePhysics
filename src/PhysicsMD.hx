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
	public var collisionColour:Color = new Color(0.8, 0, 0);

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

		// draw static bodies first
		for(collider in colliders) {
			if(collider.isDynamic) {
				continue;
			}

			// draw it!
			Luxe.draw.rectangle( {
				immediate: true,
				rect: collider.aabb.rectangle,
				color: staticColour
			});
		}

		// then draw dynamic bodies
		for(collider in colliders) {
			if(!collider.isDynamic) {
				continue;
			}

			// draw it!
			Luxe.draw.rectangle( {
				immediate: true,
				rect: collider.aabb.rectangle,
				color: dynamicColour
			});

			// check to see if it's detecting facial collisions
			if(collider.collisionFaces != null) {
				// yup! draw them
				if(collider.collisionFaces.touching.top) {
					Luxe.draw.line({
						immediate: true,
						p0: new Vector(collider.aabb.rectangle.x, collider.aabb.rectangle.y),
						p1: new Vector(collider.aabb.rectangle.x + collider.aabb.rectangle.w, collider.aabb.rectangle.y),
						color: collisionColour
					});
				}
				if(collider.collisionFaces.touching.right) {
					Luxe.draw.line({
						immediate: true,
						p0: new Vector(collider.aabb.rectangle.x + collider.aabb.rectangle.w, collider.aabb.rectangle.y),
						p1: new Vector(collider.aabb.rectangle.x + collider.aabb.rectangle.w, collider.aabb.rectangle.y + collider.aabb.rectangle.h),
						color: collisionColour
					});
				}
				if(collider.collisionFaces.touching.bottom) {
					Luxe.draw.line({
						immediate: true,
						p0: new Vector(collider.aabb.rectangle.x, collider.aabb.rectangle.y + collider.aabb.rectangle.h),
						p1: new Vector(collider.aabb.rectangle.x + collider.aabb.rectangle.w, collider.aabb.rectangle.y + collider.aabb.rectangle.h),
						color: collisionColour
					});
				}
				if(collider.collisionFaces.touching.left) {
					Luxe.draw.line({
						immediate: true,
						p0: new Vector(collider.aabb.rectangle.x, collider.aabb.rectangle.y),
						p1: new Vector(collider.aabb.rectangle.x, collider.aabb.rectangle.y + collider.aabb.rectangle.h),
						color: collisionColour
					});
				}
			}
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

			// clear the touching flags if the component exists
			if(collider.collisionFaces != null) {
				collider.collisionFaces.clearFlags( );
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
					
					// set the collision faces flags
					if(collider.collisionFaces != null) {
						if(Math.abs(collider.aabb.rectangle.y - (staticCollider.aabb.rectangle.y + staticCollider.aabb.rectangle.h)) <= 0.5) {
							collider.collisionFaces.touching.top = true;
						}
						if(Math.abs((collider.aabb.rectangle.x + collider.aabb.rectangle.w) - staticCollider.aabb.rectangle.x) <= 0.5) {
							collider.collisionFaces.touching.right = true;
						}
						if(Math.abs((collider.aabb.rectangle.y + collider.aabb.rectangle.h) - staticCollider.aabb.rectangle.y) <= 0.5) {
							collider.collisionFaces.touching.bottom = true;
						}
						if(Math.abs(collider.aabb.rectangle.x - (staticCollider.aabb.rectangle.x + staticCollider.aabb.rectangle.w)) <= 0.5) {
							collider.collisionFaces.touching.left = true;
						}
					}

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
				else {
					// see if they might overlap this frame!
					var relativeMotion = new Vector(collider.vel.v.x * Luxe.physics.step_delta * Luxe.timescale, collider.vel.v.y * Luxe.physics.step_delta * Luxe.timescale);
					var h:Float = getRayIntersectionFraction(relativeMotion);

					if(h < Math.POSITIVE_INFINITY) {
						// yup there WILL be a collision!

						// move it into place!
						collider.aabb.move(collider.vel.v.x * Luxe.physics.step_delta * Luxe.timescale * h, collider.vel.v.y * Luxe.physics.step_delta * Luxe.timescale * h);

						// zero out the normal velocity
						var tangent:Vector = new Vector(-relativeMotion.y, relativeMotion.x).normalized;
						var dp:Float = (collider.vel.v.x * tangent.x) + (collider.vel.v.y * tangent.y);
						collider.vel.v.x = tangent.x * dp;
						collider.vel.v.y = tangent.y * dp;
					}
					else {
						// move it normally!
						collider.aabb.move(collider.vel.v.x * Luxe.physics.step_delta * Luxe.timescale, collider.vel.v.y * Luxe.physics.step_delta * Luxe.timescale);
					}
				}
			}
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

	private function getLineIntersection(originA:Vector, endA:Vector, originB:Vector, endB:Vector) {
		var r:Vector = new Vector(endA.x - originA.x, endA.y - originA.y);
		var s:Vector = new Vector(endB.x - originB.x, endB.y - originB.y);
		var delta:Vector = new Vector(originB.x - originA.x, originB.y - originA.x);
		var numerator:Float = Vector.Cross(delta, r).z;
		var denominator:Float = Vector.Cross(r, s);

		if(numerator == 0 && denominator == 0) {
			return Math.POSITIVE_INFINITY;
		}
		if(denominator == 0) {
			return Math.POSITIVE_INFINITY;
		}

		var u:Float = numerator / denominator;
		var t:Float = Vector.Cross(delta, s).z / denominator;
		if((t >= 0) && (t <= 1) && (u >= 0) && (u <= 1)) {
			return t;
		}
		return Math.POSITIVE_INFINITY;
	}

	private function getRayIntersectionFraction(direction:Float):Float {
		var minT:Float = getLineIntersection(new Vector(), direction, new Vector(mdResult.x, mdResult.y), new Vector(mdResult.x, mdResult.y + mdResult.h));
		var x:Float = getLineIntersection(new Vector(), direction, new Vector(mdResult.x, mdResult.y + mdResult.h), new Vector(mdResult.x, mdResult.y + mdResult.h));
		if(x < minT) {
			minT = x;
		}
		var x:Float = getLineIntersection(new Vector(), direction, new Vector(mdResult.x + mdResult.w, mdResult.y + mdResult.h), new Vector(mdResult.x + mdResult.w, mdResult.y));
		if(x < minT) {
			minT = x;
		}
		var x:Float = getLineIntersection(new Vector(), direction, new Vector(mdResult.x + mdResult.w, mdResult.y), new Vector(mdResult.x, mdResult.y));
		if(x < minT) {
			minT = x;
		}

		return minT;
	}
}