//=============================================================================
// WFGrenDecloaker.
//=============================================================================
class WFGrenDecloakerProj extends WFS_PCSGrenadeProj;

var() float EffectRange;

var WFGrenDecloakerField DecloakingField;

simulated function PostBeginPlay()
{
	local rotator FieldRot;
	super.PostBeginPlay();
	if ( Role == ROLE_Authority )
	{
		FieldRot.Yaw = Rotation.Yaw;
		DecloakingField = spawn(class'WFGrenDecloakerField', self,,, FieldRot);
		DecloakingField.SetPhysics(PHYS_Trailer);
		DecloakingField.EffectRange = EffectRange;
		if (Instigator != None)
			DecloakingField.SetTeam(Instigator.PlayerReplicationInfo.Team);
	}
}

simulated function Explosion(vector HitLocation)
{
	local effects s;
	if (Level.NetMode != NM_Client)
		PlaySound(MiscSound);

	if (DecloakingField != None)
		DecloakingField.Destroy();
	s = spawn(class'UT_SpriteBallExplosion',,,Location+vect(0,0,1)*16);
	s.RemoteRole = ROLE_None;
	s.DrawScale = 0.5;

	Destroy();
}

function ServerExplosion(vector HitLocation)
{
	BlowUp(HitLocation);
	if ( Level.NetMode != NM_DedicatedServer )
		spawn(class'Botpack.BlastMark',,,,rot(16384,0,0));
	spawn(class'ut_spriteballexplosion',,,hitlocation+vect(0,0,1)*16);

	Destroy();
}

function Destroyed()
{
	if (DecloakingField != None)
		DecloakingField.Destroy();
	super.Destroyed();
}

defaultproperties
{
	Mass=25.000000
	LifeSpan=0.000000
	EffectRange=250.000000
	DetonationTime=90.000000
	BounceDampening=0.500000
	CollisionRadius=8.000000
	CollisionHeight=8.000000
	MyDamageType=GrenadeDeath
	Mesh=LodMesh'UnrealI.ForceFieldPick'
	DrawScale=0.500000
	AmbientSound=Sound'UnrealI.ffieldl2'
	SoundRadius=50
	SoundVolume=255
	SpawnSound=Sound'UnrealI.FieldSnd'
	MiscSound=Sound'UnrealI.fFieldh2'
	bCanHitPlayers=False
	bNetTemporary=False
}