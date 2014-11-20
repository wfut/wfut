class WFMiniFlakSlug extends FlakSlug;

simulated function Timer()
{
	local ut_SpriteSmokePuff s;

	initialDir = Velocity;
	if (Level.NetMode!=NM_DedicatedServer)
	{
		s = Spawn(class'WFMiniFlakSpriteSmokePuff');
		s.RemoteRole = ROLE_None;
	}
	if ( Level.bDropDetail )
		SetTimer(0.25,True);
	else if ( Level.bHighDetailMode )
		SetTimer(0.04,True);
}

function Explode(vector HitLocation, vector HitNormal)
{
	local vector start;

	HurtRadius(damage, 150, 'FlakDeath', MomentumTransfer, HitLocation);
	start = Location + 10 * HitNormal;
 	Spawn( class'WFMiniFlakSlugExplosion',,,Start);
	Spawn( class 'WFMiniChunk2',, '', Start);
	Spawn( class 'WFMiniChunk3',, '', Start);
 	Destroy();
}

defaultproperties
{
	Damage=35.0
	//Damage=17.500000
	DrawScale=0.25
	//MomentumTransfer=75000
	MomentumTransfer=37500
	//MomentumTransfer=18750
}