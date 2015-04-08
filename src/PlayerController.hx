package ;

import luxe.Input;
import luxe.Component;

class PlayerController extends Component {
	public var run:Run;
	public var jump:Jump;
	public var collisionFaces:CollisionFaces;

	public var axis:Float = 0;

	public function new() {
		super({name: 'PlayerController'});
	}

	override public function init() {
		run = get('Run');
		jump = get('Jump');
		collisionFaces = get('CollisionFaces');
		if(run == null || jump == null || collisionFaces == null) {
			throw "PlayerController needs Run, Jump, and CollisionFaces components to operate on!";
		}
	}

	override function update(dt:Float) {
		if(collisionFaces.touching.bottom) {
			var axis:Float = 0;
			if(Luxe.input.inputdown('move_left')) {
				axis -= 1;
			}
			if(Luxe.input.inputdown('move_right')) {
				axis += 1;
			}
			run.run(axis);
		}
		else {
			if(Luxe.input.inputdown('move_left')) {
				run.run(-1);
			}
			else if(Luxe.input.inputdown('move_right')) {
				run.run(1);
			}
		}

		if(Luxe.input.inputpressed('jump')) {
			jump.jump();
		}
	}
}