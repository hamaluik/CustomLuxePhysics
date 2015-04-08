import luxe.Input;
import luxe.Physics;
import luxe.Entity;
import luxe.Vector;

class Main extends luxe.Game {
	var player:Entity;
	var platform:Entity;
	var wall1:Entity;
	var wall2:Entity;

	override function ready() {
		// setup the custom physics
		Luxe.physics.add_engine( PhysicsMD );

		// zoom in!
		Luxe.camera.zoom = 2;

		// set up key bindings
		Luxe.input.bind_key('jump', Key.key_w);
		Luxe.input.bind_key('move_left', Key.key_a);
		Luxe.input.bind_key('move_right', Key.key_d);

		// create the player
		player = new Entity( {
			name: 'player'
		});
		player.add(new AABB(Luxe.screen.mid.x, Luxe.screen.mid.y, 4, 8));
		player.add(new Velocity(0, 0));
		player.add(new Acceleration(0, 1000));
		player.add(new Collider());
		player.add(new Run(150));
		player.add(new Jump(275, Math.PI / 4));
		player.add(new PlayerController());
		player.add(new CollisionFaces());

		// and some obstacles
		platform = new Entity({name: 'platform'});
		platform.add(new AABB(Luxe.screen.mid.x, Luxe.screen.mid.y + 46, 32, 4));
		platform.add(new Collider());

		wall1 = new Entity({name: 'wall', name_unique: true});
		wall1.add(new AABB(Luxe.screen.mid.x - 36, Luxe.screen.mid.y, 4, 64));
		wall1.add(new Collider());

		wall2 = new Entity({name: 'wall', name_unique: true});
		wall2.add(new AABB(Luxe.screen.mid.x + 36, Luxe.screen.mid.y, 4, 64));
		wall2.add(new Collider());
	} //ready

	override function onkeyup( e:KeyEvent ) {

		if(e.keycode == Key.escape) {
			Luxe.shutdown();
		}

	} //onkeyup

	override function update(dt:Float) {

	} //update


} //Main
