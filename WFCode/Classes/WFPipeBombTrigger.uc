class WFPipeBombTrigger extends WFS_PCSWallGrenadeProj;

var WFPipeBombTriggerArea ProximityField;
var WFPipeBombTriggerGlow Glow;
var float TriggerDelay, TriggerRange;
var int Health;
var int OwnerTeam;

var bool bActive, bCanMove;

// This code ensures these things don't block movers (for long, anwyay)
simulated function HitWall( vector HitNormal, actor Wall )
{
	// if attached to mover, remove mine
	if ( (Wall.Brush != None) || (Brush(Wall) != None) )
	{
		// make it look like it transports away
		spawn(class'EnhancedRespawn', self,, Location);
		Destroy();
	}
	else super.HitWall(HitNormal, Wall);
}

// handle encroachment (movers cause them to vanish)
function bool EncroachingOn( actor Other )
{
	if ((Other.Brush != None) || (Brush(Other) != None))
	{
		// make it look like it transports away
		spawn(class'EnhancedRespawn', self,, Location);
		Destroy();
	}
	return false;
}

function Detonate();

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	Glow = spawn(class'WFPipeBombTriggerGlow', self,, Location);
}

state OnSurface
{
	function BeginState()
	{
		bActive = true;
		RemoteRole = ROLE_DumbProxy; // to give accurate location
		SetTimer(2.0, false);

		ProximityField = spawn(class'WFPipeBombTriggerArea', self,, Location + ((SurfaceNormal*0.0001) * 16), Rotation);
		ProximityField.OwnerTeam = OwnerTeam;
		ProximityField.OwnerBombTrigger = self;
		ProximityField.SetBase(self);
		ProximityField.InitProximityArea();
	}

	function Detonate()
	{
		if (bActive)
		{
			GotoState('DelayedTrigger');
			ProximityField.OwnerBombTrigger = None;
			ProximityField.Destroy();
		}
	}

	event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation,
						vector Momentum, name DamageType)
	{
		if (Health <= 0) return;

		if (EventInstigator != None)
			Damage = Level.Game.ReduceDamage( Damage, DamageType, Instigator, EventInstigator );
		Health -= Damage;
		if (Health <= 0)
		{
			Spawn(class'ut_spriteballexplosion', self,, Location + (SurfaceNormal*0.0001)*8.0);
			Destroy();
		}
	}

	function Timer()
	{
		RemoteRole = ROLE_SimulatedProxy;
		bCanMove = true;
	}
}

state DelayedTrigger
{
Begin:
	PlayBeep();
	Sleep(TriggerDelay);
	DetonatePipeBombs();
}

function PlayBeep()
{
	PlaySound(sound'UnrealShare.Beep',, 2.0);
}

function DetonatePipeBombs()
{
	local WFPipeBomb PB;

	foreach RadiusActors(class'WFPipeBomb', PB, TriggerRange)
		if ( (PB != None) && !PB.bDeleteMe && ((PB.Instigator == None) || (PB.Instigator == Instigator)) )
			PB.Detonate();

	Spawn(class'ut_spriteballexplosion', self,, Location + (SurfaceNormal*0.0001)*8.0);
	Destroy();
}

simulated function Destroyed()
{
	if ((Role == ROLE_Authority) && (ProximityField != None))
		ProximityField.Destroy();
	if (Glow != None)
		Glow.Destroy();
	super.Destroyed();
}

simulated function SetupInitialRotation(vector HitNormal)
{
	SetRotation(rotator(HitNormal));
}

defaultproperties
{
     TriggerRange=1500.000000
     Health=150
     DetonationTime=0.000000
     bCanHitPlayers=False
     Damage=0.000000
     Mesh=Mesh'WFMedia.pipeprox'
     DrawScale=0.850000
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     bProjTarget=True
}
