//=============================================================================
// WFMarker.
//
// Used to mark a position that bots need to be able to make their way to.
// (use this instead of dynamically creating navigation points)
//=============================================================================
class WFMarker extends Actor;

var int Team;

defaultproperties
{
	bHidden=True
	CollisionRadius=46.000000
	CollisionHeight=50.000000
}