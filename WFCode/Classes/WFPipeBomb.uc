class WFPipeBomb extends WFS_PCSGrenadeProj;

var int Health;

simulated function PostBeginPlay()
{
	local vector X, Y, Z;

	if (Role == ROLE_Authority)
	{
		GetAxes(Instigator.ViewRotation,X,Y,Z);
		Velocity = X * (Instigator.Velocity Dot X)*0.4 + Vector(Rotation) * (Speed +
			FRand() * 100);
		Velocity.z += 210;
		MaxSpeed = 1000;
	}

	super.PostBeginPlay();
}

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	if (Health <= 0)
		return;

	if ((EventInstigator == None) || EventInstigator.bIsPlayer)
	{

		if ((EventInstigator == None) || (Instigator.PlayerReplicationInfo.Team != EventInstigator.PlayerReplicationInfo.Team))
			Health -= Damage;
		if (Health <= 0)
		{
			Detonate();
			UpdateList();
		}
	}
}

function ServerExplosion(vector HitLocation)
{
	BlowUp(HitLocation);
	spawn(class'ut_spriteballexplosion',,,hitlocation);
	//UpdateList();
	Destroy();
}

function Detonate()
{
	ServerExplosion(Location + vect(0,0,16));
}

function UpdateList()
{
	local WFPipeBombList List;
	List = WFPipeBombList(class'WFS_PlayerClassInfo'.static.FindRelatedActorClass(Instigator, class'WFPipeBombList'));
	if (List != None)
		List.RemovePipeBomb(self);
}

defaultproperties
{
	bCanHitPlayers=False
	DetonationTime=0.0
	bRandomSpin=True
	AnimSequence=WingIn
	Mesh=LodMesh'UnrealShare.GrenadeM'
	bFixedRotationDir=True
	DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
	MyDamageType='PipeBomb'
	BounceDampening=0.5
	bNetTemporary=False
	Health=25
	Damage=55
}