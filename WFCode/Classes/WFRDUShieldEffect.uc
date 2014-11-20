class WFRDUShieldEffect extends QueenShield;

var() float ForwardOffset;

function Touch(actor Other)
{
}

simulated function Tick(float DeltaTime)
{
	local vector X, Y, Z;
	if (Owner != None)
	{
		GetAxes(Owner.Rotation, X, Y, Z);
		SetLocation(Owner.Location + X * ForwardOffset);
		SetRotation(Owner.Rotation);
	}
}

defaultproperties
{
	Physics=PHYS_None
	ForwardOffset=25.0
	//bTrailerSameRotation=True
	RemoteRole=ROLE_SimulatedProxy
	Style=STY_Translucent
	bOwnerNoSee=True
	LifeSpan=0.000000
	DrawScale=0.55
	bCollideActors=False
	bProjTarget=False
	CollisionHeight=0.0
	CollisionRadius=0.0
}