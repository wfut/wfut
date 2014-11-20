//=============================================================================
// WFGrenConcProj.
//=============================================================================
class WFGrenConcProj extends WFS_PCSGrenadeProj;

function BlowUp(vector HitLocation)
{
	local pawn aPawn;
	local WFPlayerStatus Concussion;
	local inventory Inv;

	foreach RadiusActors(class'Pawn', aPawn, DamageRadius)
	{
		if ((aPawn != None) && aPawn.bIsPlayer && (aPawn != Instigator) && (aPawn.Health > 0)
			&& (aPawn.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team)
			&& !aPawn.IsInState('PCSpectating'))
		{
			// give the concussion to the player
			Concussion = spawn(class'WFStatusConcussed',,, aPawn.Location);
			Concussion.GiveStatusTo(aPawn, Instigator);
		}
	}

	super.BlowUp(HitLocation);
}

defaultproperties
{
	Mass=25.000000
	LifeSpan=0.000000
	Damage=20
	DamageRadius=250.000000
	DetonationTime=2.500000
	MomentumTransfer=120000
	BounceDampening=0.500000
	CollisionRadius=8.000000
	CollisionHeight=8.000000
	MyDamageType=ConcGrenade
	Mesh=LodMesh'Botpack.BioGelm'
	Skin=Texture'UnrealShare.Belt_fx.ShieldBelt.newgold'
	Texture=Texture'UnrealShare.Belt_fx.ShieldBelt.newgold'
	bMeshEnviroMap=True
	DrawScale=1.000000
}