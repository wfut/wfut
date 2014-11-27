class WFTeslaCoil extends WFWeapon;

var float Angle, PriCount, AltCount;
var PBolt PlasmaBeam;
var() sound DownSound;

var float LastShake;
var() float ShakeTime;
var() float ShakeMag;

var() int PriAmmoUsed;
var() int AltAmmoUsed;

var float PriAmmoRate;
var float AltAmmoRate;

simulated event RenderOverlays( canvas Canvas )
{
	Texture'Ammoled'.NotifyActor = Self;
	Super.RenderOverlays(Canvas);
	Texture'Ammoled'.NotifyActor = None;
}

simulated function Destroyed()
{
	if ( PlasmaBeam != None )
		PlasmaBeam.Destroy();

	Super.Destroyed();
}

simulated function AnimEnd()
{
	if ( (Level.NetMode == NM_Client) && (Mesh != PickupViewMesh) )
	{
		if ( AnimSequence == 'SpinDown' )
			AnimSequence = 'Idle';
		PlayIdleAnim();
	}
}
// set which hand is holding weapon
function setHand(float Hand)
{
	if ( Hand == 2 )
	{
		FireOffset.Y = 0;
		bHideWeapon = true;
		if ( PlasmaBeam != None )
			PlasmaBeam.bCenter = true;
		return;
	}
	else
		bHideWeapon = false;
	PlayerViewOffset = Default.PlayerViewOffset * 100;
	if ( Hand == 1 )
	{
		if ( PlasmaBeam != None )
		{
			PlasmaBeam.bCenter = false;
			PlasmaBeam.bRight = false;
		}
		FireOffset.Y = Default.FireOffset.Y;
		Mesh = mesh(DynamicLoadObject("Botpack.PulseGunL", class'Mesh'));
	}
	else
	{
		if ( PlasmaBeam != None )
		{
			PlasmaBeam.bCenter = false;
			PlasmaBeam.bRight = true;
		}
		FireOffset.Y = -1 * Default.FireOffset.Y;
		Mesh = mesh'PulseGunR';
	}
}

// return delta to combat style
function float SuggestAttackStyle()
{
	local float EnemyDist;

	EnemyDist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
	if ( EnemyDist < 1000 )
		return 0.4;
	else
		return 0;
}

function float RateSelf( out int bUseAltMode )
{
	local Pawn P, Other;
	local float Dist;
	local int Count;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;

	P = Pawn(Owner);

	// don't use if too far away from enemy player
	if (p.Enemy != None)
	{
		Dist = VSize(P.Enemy.Location - P.Location);
		if (Dist > 700)
			return 0;
	}

	if ( (P.Enemy == None) || (Owner.IsA('Bot') && Bot(Owner).bQuickFire) )
	{
		bUseAltMode = 0;
		return AIRating;
	}

	if ( P.Enemy.IsA('StationaryPawn') )
	{
		bUseAltMode = 0;
		return (AIRating + 0.4);
	}
	else
	{
		// use alt mode if another enemy player within range of current enemy
		foreach VisibleCollidingActors(class'Pawn', Other, 300.0, P.Enemy.Location, true)
		{
			if ( (Other != None) && (Other != P) && (!Other.bIsPlayer
				|| (!class'WFDisguise'.static.IsDisguised(Other.PlayerReplicationInfo)
					&& (Other.PlayerReplicationInfo.Team != P.PlayerReplicationInfo.Team))) )
			{
				bUseAltMode = 1;
				break;
			}
		}
	}

	AIRating *= FMin(Pawn(Owner).DamageScaling, 1.5);
	return AIRating;
}

simulated function PlayFiring()
{
	AmbientSound = AltFireSound;
	if ( (AnimSequence == 'BoltLoop') || (AnimSequence == 'BoltStart') )
		PlayAnim( 'boltloop');
	else
		PlayAnim( 'boltstart' );
}

simulated function PlayAltFiring()
{
	AmbientSound = AltFireSound;
	if ( (AnimSequence == 'BoltLoop') || (AnimSequence == 'BoltStart') )
		PlayAnim( 'boltloop');
	else
		PlayAnim( 'boltstart' );
}

function Fire( float Value )
{
	if (!WeaponActive())
		return;

	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.UseAmmo(PriAmmoUsed))
	{
		NotifyFired();
		GotoState('NormalFire');
		bCanClientFire = true;
		bPointing=True;
		Pawn(Owner).PlayRecoil(FiringSpeed);
		ClientFire(value);
		if ( PlasmaBeam == None )
		{
			PlasmaBeam = PBolt(ProjectileFire(ProjectileClass, AltProjectileSpeed, bWarnTarget));
			if ( FireOffset.Y == 0 )
				PlasmaBeam.bCenter = true;
			else if ( Mesh == mesh'PulseGunR' )
				PlasmaBeam.bRight = false;
		}
	}
}

function AltFire( float Value )
{
	if (!WeaponActive())
		return;

	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.UseAmmo(AltAmmoUsed))
	{
		NotifyFired();
		GotoState('AltFiring');
		bCanClientFire = true;
		bPointing=True;
		Pawn(Owner).PlayRecoil(FiringSpeed);
		ClientAltFire(value);
		if ( PlasmaBeam == None )
		{
			PlasmaBeam = PBolt(ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget));
			if ( FireOffset.Y == 0 )
				PlasmaBeam.bCenter = true;
			else if ( Mesh == mesh'PulseGunR' )
				PlasmaBeam.bRight = false;
		}
	}
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	local Color C;
	local string Temp;

	Temp = String(AmmoType.AmmoAmount);

	while(Len(Temp) < 3) Temp = "0"$Temp;

	Tex.DrawTile( 30, 100, (Min(AmmoType.AmmoAmount,AmmoType.Default.AmmoAmount)*196)/AmmoType.Default.AmmoAmount, 10, 0, 0, 1, 1, Texture'AmmoCountBar', False );

	if(AmmoType.AmmoAmount < 10)
	{
		C.R = 255;
		C.G = 0;
		C.B = 0;
	}
	else
	{
		C.R = 0;
		C.G = 0;
		C.B = 255;
	}

	Tex.DrawColoredText( 56, 14, Temp, Font'LEDFont', C );
}

///////////////////////////////////////////////////////
state ClientFiring
{
	simulated function AnimEnd()
	{
		if ( AmmoType.AmmoAmount <= 0 )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner) == None )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( Pawn(Owner).bAltFire != 0 )
			LoopAnim('BoltLoop');
		else if ( Pawn(Owner).bFire != 0 )
			LoopAnim('BoltLoop');
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}
}

state NormalFire
{
	ignores AnimEnd;

	function Tick(float DeltaTime)
	{
		local Pawn P;

		P = Pawn(Owner);
		if ( P == None )
		{
			GotoState('Pickup');
			return;
		}
		if ( (P.bFire == 0) || (P.IsA('Bot')
					&& ((P.Enemy == None) || (Level.TimeSeconds - Bot(P).LastSeenTime > 5))) )
		{
			P.bFire = 0;
			Finish();
			return;
		}

		PriCount += Deltatime;
		if ( PriCount > PriAmmoRate )
		{
			if ( Owner.IsA('PlayerPawn') )
				PlayerPawn(Owner).ClientInstantFlash( InstFlash,InstFog);
			if ( Affector != None )
				Affector.FireEffect();
			PriCount -= PriAmmoRate;
			if ( !AmmoType.UseAmmo(PriAmmoUsed) )
			{
				AmmoType.AmmoAmount = 0;
				Finish();
			}
		}
	}

	function EndState()
	{
		AmbientGlow = 0;
		AmbientSound = None;
		if ( PlasmaBeam != None )
		{
			PlasmaBeam.Destroy();
			PlasmaBeam = None;
		}
		Super.EndState();
	}

Begin:
	AmbientGlow = 200;
	FinishAnim();
	LoopAnim( 'boltloop');
}

simulated function PlaySpinDown()
{
	if ( (Mesh != PickupViewMesh) && (Owner != None) )
	{
		PlayAnim('Spindown', 1.0, 0.0);
		Owner.PlayOwnedSound(DownSound, SLOT_None,1.0*Pawn(Owner).SoundDampening);
	}
}

///////////////////////////////////////////////////////////////
state ClientAltFiring
{
	simulated function AnimEnd()
	{
		if ( AmmoType.AmmoAmount <= 0 )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner) == None )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( Pawn(Owner).bAltFire != 0 )
			LoopAnim('BoltLoop');
		else if ( Pawn(Owner).bFire != 0 )
			LoopAnim('BoltLoop');
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}
}

state AltFiring
{
	ignores AnimEnd;

	function Tick(float DeltaTime)
	{
		local Pawn P;

		P = Pawn(Owner);
		if ( P == None )
		{
			GotoState('Pickup');
			return;
		}
		if ( (P.bAltFire == 0) || (P.IsA('Bot')
					&& ((P.Enemy == None) || (Level.TimeSeconds - Bot(P).LastSeenTime > 5))) )
		{
			P.bAltFire = 0;
			Finish();
			return;
		}

		AltCount += Deltatime;
		if ( AltCount > AltAmmoRate )
		{
			if ( Owner.IsA('PlayerPawn') )
				PlayerPawn(Owner).ClientInstantFlash( InstFlash,InstFog);
			if ( Affector != None )
				Affector.FireEffect();
			AltCount -= AltAmmoRate;
			if ( !AmmoType.UseAmmo(AltAmmoUsed) )
			{
				AmmoType.AmmoAmount = 0;
				Finish();
			}
			/*if ((Level.TimeSeconds - LastShake) > ShakeTime)
			{
				LastShake = Level.TimeSeconds;
				ShakeOwner();
			}*/
		}
	}

	function EndState()
	{
		AmbientGlow = 0;
		AmbientSound = None;
		if ( PlasmaBeam != None )
		{
			PlasmaBeam.Destroy();
			PlasmaBeam = None;
		}
		Super.EndState();
	}

	/*function ShakeOwner()
	{
		local vector throwVect;
		local PlayerPawn P;

		throwVect = 0.15 * ShakeMag * VRand();
		throwVect.Z = FMax(Abs(ThrowVect.Z), 120);

		if ( Owner.IsA('PlayerPawn') )
		{
			P = PlayerPawn(Owner);
			P.BaseEyeHeight = FMin(P.Default.BaseEyeHeight, P.BaseEyeHeight * (0.5 + FRand()));
			P.ShakeView(ShakeTime, ShakeMag, 0.015 * ShakeMag);
		}
		if ( Owner.bIsPawn && (Owner.Physics != PHYS_Falling) )
			Pawn(Owner).AddVelocity(throwVect);

	}*/

Begin:
	AmbientGlow = 200;
	FinishAnim();
	LoopAnim( 'boltloop');
}

state Idle
{
Begin:
	bPointing=False;
	if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if ( Pawn(Owner).bFire!=0 ) Fire(0.0);
	if ( Pawn(Owner).bAltFire!=0 ) AltFire(0.0);

	Disable('AnimEnd');
	PlayIdleAnim();
}

///////////////////////////////////////////////////////////
simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;

	if ( (AnimSequence == 'BoltLoop') || (AnimSequence == 'BoltStart') )
		PlayAnim('BoltEnd');
	else if ( AnimSequence != 'SpinDown' )
		TweenAnim('Idle', 0.1);
}

simulated function TweenDown()
{
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else
		TweenAnim('Down', 0.26);
}

defaultproperties
{
     DownSound=Sound'Botpack.PulseGun.PulseDown'
     WeaponDescription="Classification: Plasma Rifle\n\nPrimary Fire: Medium sized, fast moving plasma balls are fired at a fast rate of fire.\n\nSecondary Fire: A bolt of green lightning is expelled for 100 meters, which will shock all opponents.\n\nTechniques: Firing and keeping the secondary fire's lightning on an opponent will melt them in seconds."
     InstFlash=-0.150000
     InstFog=(X=139.000000,Y=218.000000,Z=72.000000)
     AmmoName=Class'Botpack.PAmmo'
     PickupAmmoCount=60
     bRapidFire=True
     FireOffset=(X=15.000000,Y=-15.000000,Z=2.000000)
     ProjectileClass=Class'WFTeslaStarterBolt'
     AltProjectileClass=Class'WFTeslaStarterBolt'
     //AltProjectileClass=Class'WFTeslaChainStarterBolt'
     shakemag=135.000000
     shakevert=8.000000
     AIRating=0.700000
     RefireRate=0.990000
     AltRefireRate=0.990000
     FireSound=Sound'Botpack.PulseGun.PulseBolt'
     AltFireSound=Sound'Botpack.PulseGun.PulseBolt'
     SelectSound=Sound'Botpack.PulseGun.PulsePickup'
     MessageNoAmmo=" has no Plasma."
     DeathMessage="%o ate %k's burning plasma death."
     NameColor=(R=128,B=128)
     FlashLength=0.020000
     AutoSwitchPriority=3
     InventoryGroup=3
     PickupMessage="You got a Tesla Coil"
     ItemName="Tesla Coil"
     PlayerViewOffset=(X=1.500000,Z=-2.000000)
     PlayerViewMesh=LodMesh'Botpack.PulseGunR'
     PickupViewMesh=LodMesh'Botpack.PulsePickup'
     ThirdPersonMesh=LodMesh'Botpack.PulseGun3rd'
     ThirdPersonScale=0.400000
     StatusIcon=Texture'WFMedia.WeaponTesla'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzPF3'
     MuzzleFlashScale=0.400000
     MuzzleFlashTexture=Texture'Botpack.Skins.MuzzyPulse'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UsePulse'
     Mesh=LodMesh'Botpack.PulsePickup'
     bNoSmooth=False
     SoundRadius=64
     SoundVolume=255
     CollisionRadius=32.000000
     ShakeTime=0.5
     ShakeMag=2000
     PriAmmoUsed=1
     AltAmmoUsed=1
     PriAmmoRate=0.1
     AltAmmoRate=0.1
}
