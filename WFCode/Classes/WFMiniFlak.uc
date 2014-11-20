class WFMiniFlak extends WFWeapon;

// return delta to combat style
function float SuggestAttackStyle()
{
	local bot B;

	B = Bot(Owner);
	if ( (B != None) && B.bNovice )
		return 0.2;
	return 0.4;
}

function float SuggestDefenseStyle()
{
	return -0.3;
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	local Color C;
	local string Temp;

	if ( AmmoType != None )
		Temp = String(AmmoType.AmmoAmount);

	while(Len(Temp) < 3) Temp = "0"$Temp;

	C.R = 255;
	C.G = 0;
	C.B = 0;

	Tex.DrawColoredText( 30, 10, Temp, Font'LEDFont2', C );
}


function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist, rating;
	local vector EnemyDir;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;
	if ( Pawn(Owner).Enemy == None )
	{
		bUseAltMode = 0;
		return AIRating;
	}
	EnemyDir = Pawn(Owner).Enemy.Location - Owner.Location;
	EnemyDist = VSize(EnemyDir);
	rating = FClamp(AIRating - (EnemyDist - 450) * 0.001, 0.2, AIRating);
	if ( Pawn(Owner).Enemy.IsA('StationaryPawn') )
	{
		bUseAltMode = 0;
		return AIRating + 0.3;
	}
	if ( EnemyDist > 900 )
	{
		bUseAltMode = 0;
		if ( EnemyDist > 2000 )
		{
			if ( EnemyDist > 3500 )
				return 0.2;
			return (AIRating - 0.3);
		}
		if ( EnemyDir.Z < -0.5 * EnemyDist )
		{
			bUseAltMode = 1;
			return (AIRating - 0.3);
		}
	}
	else if ( (EnemyDist < 750) && (Pawn(Owner).Enemy.Weapon != None) && Pawn(Owner).Enemy.Weapon.bMeleeWeapon )
	{
		bUseAltMode = 0;
		return (AIRating + 0.3);
	}
	else if ( (EnemyDist < 340) || (EnemyDir.Z > 30) )
	{
		bUseAltMode = 0;
		return (AIRating + 0.2);
	}
	else
		bUseAltMode = int( FRand() < 0.65 );
	return rating;
}


simulated event RenderOverlays( canvas Canvas )
{
	Texture'FlakAmmoled'.NotifyActor = Self;
	Super.RenderOverlays(Canvas);
	Texture'FlakAmmoled'.NotifyActor = None;
}


// Fire chunks
function Fire( float Value )
{
	local Vector Start, X,Y,Z;
	local Bot B;
	local Pawn P;

	if (!WeaponActive())
		return;

	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.UseAmmo(1))
	{
		bCanClientFire = true;
		bPointing=True;
		Start = Owner.Location + CalcDrawOffset();
		B = Bot(Owner);
		P = Pawn(Owner);
		P.PlayRecoil(FiringSpeed);
		Owner.MakeNoise(2.0 * P.SoundDampening);
		AdjustedAim = P.AdjustAim(AltProjectileSpeed, Start, AimError, True, bWarnTarget);
		GetAxes(AdjustedAim,X,Y,Z);
		Spawn(class'WeaponLight',,'',Start+X*20,rot(0,0,0));
		Start = Start + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;

		Spawn( class 'WFMiniChunk1',, '', Start, AdjustedAim);
		Spawn( class 'WFMiniChunk2',, '', Start - Z, AdjustedAim);
		Spawn( class 'WFMiniChunk3',, '', Start + 2 * Y + Z, AdjustedAim);

		// lower skill bots fire less flak chunks
		if ( (B == None) || !B.bNovice || ((B.Enemy != None) && (B.Enemy.Weapon != None) && B.Enemy.Weapon.bMeleeWeapon) )
			Spawn( class 'WFMiniChunk4',, '', Start + 2 * Y + Z, AdjustedAim);
		else if ( B.Skill > 1 )
			Spawn( class 'WFMiniChunk3',, '', Start + Y - Z, AdjustedAim);

		ClientFire(Value);
		GoToState('NormalFire');
	}
}

simulated function PlayFiring()
{
	PlayAnim( 'Fire', 0.9, 0.05);
	PlayOwnedSound(FireSound, SLOT_Misc,Pawn(Owner).SoundDampening*4.0);
	bMuzzleFlash++;
}

simulated function PlayAltFiring()
{
	PlayOwnedSound(AltFireSound, SLOT_Misc,Pawn(Owner).SoundDampening*4.0);
	PlayAnim('AltFire', 1.3, 0.05);
	bMuzzleFlash++;
}

function AltFire( float Value )
{
	local Vector Start, X,Y,Z;

	if (!WeaponActive())
		return;

	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.UseAmmo(1))
	{
		Pawn(Owner).PlayRecoil(FiringSpeed);
		bPointing=True;
		bCanClientFire = true;
		Owner.MakeNoise(Pawn(Owner).SoundDampening);
		GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
		Start = Owner.Location + CalcDrawOffset();
		Spawn(class'WeaponLight',,'',Start+X*20,rot(0,0,0));
		Start = Start + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
		AdjustedAim = pawn(owner).AdjustToss(AltProjectileSpeed, Start, AimError, True, bAltWarnTarget);
		Spawn(AltProjectileClass,,, Start,AdjustedAim);
		ClientAltFire(Value);
		GoToState('AltFiring');
	}
}

////////////////////////////////////////////////////////////
state AltFiring
{
	function EndState()
	{
		Super.EndState();
		OldFlashCount = FlashCount;
	}

	function AnimEnd()
	{
		if ( (AnimSequence != 'Loading') && (AmmoType.AmmoAmount > 0) )
			PlayReloading();
		else
			Finish();
	}

Begin:
	FlashCount++;
}

/////////////////////////////////////////////////////////////
simulated function PlayReloading()
{
	PlayAnim('Loading',0.7, 0.05);
	Owner.PlayOwnedSound(CockingSound, SLOT_None,0.5*Pawn(Owner).SoundDampening);
}

simulated function PlayFastReloading()
{
	PlayAnim('Loading',1.4, 0.05);
	Owner.PlayOwnedSound(CockingSound, SLOT_None,0.5*Pawn(Owner).SoundDampening);
}

state ClientReload
{
	simulated function bool ClientFire(float Value)
	{
		bForceFire = bForceFire || ( bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0) );
		return bForceFire;
	}

	simulated function bool ClientAltFire(float Value)
	{
		bForceAltFire = bForceAltFire || ( bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0) );
		return bForceAltFire;
	}

	simulated function AnimEnd()
	{
		if ( bCanClientFire && (PlayerPawn(Owner) != None) && (AmmoType.AmmoAmount > 0) )
		{
			if ( bForceFire || (Pawn(Owner).bFire != 0) )
			{
				Global.ClientFire(0);
				return;
			}
			else if ( bForceAltFire || (Pawn(Owner).bAltFire != 0) )
			{
				Global.ClientAltFire(0);
				return;
			}
		}
		GotoState('');
		Global.AnimEnd();
	}

	simulated function EndState()
	{
		bForceFire = false;
		bForceAltFire = false;
	}

	simulated function BeginState()
	{
		bForceFire = false;
		bForceAltFire = false;
	}
}

state ClientFiring
{
	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None) || (Ammotype.AmmoAmount <= 0) )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else
		{
			PlayFastReloading();
			GotoState('ClientReload');
		}
	}
}

state ClientAltFiring
{
	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None) || (Ammotype.AmmoAmount <= 0) )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else
		{
			PlayReloading();
			GotoState('ClientReload');
		}

	}
}

state NormalFire
{
	function EndState()
	{
		Super.EndState();
		OldFlashCount = FlashCount;
	}

	function AnimEnd()
	{
		if ( (AnimSequence != 'Loading') && (AmmoType.AmmoAmount > 0) )
			PlayFastReloading();
		else
			Finish();
	}

Begin:
	FlashCount++;
}

///////////////////////////////////////////////////////////
simulated function TweenDown()
{
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else if ( AmmoType.AmmoAmount < 1 )
		TweenAnim('Select', 0.5);
	else
		PlayAnim('Down',1.0, 0.05);
}

simulated function PlayIdleAnim()
{
}

simulated function PlayPostSelect()
{
	PlayAnim('Loading', 1.3, 0.05);
	Owner.PlayOwnedSound(Misc2Sound, SLOT_None,1.3*Pawn(Owner).SoundDampening);
}

defaultproperties
{
     //WeaponDescription="Classification: Heavy Shrapnel\n\nPrimary Fire: White hot chunks of scrap metal are sprayed forth, shotgun style.\n\nSecondary Fire: A grenade full of shrapnel is lobbed at the enemy.\n\nTechniques: The Flak Cannon is far more useful in close range combat situations."
     WeaponDescription="Classification: Light Shrapnel\n\nPrimary Fire: Small white hot chunks of scrap metal are sprayed forth, shotgun style.\n\nSecondary Fire: A small grenade full of shrapnel is lobbed at the enemy.\n\nTechniques: The Mini Flak is far more useful in close range combat situations."
     InstFlash=-0.400000
     InstFog=(X=650.000000,Y=450.000000,Z=190.000000)
     AmmoName=Class'Botpack.FlakAmmo'
     PickupAmmoCount=10
     bWarnTarget=True
     bAltWarnTarget=True
     bSplashDamage=True
     FiringSpeed=1.000000
     FireOffset=(X=10.000000,Y=-11.000000,Z=-15.000000)
     ProjectileClass=Class'Botpack.UTChunk'
     //AltProjectileClass=Class'Botpack.flakslug'
     AltProjectileClass=Class'WFMiniFlakSlug'
     aimerror=700.000000
     shakemag=350.000000
     shaketime=0.150000
     shakevert=8.500000
     //AIRating=0.750000
     AIRating=0.450000
     FireSound=Sound'UnrealShare.flak.shot1'
     AltFireSound=Sound'UnrealShare.flak.Explode1'
     CockingSound=Sound'UnrealI.flak.load1'
     SelectSound=Sound'UnrealI.flak.pdown'
     Misc2Sound=Sound'UnrealI.flak.Hidraul2'
     DeathMessage="%o was ripped to shreds by %k's %w."
     NameColor=(G=96,B=0)
     bDrawMuzzleFlash=True
     MuzzleScale=2.000000
     FlashY=0.160000
     FlashO=0.015000
     FlashC=0.100000
     FlashLength=0.020000
     FlashS=256
     MFTexture=Texture'Botpack.Skins.Flakmuz'
     AutoSwitchPriority=2
     InventoryGroup=2
     //AutoSwitchPriority=8
     //InventoryGroup=8
     PickupMessage="You got the Mini Flak."
     ItemName="Mini Flak"
     PlayerViewOffset=(X=1.500000,Y=-1.000000,Z=-1.500000)
     PlayerViewMesh=LodMesh'Botpack.flakm'
     //PlayerViewScale=1.200000
     PlayerViewScale=0.75
     BobDamping=0.972000
     PickupViewMesh=LodMesh'Botpack.Flak2Pick'
     ThirdPersonMesh=LodMesh'Botpack.FlakHand'
     StatusIcon=Texture'Botpack.Icons.UseFlak'
     bMuzzleFlashParticles=True
     MuzzleFlashStyle=STY_Translucent
     MuzzleFlashMesh=LodMesh'Botpack.muzzFF3'
     MuzzleFlashScale=0.400000
     MuzzleFlashTexture=Texture'Botpack.Skins.MuzzyFlak'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseFlak'
     Mesh=LodMesh'Botpack.Flak2Pick'
     bNoSmooth=False
     CollisionRadius=32.000000
     CollisionHeight=23.000000
     LightBrightness=228
     LightHue=30
     LightSaturation=71
     LightRadius=14
     ThirdPersonScale=0.625
     Mass=15.000000
     PickupViewScale=0.625
}