//=============================================================================
// WFStatusOnFire.
//=============================================================================
class WFStatusOnFire extends WFPlayerStatus;

var() int OnFireTime;
var() int DamageAmount;
var() int DamageTime;
var() name DamageType;

var() vector ViewFog;
var() float ViewFogScale;

var() sound ExtinguishedSound;

var int DamageTimeLeft, OnFireTimeCount;
var Effects MyEffect;

replication
{
	reliable if (Role == ROLE_Authority)
		MyEffect;
}

state Activated
{
	function BeginState()
	{
		super.BeginState();

		if (Owner.IsA('PlayerPawn'))
			playerpawn(Owner).ClientAdjustGlow(ViewFogScale, ViewFog);

		if (MyEffect == None)
			//MyEffect = spawn(class'WFOnFireEffect', Owner,, Owner.Location, Owner.Rotation);
			MyEffect = spawn(class'WFFlameGenerator', Owner,, Owner.Location, Owner.Rotation);

		DamageTimeLeft = DamageTime;
		OnFireTime *= ScaleFactor;
		SetTimer(1.0, true);
	}

	function Timer()
	{
		local ZoneInfo OwnerZone;

		OwnerZone = Owner.Region.Zone;
		if (OwnerZone.bWaterZone)
		{
			if (OwnerZone.DamageType == '')
			{
				// player in water zone so put out flames
				SetTimer(0.0, false);
				Owner.PlaySound(ExtinguishedSound);
				pawn(Owner).ClientMessage(ExpireMessage, 'Critical');
				Destroy();
				return;
			}
			// TODO: maybe have flames cause explosion for slime?
			/*else if (ZoneDamageType == 'Corroded')
			{
			}*/
		}

		if (OnFireTime > 0)
		{
			OnFireTimeCount++;
			if (OnFireTimeCount > OnFireTime)
			{
				UsedUp();
				return;
			}
		}

		if (DamageTime > 0)
		{
			DamageTimeLeft--;
			if (DamageTimeLeft <= 0)
			{
				// damage player
				Owner.TakeDamage(DamageAmount, StatusInstigator, vect(0,0,0), vect(0,0,0), DamageType);
				DamageTimeLeft = DamageTime;
			}
		}
	}

	function EndState()
	{
		if (Owner.IsA('PlayerPawn'))
			playerpawn(Owner).ClientAdjustGlow(ViewFogScale*-1.0, ViewFog*-1.0);
		super.EndState();
	}
}

simulated function Destroyed()
{
	if (MyEffect != None)
		MyEffect.Destroy();
	super.Destroyed();
}

defaultproperties
{
	PickupMessage="You are on fire!"
	ExpireMessage="You are no longer on fire."
	OnFireTime=5
	DamageTime=1
	DamageAmount=5
	DamageType=OnFireStatus
	ExtinguishedSound=sound'Vapour2'
	ViewFog=(X=250.000000,Y=0.000000,Z=0.000000)
	ViewFogScale=-0.250000
	StatusID=5
	StatusType="OnFire"
	DeathMessage="%o was killed by %k's flaming death."
}