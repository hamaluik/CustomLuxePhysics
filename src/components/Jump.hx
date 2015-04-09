package components;

import luxe.Component;
import luxe.Vector;

class Jump extends Component {
	public var aabb:AABB;
	public var vel:Velocity;
	public var collisionFaces:CollisionFaces;

	public var v0:Float = 0;
	public var jumpAngle:Float = Math.PI / 4;

	public function new( v0:Float, jumpAngle:Float ) {
		super( {name: 'Jump' });
		this.v0 = v0;
		this.jumpAngle = jumpAngle;
	}

	override public function init( ) {
		aabb = get( 'AABB' );
		vel = get( 'Velocity' );
		if(aabb == null || vel == null) {
			throw "Jump cannot operate without AABB and Velocity components!";
		}
		collisionFaces = get('CollisionFaces');
	}

	private inline function sign(x:Float):Float {
		if(x < 0) {
			return -1;
		}
		if(x > 0) {
			return 1;
		}
		return 0;
	}

	public function jump() {
		var canJump:Bool = true;

		var jx:Float = 0;
		var jy:Float = -v0;

		// first test if we have collision faces
		if(collisionFaces != null) {
			if(!collisionFaces.touching.bottom && !collisionFaces.touching.left && !collisionFaces.touching.right) {
				canJump = false;
			}
			if(canJump && !collisionFaces.touching.bottom) {
				// launch at an angle
				jx = Math.cos(jumpAngle) * v0;
				jy = -Math.sin(jumpAngle) * v0;

				if(collisionFaces.touching.right) {
					jx *= -1;
				}
			}
		}

		if(canJump) {
			vel.v.x = jx;
			vel.v.y = jy;
			aabb.move(sign(jx), sign(jy));
			if(collisionFaces != null) {
				collisionFaces.clearFlags();
			}
		}
	}
}