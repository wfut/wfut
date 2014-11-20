//=============================================================================
// WFChainCannon.
//=============================================================================
class WFChainCannon extends WFWeapon;

var bool bFiredShot, bOutOfAmmo, bPlayerSlowed;
var() texture MuzzleFlashVariations[10];
var float LastShellSpawn;
var bool bUseExtraAmmo;

// damage decreases linearly from EffectiveRange to MaxRange to MinDamage
var() float EffectiveRange;
var() float MaxRange;
var() float MinDamageRange;
var() int BaseDamage;
var() int RndDamage; // added to base
var() int MinDamage;

// --- Temp Code ---
// set which hand is holding weapon
function setHand(float Hand)
{
	if ( Hand == 2 )
	{
		FireOffset.Y = 0;
		bHideWeapon = true;
		return;
	}
	else
		bHideWeapon = false;
	PlayerViewOffset = Default.PlayerViewOffset * 100;
	FireOffset.Y = Hand * Default.FireOffset.Y;
	PlayerViewOffset.Y *= Hand;
	if ( Hand == 1 )
		Mesh = mesh(DynamicLoadObject("WFMedia.chainfirstL", class'Mesh'));
	else
	{
		Mesh = mesh'chainfirst';
		if ( Hand == 0 )
		{
			PlayerViewOffset.X = Default.PlayerViewOffset.X * 95;
			PlayerViewOffset.Z = Default.PlayerViewOffset.Z * 105;
		}
	}
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	local Color C;
	local string Temp;

	Temp = String(AmmoType.AmmoAmount);

	while(Len(Temp) < 3) Temp = "0"$Temp;

	C.R = 255;
	C.G = 0;
	C.B = 0;

	Tex.DrawColoredText( 2, 10, Temp, Font'LEDFont2', C );
}

function float RateSelf( out int bUseAltMode )
{
	local float dist;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;

	if ( Pawn(Owner).Enemy == None )
	{
		bUseAltMode = 0;
		return AIRating;
	}

	/*dist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
	bUseAltMode = 1;
	if ( dist > 1200 )
	{
		if ( dist > 1700 )
			bUseAltMode = 0;
		return (AIRating * FMin(Pawn(Owner).DamageScaling, 1.5) + FMin(0.0001 * dist, 0.3));
	}
	AIRating *= FMin(Pawn(Owner).DamageScaling, 1.5);*/
	return AIRating;
}

simulated event RenderOverlays( canvas Canvas )
{
	local UT_Shellcase s;
	local vector X,Y,Z;
	local float dir;

	if ( bSteadyFlash3rd )
	{
		bMuzzleFlash = 1;
		bSetFlashTime = false;
		if ( !Level.bDropDetail )
			MFTexture = MuzzleFlashVariations[Rand(10)];
		else
			MFTexture = MuzzleFlashVariations[Rand(5)];
	}
	else
		bMuzzleFlash = 0;
	FlashY = Default.FlashY * (1.08 - 0.16 * FRand());
	if ( !Owner.IsA('PlayerPawn') || (PlayerPawn(Owner).Handedness == 0) )
		FlashO = Default.FlashO * (4 + 0.15 * FRand());
	else
		FlashO = Default.FlashO * (1 + 0.15 * FRand());
	Texture'MiniAmmoled'.NotifyActor = Self;
	Super.RenderOverlays(Canvas);
	Texture'MiniAmmoled'.NotifyActor = None;

	if ( bSteadyFlash3rd && Level.bHighDetailMode && (Level.TimeSeconds - LastShellSpawn > 0.125)
		&& (Level.Pauser=="") )
	{
		LastShellSpawn = Level.TimeSeconds;
		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);

		if ( PlayerViewOffset.Y >= 0 )
			dir = 1;
		else
			dir = -1;
		if ( Level.bHighDetailMode )
		{
			s = Spawn(class'MiniShellCase',Owner, '', Owner.Location + CalcDrawOffset() + 30 * X + (0.4 * PlayerViewOffset.Y+5.0) * Y - Z * 5);
			if ( s != None )
				s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.3+0.2)*dir*Y + (FRand()*0.3+1.0) * Z)*160);
		}
	}
}


//select_deselect functions


simulated function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',0.6,0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);
}

simulated function TweenDown()
{
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else
		PlayAnim('Down', 0.7, 0.05);
}


// --- Animation ---
simulated function PlaySpinUp()
{
	if ( Owner != None )
	{
		PlayOwnedSound(Misc1Sound, SLOT_Misc, 3.0*Pawn(Owner).SoundDampening);  //start firing, power up
		//PlayAnim('spinup',1.5, 0.05);
		//PlayAnim('spinup',0.5, 0.05);
		PlayAnim('spinup', 1.0, 0.05);
	}
}

simulated function PlaySpinDown()
{
	if ( Owner != None )
	{
		PlayOwnedSound(Misc2Sound, SLOT_Misc, 3.0*Pawn(Owner).SoundDampening);  //Finish firing, power down
		//PlayAnim('spindown',1.5, 0.05);
		//PlayAnim('spindown',0.5, 0.05);
		PlayAnim('spindown',1.0, 0.05);
	}
}

simulated function PlayFiring()
{
	PlayEffects();
	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	PlayAnim('fire',1 + 0.6 * FireAdjust, 0.05);
	AmbientGlow = 250;
	AmbientSound = FireSound;
	bSteadyFlash3rd = true;
}

simulated function PlayAltFiring()
{
	//if ( PlayerPawn(Owner) != None )
	//	PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	PlayAnim('spinidle',0.7 + 0.3 * FireAdjust, 0.05);
	AmbientGlow = 0;
	AmbientSound = AltFireSound;
	bSteadyFlash3rd = false;
}

// --- Serverside ---
function Fire( float Value )
{
	if (!WeaponActive())
		return;

	if ( (AmmoType == None) && (AmmoName != None) )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.AmmoAmount > 0)
	{
		GotoState('SpinUp');
		bPointing=True;
		bCanClientFire = true;
		ClientFire(Value);
		if ( bRapidFire || (FiringSpeed > 0) )
			Pawn(Owner).PlayRecoil(FiringSpeed);
	}
}


function AltFire( float Value )
{
	if (!WeaponActive())
		return;

	if ( (AmmoType == None) && (AmmoName != None) )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.AmmoAmount > 0)
	{
		GotoState('SpinUp');
		bPointing=True;
		bCanClientFire = true;
		ClientAltFire(Value);
		if ( bRapidFire || (FiringSpeed > 0) )
			Pawn(Owner).PlayRecoil(FiringSpeed);
	}
}

// cannon firing
state Firing
{
	function Fire(float F) { }
	function AltFire(float F) { }

	function BeginState()
	{
		PlayFiring();
		AmbientGlow = 250;
		AmbientSound = FireSound;
		bSteadyFlash3rd = true;
		if (!bPlayerSlowed)
			SlowPlayerMovement();
		Super.BeginState();
		bUseExtraAmmo = false;
	}

	function Tick( float DeltaTime )
	{
		if (Owner==None)
			AmbientSound = None;
	}

	function AnimEnd()
	{
		if (Pawn(Owner).Weapon != self) GotoState('');
		else if (Pawn(Owner).bFire!=0 && AmmoType.AmmoAmount>0)
			PlayFiring();
		else if ( Pawn(Owner).bAltFire!=0 && AmmoType.AmmoAmount>0)
			GotoState('Spinning');
		else
			GotoState('SpinDown');
	}

Begin:
	GenerateBullet();
	bUseExtraAmmo = !bUseExtraAmmo;
	Sleep(0.125);
	//Sleep(0.08);
	Goto('Begin');
}

// barrel spinning but not firing
state Spinning
{
	function Fire(float F) { }
	function AltFire(float F) { }

	function BeginState()
	{
		PlayAltFiring();
		AmbientGlow = 0;
		AmbientSound = AltFireSound;
		bSteadyFlash3rd = false;
		if (bPlayerSlowed)
			ResetPlayerMovement();
		if (!bPlayerSlowed)
			SlowPlayerMovement();
		Super.BeginState();
	}

	function Tick( float DeltaTime )
	{
		if (Owner==None)
			AmbientSound = None;
	}

	function AnimEnd()
	{
		if (Pawn(Owner).Weapon != self) GotoState('');
		else if (Pawn(Owner).bFire!=0 && AmmoType.AmmoAmount>0)
			GotoState('Firing');
		else if ( Pawn(Owner).bAltFire!=0 && AmmoType.AmmoAmount>0)
			PlayAltFiring();
		else
			GotoState('SpinDown');
	}
}

// barrel spinning up
state SpinUp
{
	function Fire(float F) { }
	function AltFire(float F) { }

	function BeginState()
	{
		PlaySpinUp();
		if (!bPlayerSlowed)
			SlowPlayerMovement();
	}

	function AnimEnd()
	{
		if (Pawn(Owner).bFire != 0)
			GotoState('Firing');
		else if (Pawn(Owner).bAltFire != 0)
			GotoState('Spinning');
		else GotoState('SpinDown');
	}
}

// barrel spinning down
state SpinDown
{
	function Fire(float F) { }
	function AltFire(float F) { }

	function BeginState()
	{
		PlaySpinDown();
		bSteadyFlash3rd = false;
		AmbientGlow = 0;
		LightType = LT_None;
		AmbientSound = None;
		if (bPlayerSlowed)
			ResetPlayerMovement();
	}

	function AnimEnd()
	{
		Finish();
	}

	function EndState()
	{
		if (bPlayerSlowed)
			ResetPlayerMovement();
	}
}

function GenerateBullet()
{
    LightType = LT_Steady;
	bFiredShot = true;
	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ClientInstantFlash( -0.2, vect(325, 225, 95));
	if ( AmmoType.UseAmmo(1) )
	{
		TraceFire(0.95);
		TraceFire(0.95);
		TraceFire(0.95);
		//TraceFire(0.95);
	}
	else
		GotoState('SpinDown');
	if (bUseExtraAmmo)
		AmmoType.UseAmmo(1); // extra ammo usage
}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z, AimDir;
	local actor Other;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
		+ Accuracy * (FRand() - 0.5 ) * Z * 1000;
	AimDir = vector(AdjustedAim);
	EndTrace += (MaxRange * AimDir);
	Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);

	/*Count++;
	if ( Count == 4 )
	{
		Count = 0;
		if ( VSize(HitLocation - StartTrace) > 250 )
			Spawn(class'MTracer',,, StartTrace + 96 * AimDir,rotator(EndTrace - StartTrace));
	}*/
	ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
}

//push is here...default was 500

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local int rndDam;
	local float mo, dist, dmgamt, dscale;

	if (Other == Level)
		Spawn(class'UT_LightWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
	else if ( (Other!=self) && (Other!=Owner) && (Other != None) )
	{
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
		else
			Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);

		if ( Other.IsA('Bot') && (FRand() < 0.2) )
			Pawn(Other).WarnTarget(Pawn(Owner), 500, X);
		rndDam = 9 + Rand(6);
		if ( FRand() < 0.2 )
			X *= 2.5;

		dist = VSize(HitLocation - Owner.Location);
		if (dist > MinDamageRange)
			dmgamt = MinDamage;
		else if (dist > EffectiveRange)
		{
			dscale = 1.0 - ((dist-EffectiveRange)/(MinDamageRange-EffectiveRange));
			dmgamt = int(FClamp(float(rndDam)*dscale, MinDamage, rndDam));
			log("-- dist: "$dist$"   dscale: "$dscale$"   rdnDam: "$rndDam$"   dmgamt: "$dmgamt);
		}
		else dmgamt = rndDam;
		mo = FClamp(650.0*(1.0 - (dist/2500.0)), 275.0, 650.0);
		Other.TakeDamage(dmgamt, Pawn(Owner), HitLocation, 2.0*rndDam*mo*X, MyDamageType);
		//Other.TakeDamage(rndDam, Pawn(Owner), HitLocation, 2.0*rndDam*500.0*X, MyDamageType);
		//Other.TakeDamage(rndDam, Pawn(Owner), HitLocation, 2.0*rndDam*275.0*X, MyDamageType);
	}
}

function SlowPlayerMovement()
{
	local pawn PawnOwner;
	//Log("-- slowing player");
	if (bPlayerSlowed)
		return;
	PawnOwner = pawn(owner);
	bPlayerSlowed = true;
	PawnOwner.GroundSpeed *= 0.25;
	PawnOwner.WaterSpeed *= 0.25;
	PawnOwner.AirSpeed *= 0.25;
	PawnOwner.AccelRate *= 0.25;
	//Log("-- player slowed");
}

function WeaponEvent(name EventType)
{
	if (EventType == 'PlayerMovementReset')
	{
		if (bPlayerSlowed)
		{
			bPlayerSlowed = false;
			SlowPlayerMovement();
		}
	}
}

function ResetPlayerMovement()
{
	local pawn PawnOwner;
	local float SpeedScaling;
	local class<WFS_PlayerClassInfo> PCI;
	local inventory status;

	if (!bPlayerSlowed)
		return;

	if (DeathMatchPlus(Level.Game).bMegaSpeed)
		SpeedScaling = 1.4;
	else SpeedScaling = 1.0;

	PawnOwner = pawn(Owner);
	if (PawnOwner != None)
	{
		PCI = class'WFS_PlayerClassInfo'.static.GetPCIFor(PawnOwner);

		PawnOwner.GroundSpeed = PawnOwner.default.GroundSpeed * SpeedScaling;
		PawnOwner.WaterSpeed = PawnOwner.default.WaterSpeed * SpeedScaling;
		PawnOwner.AirSpeed = PawnOwner.default.AirSpeed * SpeedScaling;
		PawnOwner.AccelRate = PawnOwner.default.AccelRate * SpeedScaling;

		if (PCI != None)
			PCI.static.ModifyPlayer(PawnOwner);

		status = PawnOwner.FindInventoryType(class'WFStatusTranquilised');
		if (status != None)
			WFStatusTranquilised(status).SetPlayerMovement();

		status = PawnOwner.FindInventoryType(class'WFStatusLegDamage');
		if (status != None)
			WFStatusLegDamage(status).SetPlayerMovement();
	}
	bPlayerSlowed = false;
}

function DropFrom(vector StartLocation)
{
	if (bPlayerSlowed)
		ResetPlayerMovement();
	AmbientSound = None;
	super.DropFrom(StartLocation);
}

function Destroyed()
{
	if (bPlayerSlowed)
		ResetPlayerMovement();
	super.Destroyed();
}

// --- Clientside ---
simulated function bool ClientFire( float Value )
{
	if ( bCanClientFire && ((Role == ROLE_Authority) || (AmmoType == None) || (AmmoType.AmmoAmount > 0)) )
	{
		/*if ( (PlayerPawn(Owner) != None)
			&& ((Level.NetMode == NM_Standalone) || PlayerPawn(Owner).Player.IsA('ViewPort')) )
		{
			if ( InstFlash != 0.0 )
				PlayerPawn(Owner).ClientInstantFlash( InstFlash, InstFog);
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		}
		if ( Affector != None )
			Affector.FireEffect();*/
		//PlayFiring();
		if ( Role < ROLE_Authority )
			GotoState('ClientSpinUp');
		return true;
	}
	return false;
}

simulated function bool ClientAltFire( float Value )
{
	if ( bCanClientFire && ((Role == ROLE_Authority) || (AmmoType == None) || (AmmoType.AmmoAmount > 0)) )
	{
		/*if ( (PlayerPawn(Owner) != None)
			&& ((Level.NetMode == NM_Standalone) || PlayerPawn(Owner).Player.IsA('ViewPort')) )
		{
			if ( InstFlash != 0.0 )
				PlayerPawn(Owner).ClientInstantFlash( InstFlash, InstFog);
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		}
		if ( Affector != None )
			Affector.FireEffect();*/
		//PlayAltFiring();
		if ( Role < ROLE_Authority )
			GotoState('ClientSpinUp');
		return true;
	}
	return false;
}

// cannon firing
state ClientFiring
{
	simulated function bool ClientFire(float Value) { return false; }
	simulated function bool ClientAltFire(float Value) { return false; }

	simulated function BeginState()
	{
		PlayFiring();
		bSteadyFlash3rd = true;
		AmbientSound = AltFireSound;
	}

	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None)
			|| ((AmmoType != None) && (AmmoType.AmmoAmount <= 0)) )
			GotoState('ClientSpinDown');
		else if ( !bCanClientFire )
			GotoState('ClientSpinDown');
		else if ( Pawn(Owner).bFire != 0 )
			PlayFiring();
		else if ( Pawn(Owner).bAltFire != 0 )
			GotoState('ClientSpinning');
		else
			GotoState('ClientSpinDown');
	}
}

// barrel spinning but not firing
state ClientSpinning
{
	simulated function bool ClientFire(float Value) { return false; }
	simulated function bool ClientAltFire(float Value) { return false; }

	simulated function BeginState()
	{
		PlayAltFiring();
		//bSteadyFlash3rd = true;
		AmbientSound = AltFireSound;
	}

	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None)
			|| ((AmmoType != None) && (AmmoType.AmmoAmount <= 0)) )
			GotoState('ClientSpinDown');
		else if ( !bCanClientFire )
			GotoState('ClientSpinDown');
		else if ( Pawn(Owner).bFire != 0 )
			GotoState('ClientFiring');
		else if ( Pawn(Owner).bAltFire != 0 )
			PlayAltFiring();
		else
			GotoState('ClientSpinDown');
	}
}

// barrel spinning up
state ClientSpinUp
{
	simulated function bool ClientFire(float Value) { return false; }
	simulated function bool ClientAltFire(float Value) { return false; }

	simulated function BeginState()
	{
		PlaySpinUp();
	}

	simulated function AnimEnd()
	{
		if (Pawn(Owner).bFire != 0)
			GotoState('ClientFiring');
		else if (Pawn(Owner).bAltFire != 0)
			GotoState('ClientSpinning');
		else GotoState('ClientSpinDown');
	}
}

// barrel spinning down
state ClientSpinDown
{
	simulated function bool ClientFire(float Value) { return false; }
	simulated function bool ClientAltFire(float Value) { return false; }

	simulated function BeginState()
	{
		PlaySpinDown();
		bSteadyFlash3rd = false;
		AmbientSound = None;
	}

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
		else if ( Pawn(Owner).bAltFire != 0 )
			Global.ClientAltFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}
}

simulated function PlayEffects()
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

	if (Role == ROLE_Authority)
	{
		SoundVolume = 255*Pawn(Owner).SoundDampening;
		Pawn(Owner).PlayRecoil(FiringSpeed);
	}
}

defaultproperties
{
     MuzzleFlashVariations(0)=Texture'Botpack.Skins.Muz1'
     MuzzleFlashVariations(1)=Texture'Botpack.Skins.Muz2'
     MuzzleFlashVariations(2)=Texture'Botpack.Skins.Muz3'
     MuzzleFlashVariations(3)=Texture'Botpack.Skins.Muz4'
     MuzzleFlashVariations(4)=Texture'Botpack.Skins.Muz5'
     MuzzleFlashVariations(5)=Texture'Botpack.Skins.Muz6'
     MuzzleFlashVariations(6)=Texture'Botpack.Skins.Muz7'
     MuzzleFlashVariations(7)=Texture'Botpack.Skins.Muz8'
     MuzzleFlashVariations(8)=Texture'Botpack.Skins.Muz9'
     MuzzleFlashVariations(9)=Texture'Botpack.Skins.Muz9'
     WeaponDescription="Classification: Gatling Gun\n\nPrimary Fire: Bullets are sprayed forth at a medium to fast rate of fire and good accuracy.\n\nSecondary Fire: Minigun fires twice as fast and is half as accurate.\n\nTechniques: Secondary fire is much more useful at close range, but can eat up tons of ammunition."
     //AmmoName=Class'Botpack.Miniammo'
     AmmoName=Class'WFChainCannonAmmo'
     PickupAmmoCount=50
     bInstantHit=True
     bAltInstantHit=True
     bRapidFire=True
     FireOffset=(X=8.000000,Y=-5.000000,Z=-4.000000)
     MyDamageType=shot
     shakemag=135.000000
     shakevert=8.000000
     AIRating=0.730000
     RefireRate=0.990000
     AltRefireRate=0.990000
     AltFireSound=Sound'chainspin'
     FireSound=Sound'chainfire'
     SelectSound=Sound'UnrealI.Minigun.MiniSelect'
     Misc2Sound=Sound'Cspindown'
     Misc1Sound=Sound'Cspinup'
     DeathMessage="%k's %w turned %o into a leaky piece of meat."
     NameColor=(B=0)
     bDrawMuzzleFlash=True
     MuzzleScale=2.000000
     FlashY=0.180000
     FlashO=0.022000
     FlashC=0.006000
     FlashLength=0.200000
     FlashS=128
     MFTexture=Texture'Botpack.Skins.Muz9'
     AutoSwitchPriority=4
     InventoryGroup=4
     PickupMessage="You got the Chain Cannon."
     ItemName="Chain Cannon"
     //PlayerViewOffset=(X=2.0,Y=-1.9,Z=-2.0)
     PlayerViewOffset=(X=2.2,Y=-1.9,Z=-1.7)
     PlayerViewMesh=LodMesh'WFMedia.chainfirst'
     PlayerViewScale=.36
     BobDamping=0.930000
     PickupViewMesh=LodMesh'chainpick'
     ThirdPersonMesh=LodMesh'chainthird'
     ThirdpersonScale=1.6
     StatusIcon=Texture'Botpack.Icons.UseMini'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.MuzzFlash3'
     MuzzleFlashScale=0.250000
     MuzzleFlashTexture=Texture'Botpack.Skins.Muzzy'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseMini'
     Mesh=LodMesh'chainpick'
     Drawscale=1.5
     bNoSmooth=False
     SoundRadius=96
     SoundVolume=255
     CollisionRadius=34.000000
     CollisionHeight=8.000000
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=28
     LightSaturation=32
     LightRadius=6
     MaxRange=10000
     MinDamageRange=2500
     EffectiveRange=1500
     MinDamage=2
     RndDamage=6
     BaseDamage=9
}