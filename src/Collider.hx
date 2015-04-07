package ;

import luxe.Component;
import luxe.Vector;
import luxe.Rectangle;

class Collider extends Component {
	public var aabb:AABB;
	public var vel:Velocity;
	public var acc:Acceleration;

	public function new( ) {
		super( {name: 'Collider' });
	}

	override public function init() {
		aabb = get('AABB');
		if(aabb == null) {
			throw "Collider must have an AABB attached to it!";
		}
		vel = get('Velocity');
		acc = get('Acceleration');
	}

	override public function onadded() {
		PhysicsMD.instance.colliders.push(this);
	}

	override public function onremoved() {
		PhysicsMD.instance.colliders.remove(this);
	}

	public var isDynamic(get, never):Bool;
	public function get_isDynamic():Bool {
		return vel != null;
	}
}