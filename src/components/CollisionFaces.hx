package components;

import luxe.Component;

typedef TouchDirections = {
	var top:Bool;
	var right:Bool;
	var bottom:Bool;
	var left:Bool;
}

class CollisionFaces extends Component {
	public var touching:TouchDirections;

	public function new() {
		super( {name: 'CollisionFaces'} );
		clearFlags( );
	}

	public function clearFlags() {
		touching = {
			top: false,
			right: false,
			bottom: false,
			left: false
		};
	}
}