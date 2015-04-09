package components;

import luxe.Component;
import luxe.Vector;

class Run extends Component {
	public var vel:Velocity;

	public var speed:Float;

	public function new( speed:Float ) {
		super( {name: 'Run' });
		this.speed = speed;
	}

	override public function init( ) {
		vel = get( 'Velocity' );
		if(vel == null) {
			throw "Run cannot operate without a Velocity component!";
		}
	}

	public function run(direction:Float) {
		// clamp the direction axis
		direction = Math.max(direction, -1);
		direction = Math.min(direction, 1);
		vel.v.x = direction * speed;
	}
}