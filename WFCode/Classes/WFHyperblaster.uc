//=============================================================================
// WFHyperblaster.
//=============================================================================
class WFHyperblaster extends WFWeapon;

var() float HitDamage;
var() float AltHitDamage;
var() int AltAmmoUsed;

var() float RecoilKick;
var() float RecoilLift;

var() bool bAltFireDropsFlag;

// -- AI related --
function float RateSelf( out int bUseAltMode )
{
	if ( AmmoType.AmmoAmount <=0 )
		return -2;

	if ((AmmoType != None) && (AmmoType.AmmoAmount <= AltAmmoUsed))
		bUseAltMode = 0;

	return AIRating;
}


// -- animation --
simulated function PlayFiring()
{
	PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
	//PlayAnim('Fire1', 0.50 + 0.50 * FireAdjust,0.05);
	PlayAnim('Fire1', 0.25 + 0.25 * FireAdjust,0.05);
}

simulated function PlayAltFiring()
{
	PlayOwnedSound(AltFireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
	PlayAnim('Fire1', 0.10 + 0.10 * FireAdjust,0.05);
}

simulated function PlayIdleAnim()
{
	if ( Mesh != PickupViewMesh )
		LoopAnim('Still',0.04,0.3);
}



// -- fire --
function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
		+ Accuracy * (FRand() - 0.5 ) * Z * 1000 ;

	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);
	EndTrace += (10000 * vector(AdjustedAim));

	Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local int i;
	local PlayerPawn PlayerOwner;

	if (Other==None)
	{
		HitNormal = -X;
		HitLocation = Owner.Location + X*1000.0;
	}

	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner != None )
		PlayerOwner.ClientInstantFlash( -0.4, vect(450, 190, 650));
	SpawnEffect(HitLocation, Owner.Location + CalcDrawOffset() + (FireOffset.X + 20) * X + FireOffset.Y * Y + FireOffset.Z * Z);

	//Spawn(class'WF_SuperRing',,, HitLocation+HitNormal*8,rotator(HitNormal));
	//Spawn(class'ut_RingExplosion5',,, HitLocation+HitNormal*8,rotator(HitNormal));
	if (Other != none)
		Spawn(class'WFHyperWallHit',,, HitLocation+HitNormal*8,rotator(HitNormal));

	if ( (Other != self) && (Other != Owner) && (Other != None) )
		Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, 10000.0*X, MyDamageType);
}

function SpawnEffect(vector HitLocation, vector SmokeLocation)
{
	local WFHyperBeam Smoke,shock;
	local Vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;

	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/135.0;
	if ( NumPoints < 1 )
		return;
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);

	Smoke = Spawn(class'WFHyperBeam',,,SmokeLocation,SmokeRotation);
	Smoke.MoveAmount = DVector/NumPoints;
	Smoke.NumPuffs = NumPoints - 1;
}

// -- alt fire --
function AltFire( float Value )
{
	local pawn PawnOwner;
	if (!WeaponActive())
		return;

	PawnOwner = pawn(Owner);
	if ( (AmmoType == None) && (AmmoName != None) )
	{
		// ammocheck
		GiveAmmo(PawnOwner);
	}
	if (AmmoType.UseAmmo(AltAmmoUsed))
	{
		GotoState('AltFiring');
		if (bAltFireDropsFlag && (PawnOwner.PlayerReplicationInfo.HasFlag != None))
		{
			PawnOwner.ClientMessage("You dropped the flag!", 'CriticalEvent');
			PawnOwner.PlayerReplicationInfo.HasFlag.Drop(0.25 * PawnOwner.Velocity);
		}
		bPointing=True;
		bCanClientFire = true;
		ClientAltFire(Value);
		if ( bRapidFire || (FiringSpeed > 0) )
			PawnOwner.PlayRecoil(FiringSpeed);
		if ( bAltInstantHit )
			TraceAltFire(0.0);
		else
			ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
	}
}

// Finish a firing sequence
function Finish()
{
	local Pawn PawnOwner;
	local bool bForce, bForceAlt;

	bForce = bForceFire;
	bForceAlt = bForceAltFire;
	bForceFire = false;
	bForceAltFire = false;

	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}

	PawnOwner = Pawn(Owner);
	if ( PawnOwner == None )
		return;
	if ( PlayerPawn(Owner) == None )
	{
		if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		{
			PawnOwner.StopFiring();
			PawnOwner.SwitchToBestWeapon();
			if ( bChangeWeapon )
				GotoState('DownWeapon');
		}
		else if ( (PawnOwner.bFire != 0) && (FRand() < RefireRate) )
			Global.Fire(0);
		else if ( (PawnOwner.bAltFire != 0) && (FRand() < AltRefireRate) )
			Global.AltFire(0);
		else
		{
			PawnOwner.StopFiring();
			GotoState('Idle');
		}
		return;
	}
	if ( !WeaponActive() || ((AmmoType != None) && (AmmoType.AmmoAmount<=0)) || (PawnOwner.Weapon != self) )
		GotoState('Idle');
	else if ( (PawnOwner.bFire!=0) || bForce )
		Global.Fire(0);
	else if ( ((PawnOwner.bAltFire!=0) || bForceAlt) && (AmmoType.AmmoAmount>=AltAmmoUsed))
		Global.AltFire(0);
	else
		GotoState('Idle');
}

function TraceAltFire(float Accuracy)
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local vector KickVel;
	local actor Other;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
		+ Accuracy * (FRand() - 0.5 ) * Z * 1000 ;

	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);
	EndTrace += (10000 * vector(AdjustedAim));

	Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
	ProcessTraceAltHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
	KickVel = (RecoilKick*-X) + vect(0,0,1)*RecoilLift;
	KickVel.Z = FClamp(KickVel.Z, -RecoilLift, RecoilLift);
	pawn(Owner).AddVelocity(KickVel);
}

function ProcessTraceAltHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	if (Other==None)
	{
		HitNormal = -X;
		HitLocation = Owner.Location + X*10000.0;
	}

	SpawnAltEffect(HitLocation, Owner.Location + CalcDrawOffset() + (FireOffset.X + 20) * X + FireOffset.Y * Y + FireOffset.Z * Z);

	Spawn(class'ut_SuperRing2',,, HitLocation+HitNormal*8,rotator(HitNormal));

	if ( (Other != self) && (Other != Owner) && (Other != None) )
		Other.TakeDamage(AltHitDamage, Pawn(Owner), HitLocation, 60000.0*X, MyDamageType);
}

function SpawnAltEffect(vector HitLocation, vector SmokeLocation)
{
	local ShockBeam Smoke,shock;
	local Vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;

	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/135.0;
	if ( NumPoints < 1 )
		return;
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);

	//Smoke = Spawn(class'SuperShockBeam',,,SmokeLocation,SmokeRotation);
	Smoke = Spawn(class'WFHyperBeamAlt',,,SmokeLocation,SmokeRotation);
	Smoke.MoveAmount = DVector/NumPoints;
	Smoke.NumPuffs = NumPoints - 1;
}

simulated function bool ClientAltFire( float Value )
{
	if ( bCanClientFire && ((Role == ROLE_Authority) || (AmmoType == None) || (AmmoType.AmmoAmount >= AltAmmoUsed)) )
	{
		if ( (PlayerPawn(Owner) != None)
			&& ((Level.NetMode == NM_Standalone) || PlayerPawn(Owner).Player.IsA('ViewPort')) )
		{
			if ( InstFlash != 0.0 )
				PlayerPawn(Owner).ClientInstantFlash( InstFlash, InstFog);
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		}
		if ( Affector != None )
			Affector.FireEffect();
		PlayAltFiring();
		if ( Role < ROLE_Authority )
			GotoState('ClientAltFiring');
		return true;
	}
	return false;
}

state ClientAltFiring
{
	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None)
			|| ((AmmoType != None) && (AmmoType.AmmoAmount <= 0)) )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else if ((Pawn(Owner).bAltFire != 0) && (AmmoType.AmmoAmount >= AltAmmoUsed))
			Global.ClientAltFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}
}

state ClientFiring
{
	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None)
			|| ((AmmoType != None) && (AmmoType.AmmoAmount <= 0)) )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else if ((Pawn(Owner).bAltFire != 0) && (AmmoType.AmmoAmount >= AltAmmoUsed))
			Global.ClientAltFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}
}

defaultproperties
{
     hitdamage=25.000000
     AltHitDamage=100.000000
     AltAmmoUsed=10
     RecoilKick=250.000000
     RecoilLift=150.000000
     WeaponDescription="Classification: Energy Rifle"
     InstFlash=-0.400000
     InstFog=(Z=800.000000)
     AmmoName=Class'Botpack.ShockCore'
     PickupAmmoCount=20
     bInstantHit=True
     bAltInstantHit=True
     FiringSpeed=2.000000
     FireOffset=(X=0.000000,Y=-10.000000,Z=-8.000000)
     AltProjectileClass=Class'Botpack.ShockProj'
     MyDamageType=jolted
     AIRating=0.630000
     AltRefireRate=0.700000
     FireSound=Sound'UnrealShare.Dispersion.DispShot'
     AltFireSound=Sound'UnrealShare.ASMD.TazerFire'
     SelectSound=Sound'UnrealShare.ASMD.TazerSelect'
     DeathMessage="%k inflicted mortal damage upon %o with the %w."
     NameColor=(R=128,G=0)
     AutoSwitchPriority=3
     InventoryGroup=3
     PickupMessage="You got the Hyperblaster."
     ItemName="Hyperblaster"
     PlayerViewOffset=(X=1.2,Y=-1.35,Z=-1.1)
     PlayerViewMesh=LodMesh'hyperfirst'
     PlayerViewScale=.1
     BobDamping=0.975000
     PickupViewMesh=LodMesh'hyperpick'
     ThirdPersonMesh=LodMesh'hyperthird'
     ThirdpersonScale=.24
     StatusIcon=Texture'WFMedia.WeaponHyperblaster'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseASMD'
     Mesh=LodMesh'hyperpick'
     bNoSmooth=False
     CollisionRadius=34.000000
     CollisionHeight=8.000000
     Mass=50.000000
}
