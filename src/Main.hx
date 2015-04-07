import luxe.Input;
import luxe.Physics;
import luxe.Entity;
import luxe.Vector;

class Main extends luxe.Game {
	var player:Entity;
	var platform:Entity;

	override function ready() {
		// setup the custom physics
		Luxe.physics.add_engine( PhysicsMD );

		// zoom in!
		Luxe.camera.zoom = 2;

		// create the player
		player = new Entity( {
			name: 'player'
		});
		player.add(new AABB(Luxe.screen.mid.x, Luxe.screen.mid.y, 4, 8));
		player.add(new Velocity(0, 0));
		player.add(new Acceleration(0, 1000));
		player.add(new Collider());
		player.add(new Jump(275));
		player.add(new PlayerController());

		// and a platform for them
		platform = new Entity({name: 'platform'});
		platform.add(new AABB(Luxe.screen.mid.x, Luxe.screen.mid.y + 46, 32, 4));
		platform.add(new Collider());
	} //ready

	override function onkeyup( e:KeyEvent ) {

		if(e.keycode == Key.escape) {
			Luxe.shutdown();
		}

	} //onkeyup

	override function update(dt:Float) {

	} //update


} //Main
