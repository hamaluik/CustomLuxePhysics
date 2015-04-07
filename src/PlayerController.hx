package ;

import luxe.Input;
import luxe.Component;

class PlayerController extends Component {
	public var jump:Jump;

	public function new() {
		super({name: 'PlayerController'});
	}

	override public function init() {
		jump = get('Jump');
		if(jump == null) {
			throw "PlayerController needs a Jump component to operate on!";
		}
	}

	override function onkeydown(e:KeyEvent) {
		if(e.keycode == Key.key_w) {
			jump.jump();
		}
	}
}