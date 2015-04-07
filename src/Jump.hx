package ;

import luxe.Component;
import luxe.Vector;

class Jump extends Component {
	public var aabb:AABB;
	public var vel:Velocity;
	public var v0:Float = 0;

	public function new( v0:Float ) {
		super( {name: 'Jump' });
		this.v0 = v0;
	}

	override public function init( ) {
		aabb = get( 'AABB' );
		vel = get( 'Velocity' );
		if(aabb == null || vel == null) {
			throw "Jump cannot operate without a AABB and Velocity components!";
		}
	}

	public function jump() {
		vel.v.y = -v0;
		aabb.move(0, -1);
	}
}