package ;

import luxe.Component;
import luxe.Vector;

class Acceleration extends Component {
	public var a:Vector = new Vector( );
	private var vel:Velocity;

	public function new( ?ax:Float, ?ay:Float ) {
		super( {name: 'Acceleration' });
		if(ax != null) {
			a.x = ax;
		}
		if(ay != null) {
			a.y = ay;
		}
	}

	override public function init( ) {
		vel = get( 'Velocity' );
		if(vel == null) {
			throw "Acceleration cannot operate without a velocity component!";
		}
	}

	override public function update(dt:Float) {
		vel.v.x += a.x * dt;
		vel.v.y += a.y * dt;
	}
}