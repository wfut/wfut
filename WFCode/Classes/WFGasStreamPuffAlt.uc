class WFGasStreamPuffAlt extends WFGasStreamPuff;

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
}

function CauseDamage(pawn Other, vector HitLocation)
{
}

function Timer()
{
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	Velocity = 0.75*(( Velocity dot HitNormal ) * HitNormal * (-1.0) + Velocity);   // Reflect off Wall w/damping
	speed = VSize(Velocity);
	if ( speed < 20 )
	{
		bBounce = False;
		SetPhysics(PHYS_None);
	}
}

defaultproperties
{
}
