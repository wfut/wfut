class WFMortarGrenade extends WFFastGrenade;

simulated function ProcessTouch( actor Other, vector HitLocation )
{
	if ( (Other!=instigator) )
		Explosion(HitLocation);
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	Explosion(Location);
}

simulated function Explosion(vector HitLocation)
{
	local effects e;

	BlowUp(HitLocation);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		spawn(class'Botpack.BlastMark',,,,rot(16384,0,0));
  		e = spawn(class'FlameExplosion',,,HitLocation);
		e.RemoteRole = ROLE_None;
  		e = spawn(class'WFGrenadeWave',,,HitLocation);
		e.RemoteRole = ROLE_None;
	}
 	Destroy();
}

defaultproperties
{
	Damage=80
	Range=250
}