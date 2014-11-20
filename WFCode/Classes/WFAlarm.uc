//=============================================================================
// WFAlarm.
//
// TODO: Send an "intruder alert" message to the owner when first playing the alarm
//=============================================================================
class WFAlarm extends WFS_PCSWallGrenadeProj;

var bool bAlarmActive, bCanRemove;
var() int Health;
var byte OwnerTeam;
var() sound AlarmSound;
var WFAlarmArea AlarmArea;
var float MinEffectTime; // used for spawning spark effects when damaged
var float LastEffect;

var WFAlarmGlow Glow;
var() float GlowOffset;

var() float AlarmLifeSpan; // how long before alarm runs out

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

// handle encroachment (movers cause alarm to vanish)
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

function EncroachedBy( actor Other )
{
	if ((Other.Brush != None) || (Brush(Other) != None))
	{
		// make it look like it transports away
		spawn(class'EnhancedRespawn', self,, Location);
		Destroy();
	}
}
// end of mover anti-block code

state OnSurface
{
	function BeginState()
	{
		bAlarmActive = true;
		RemoteRole = ROLE_DumbProxy; // to give accurate location
		SetTimer(2.0, false);

		AlarmArea = spawn(class'WFAlarmArea', self,, Location + ((SurfaceNormal*0.0001) * 16), Rotation);
		AlarmArea.OwnerTeam = OwnerTeam;
		AlarmArea.OwnerAlarm = self;
		AlarmArea.SetBase(self);
		AlarmArea.InitAlarmArea();

		Glow = spawn(class'WFAlarmGlow', self,, Location);
	}

	event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation,
						vector Momentum, name DamageType)
	{
		if (Health <= 0) return;

		if ( !Region.Zone.bWaterZone && (LastEffect - Level.TimeSeconds > MinEffectTime) && (FRand() < 0.5) )
		{
			LastEffect = Level.TimeSeconds;
			spawn(class'UT_Spark',,,Location + 8 * Vector(Rotation));
		}

		Health -= Damage;
		if (Health <= 0)
		{
			ServerExplosion(Location + (SurfaceNormal*0.0001) * 16);
			Destroy();
		}
	}

	function Timer()
	{
		if (!bCanRemove)
		{
			RemoteRole = ROLE_SimulatedProxy;
			bCanRemove = true;
			if (AlarmLifeSpan > 0.0)
				SetTimer(AlarmLifeSpan, false);
		}
		else
		{
			// remove alarm
			if (Instigator != None)
				Instigator.ClientMessage("Your alarm has expired", 'CriticalEvent');
			Destroy();
		}
	}

	function EndState()
	{
		bAlarmActive = false;
	}
}

function PlayAlarm()
{
	// TODO: add message here
	Glow.ShowGlow();
	AmbientSound = AlarmSound;
}

function StopAlarm()
{
	Glow.HideGlow();
	AmbientSound = None;
}

simulated function SetupInitialRotation(vector HitNormal)
{
	SetRotation(rotator(HitNormal));
}

function Destroyed()
{
	if (AlarmArea != None)
		AlarmArea.Destroy();
	if (Glow != None)
		Glow.Destroy();
	super.Destroyed();
}

defaultproperties
{
	Damage=0
	MinEffectTime=1.000000
	DetonationTime=0.000000
	Health=250
	AlarmSound=Sound'Botpack.CTF.flagtaken'
	SoundRadius=196
	SoundVolume=196
	SoundPitch=96
	bProjTarget=True
	Mesh=LodMesh'WF_Alarm'
	DrawScale=0.800000
	bCanHitPlayers=False
	CollisionHeight=2.000000
	CollisionRadius=2.000000
	GlowOffset=8
	AlarmLifeSpan=180.0
}