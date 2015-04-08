package ;

import luxe.Component;
import luxe.Vector;
import luxe.Input;

class Velocity extends Component {
	public var v:Vector = new Vector( );
	private var aabb:AABB;

	public function new( ?vx:Float, ?vy:Float ) {
		super( {name: 'Velocity' });
		if(vx != null) {
			v.x = vx;
		}
		if(vy != null) {
			v.y = vy;
		}
	}

	override public function init( ) {
		aabb = get( 'AABB' );
		if(aabb == null) {
			throw "Velocity cannot operate without an AABB component!";
		}
	}

	override public function update(dt:Float) {
		aabb.move( v.x * dt * Luxe.timescale, v.y * dt * Luxe.timescale );
	}
}