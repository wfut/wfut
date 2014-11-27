//=============================================================================
// WFBioRifle.
//=============================================================================
class WFBioRifle extends WFWeapon;

var float ChargeSize, Count;
var bool bBurst;
var WFGasStreamGen GasStream;

simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;
	if ( (Owner != None) && (VSize(Owner.Velocity) > 10) )
		PlayAnim('Walking',0.3,0.3);
	else
		TweenAnim('Still', 1.0);
	Enable('AnimEnd');
}

function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist;
	local bool bRetreating;
	local vector EnemyDir;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;
	bUseAltMode = 0;
	if ( Pawn(Owner).Enemy == None )
		return AIRating;

	EnemyDir = Pawn(Owner).Enemy.Location - Owner.Location;
	EnemyDist = VSize(EnemyDir);
	if ( EnemyDist > 1400 )
		return 0;

	bRetreating = ( ((EnemyDir/EnemyDist) Dot Owner.Velocity) < -0.6 );
	if ( (EnemyDist > 600) && (EnemyDir.Z > -0.4 * EnemyDist) )
	{
		// only use if enemy not too far and retreating
		if ( !bRetreating )
			return 0;

		return AIRating;
	}

	bUseAltMode = int( FRand() < 0.3 );

	if ( bRetreating || (EnemyDir.Z < -0.7 * EnemyDist) )
		return (AIRating + 0.18);
	return AIRating;
}

// return delta to combat style
function float SuggestAttackStyle()
{
	return -0.3;
}

function float SuggestDefenseStyle()
{
	return -0.4;
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X,Y,Z;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustToss(ProjSpeed, Start, 0, True, (bWarn || (FRand() < 0.4)));
	return Spawn(ProjClass,,, Start,AdjustedAim);
}

simulated function PlayAltFiring()
{
	PlayIdleAnim();
}

///////////////////////////////////////////////////////

simulated function PlayAltBurst()
{
	if ( Owner.IsA('PlayerPawn') )
		PlayerPawn(Owner).ClientInstantFlash( InstFlash, InstFog);
	PlayOwnedSound(FireSound, SLOT_Misc, 1.7*Pawn(Owner).SoundDampening);	//shoot goop
	PlayAnim('Fire',0.4, 0.05);
}

simulated function PlayFiring()
{
	PlayOwnedSound(AltFireSound, SLOT_None, 1.7*Pawn(Owner).SoundDampening);	//fast fire goop
	//LoopAnim('Fire',0.65 + 0.4 * FireAdjust, 0.05);
	LoopAnim('Fire',0.5 + 0.35 * FireAdjust, 0.05);
}

// -----------------------

function AltFire( float Value )
{
	if (!WeaponActive())
		return;

	// ammocheck
	if ( (AmmoType == None) && (AmmoName != None) )
		GiveAmmo(Pawn(Owner));

	if ((GetStateName() == 'AltFiring') || AmmoType.UseAmmo(1))
	{
		NotifyFired();
		GotoState ('AltFiring');
		bPointing=True;
		bCanClientFire = true;
		ClientAltFire( value );
	}
}

state AltFiring
{
ignores AnimEnd;

	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function BeginState()
	{
		count = 0;
		if (GasStream == None)
		{
			GasStream = spawn(class'WFGasStreamGen', self,, Owner.Location);
			GasStream.Instigator = Instigator;
			if ( FireOffset.Y == 0 )
				GasStream.bCenter = true;
		}
	}

	function Tick(float DeltaTime)
	{
		count += DeltaTime;
		if (count > 0.2)
		{
			count = 0;
			AmmoType.UseAmmo(1);
		}

		if (Owner==None)
		{
			GotoState('Pickup');
			return;
		}

		if (Owner.Region.Zone.bWaterZone || (Pawn(Owner).bAltFire == 0) || (AmmoType.AmmoAmount <= 0))
			Finish();
	}

	// Finish a firing sequence
	function EndState()
	{
		count = 0;
		if (GasStream != None)
		{
			GasStream.Destroy();
			GasStream = None;
		}
	}
}

function Destroyed()
{
	if (GasStream != None)
		GasStream.Destroy();
	super.Destroyed();
}

simulated function bool ClientAltFire( float Value )
{
	if ( bCanClientFire && ((Role == ROLE_Authority) || (AmmoType == None) || (AmmoType.AmmoAmount > 0)) )
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
			GotoState('ClientFiring');
		return true;
	}
	return false;
}

state ClientAltFiring
{
	simulated function AnimEnd()
	{
	}
	simulated function Tick(float DeltaTime)
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
		//else if ( Pawn(Owner).bAltFire != 0 )
		//	Global.ClientAltFire(0);
		else if ( Pawn(Owner).bAltFire == 0 )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}
}


defaultproperties
{
     WeaponDescription="Classification: Toxic Rifle\n\nPrimary Fire: Wads of Tarydium byproduct are lobbed at a medium rate of fire.\n\nSecondary Fire: When trigger is held down, the BioRifle will create a much larger wad of byproduct. When this wad is launched, it will burst into smaller wads which will adhere to any surfaces.\n\nTechniques: Byproducts will adhere to walls, floors, or ceilings. Chain reactions can be caused by covering entryways with this lethal green waste."
     InstFlash=-0.150000
     InstFog=(X=139.000000,Y=218.000000,Z=72.000000)
     AmmoName=Class'Botpack.BioAmmo'
     PickupAmmoCount=25
     bAltWarnTarget=True
     bRapidFire=True
     FiringSpeed=1.000000
     FireOffset=(X=12.000000,Y=-11.000000,Z=-6.000000)
     ProjectileClass=Class'WFBioRifleGel'
     AltProjectileClass=Class'WFBioRifleGlob'
     AIRating=0.600000
     RefireRate=0.900000
     AltRefireRate=0.700000
     FireSound=Sound'UnrealI.BioRifle.GelShot'
     AltFireSound=Sound'UnrealI.BioRifle.GelShot'
     CockingSound=Sound'UnrealI.BioRifle.GelLoad'
     SelectSound=Sound'UnrealI.BioRifle.GelSelect'
     DeathMessage="%o drank a glass of %k's dripping green load."
     NameColor=(R=0,B=0)
     AutoSwitchPriority=4
     InventoryGroup=4
     PickupMessage="You got the GES BioRifle."
     ItemName="GES Bio Rifle"
     PlayerViewOffset=(X=1.700000,Y=-0.850000,Z=-0.950000)
     PlayerViewMesh=LodMesh'Botpack.BRifle2'
     BobDamping=0.972000
     PickupViewMesh=LodMesh'Botpack.BRifle2Pick'
     ThirdPersonMesh=LodMesh'Botpack.BRifle23'
     StatusIcon=Texture'WFMedia.WeaponBioGun'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseBio'
     Mesh=LodMesh'Botpack.BRifle2Pick'
     bNoSmooth=False
     CollisionHeight=19.000000
}
