package components;

import luxe.Component;
import luxe.Vector;
import luxe.Rectangle;

class AABB extends Component {
	public var rectangle:Rectangle;

	public function new( centreX:Float, centreY:Float, extentsX:Float, extentsY:Float ) {
		super( {name: 'AABB' });
		rectangle = new Rectangle( centreX - extentsX, centreY - extentsY, extentsX * 2, extentsY * 2 );
	}

	public function move(dx:Float, dy:Float) {
		rectangle.x += dx;
		rectangle.y += dy;
	}
}