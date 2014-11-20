class WFRailGun extends WFWeapon;

var() float RailBeamDamage;
var() float SplashDamage;
var() float BeamRange;

var float ChargeSize, Count;
var bool bBurst;

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
	if (EnemyDist > 2000)
		bUseAltMode = 1;
	else bUseAltMode = int( FRand() < 0.3 );

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

function AltFire( float Value )
{
	if (!WeaponActive())
		return;

	bPointing=True;
	if ( AmmoType == None )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1) )
	{
		GoToState('AltFiring');
		bCanClientFire = true;
		ClientAltFire(Value);
	}
}

simulated function bool ClientAltFire( float Value )
{
	local bool bResult;

	InstFlash = 0.0;
	bResult = Super.ClientAltFire(value);
	InstFlash = Default.InstFlash;
	return bResult;
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X,Y,Z;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
	return Spawn(ProjClass,,, Start,AdjustedAim);
}

simulated function PlayAltFiring()
{
	PlayOwnedSound(Sound'UnrealShare.PowerUp3', SLOT_Misc, 1.3*Pawn(Owner).SoundDampening);	 // charging rail beam
	PlayAnim('Charging',0.24,0.05);
}

///////////////////////////////////////////////////////
state ClientAltFiring
{
	simulated function Tick(float DeltaTime)
	{
		if ( bBurst )
			return;
		if ( !bCanClientFire || (Pawn(Owner) == None) )
			GotoState('');
		else if ( (Pawn(Owner).bAltFire == 0) || (pawn(Owner).bFire==1) )
		{
			PlayAltBurst();
			bBurst = true;
		}
	}

	simulated function AnimEnd()
	{
		if ( bBurst )
		{
			bBurst = false;

			if ( (Pawn(Owner) == None)
				|| ((AmmoType != None) && (AmmoType.AmmoAmount <= 0)) )
			{
				PlayIdleAnim();
				GotoState('');
			}
			else if ( !bCanClientFire )
				GotoState('');
			else if ( (Pawn(Owner).bAltFire != 0) && (Pawn(Owner).bFire != 0) )
				Global.ClientAltFire(0);
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
		else
			TweenAnim('Loaded', 0.5);
	}
}

state AltFiring
{
	ignores AnimEnd;

	function Tick( float DeltaTime )
	{
		//SetLocation(Owner.Location);
		if ( ChargeSize < 4.1 )
		{
			Count += DeltaTime;
			if ( (Count > 0.5) && AmmoType.UseAmmo(1) )
			{
				ChargeSize += Count;
				Count = 0;
				if ( (PlayerPawn(Owner) == None) && (FRand() < 0.2) )
					GoToState('ShootLoad');
			}
		}
		if( (pawn(Owner).bAltFire==0) || (pawn(Owner).bFire==1) )
			GoToState('ShootLoad');
	}

	function BeginState()
	{
		ChargeSize = 0.0;
		Count = 0.0;
	}

	function EndState()
	{
		ChargeSize = FMin(ChargeSize, 4.1);
	}

Begin:
	FinishAnim();
}

state ShootLoad
{
	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function Fire(float F)
	{
	}

	function AltFire(float F)
	{
	}

	function Timer()
	{
	}

	function AnimEnd()
	{
		Finish();
	}

	function BeginState()
	{
		Local Projectile Gel;
		local vector Start;

		TraceFire(0.0);
		PlayAltBurst();
	}

Begin:
}

function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local bool bHitLevel;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000
		+ Accuracy * (FRand() - 0.5 ) * Z * 1000 ;

	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);
	EndTrace += (BeamRange * vector(AdjustedAim));

	// damage all actors on beam
	foreach TraceActors(class'actor', Other, HitLocation, HitNormal, EndTrace, StartTrace)
		if (Other != None)
		{
			if (Other == Level)
			{
				SpawnEffect(HitLocation, Owner.Location + CalcDrawOffset() + (FireOffset.X + 20) * vector(AdjustedAim) + FireOffset.Y * Y + FireOffset.Z * Z);
				SpawnProjectile(HitLocation, HitNormal, Normal(HitLocation - StartTrace));
				bHitLevel = true;
				break;
			}
			else ProcessTraceActor(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
		}

	if (!bHitLevel)
	{
		//SpawnProjectile(EndTrace, Normal(StartTrace - EndTrace), Normal(StartTrace - EndTrace));
		HitNormal = -vector(AdjustedAim);
		HitLocation = Owner.Location + vector(AdjustedAim)*10000.0;
		SpawnEffect(HitLocation, Owner.Location + CalcDrawOffset() + (FireOffset.X + 20) * vector(AdjustedAim) + FireOffset.Y * Y + FireOffset.Z * Z);
	}
}

function SpawnProjectile(vector HitLocation, vector HitNormal, vector HitAngle)
{
	local rotator ShellRot;
	local float DamageRadius, DamageAmount;

	ShellRot = rotator(( HitAngle dot HitNormal ) * HitNormal * (-1.8 + FRand()*0.8) + HitAngle);
	spawn(class'SawHit',,, HitLocation + 8 * HitNormal, rotator(HitNormal));
	if (ChargeSize > 3.0)
	{
		DamageAmount = SplashDamage + SplashDamage * FClamp(4.0-ChargeSize/2.0, 0.2, 1.0);
		HurtRadius(DamageAmount, 200, MyDamageType, 50000, HitLocation);
		spawn(class'UT_SpriteBallExplosion',,,HitLocation + HitNormal*16);
		spawn(class'WFRailSlug',,,HitLocation + HitNormal*8, ShellRot);
	}
	else spawn(class'WFRailSlugShell',,,HitLocation + 8 * HitNormal, ShellRot);
}

function ProcessTraceActor(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local int i;
	local PlayerPawn PlayerOwner;

	if (Other==None)
	{
		HitNormal = -X;
		HitLocation = Owner.Location + X*10000.0;
	}

	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner != None )
		PlayerOwner.ClientInstantFlash( -0.4, vect(450, 190, 650));

	if ( (Other != self) && (Other != Owner) && (Other != None) )
		Other.TakeDamage(RailBeamDamage*FClamp(ChargeSize/4.0, 0.25, 1.0), Pawn(Owner), HitLocation, (60000.0+40000.0*(ChargeSize/4.1))*X, MyDamageType);
}

function SpawnEffect(vector HitLocation, vector SmokeLocation)
{
	local ShockBeam Smoke,shock;
	local class<ShockBeam> BeamClass;
	local Vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;
	local int BeamSize;

	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/135.0;
	if ( NumPoints < 1 )
		return;
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);

	BeamSize = Max(1, int(ChargeSize));
	switch (BeamSize)
	{
		case 1: BeamClass = class'WFRailBeam1'; break;
		case 2: BeamClass = class'WFRailBeam2'; break;
		case 3: BeamClass = class'WFRailBeam3'; break;
		case 4: BeamClass = class'WFRailBeam4'; break;
	}

	Smoke = Spawn(BeamClass,,,SmokeLocation,SmokeRotation);
	Smoke.MoveAmount = DVector/NumPoints;
	Smoke.NumPuffs = NumPoints - 1;
}

// Finish a firing sequence
function Finish()
{
	local bool bForce, bForceAlt;

	bForce = bForceFire;
	bForceAlt = bForceAltFire;
	bForceFire = false;
	bForceAltFire = false;

	if ( bChangeWeapon )
		GotoState('DownWeapon');
	else if ( PlayerPawn(Owner) == None )
	{
		Pawn(Owner).bAltFire = 0;
		Super.Finish();
	}
	else if ( !WeaponActive() || (AmmoType.AmmoAmount<=0) || (Pawn(Owner).Weapon != self) )
		GotoState('Idle');
	else if ( ((Pawn(Owner).bFire!=0) && (Pawn(Owner).bAltFire!=0)) || bForceAlt )
		Global.AltFire(0);
	else if ( (Pawn(Owner).bFire!=0) || bForce )
		Global.Fire(0);
	else if ( (Pawn(Owner).bAltFire!=0) || bForceAlt )
		Global.AltFire(0);
	else
		GotoState('Idle');
}

simulated function PlayAltBurst()
{
	if ( Owner.IsA('PlayerPawn') )
		PlayerPawn(Owner).ClientInstantFlash( InstFlash, InstFog);
	PlayOwnedSound(AltFireSound, SLOT_Misc, 1.7*Pawn(Owner).SoundDampening);	//shoot rail beam
	PlayAnim('Fire',0.25, 0.05);
}

simulated function PlayFiring()
{
	PlayOwnedSound(FireSound, SLOT_None, 1.7*Pawn(Owner).SoundDampening);	//fire the rail slug
	//LoopAnim('Fire', 0.50 + 0.20 * FireAdjust, 0.05);
	LoopAnim('Fire', 0.70 + 0.20 * FireAdjust, 0.05);
}

defaultproperties
{
     RailBeamDamage=80.000000
     BeamRange=10000
     SplashDamage=25.000000
     WeaponDescription="Classification: High Speed Projectile Weapon\n\nPrimary Fire: Fires a metal slug at high speed that will pass through enemies.\n\nSecondary Fire: Instant hit rail beam. Hold down to increase the power of the beam.\n\nTechniques: (n/a)."
	 //WeaponDescription="Classification: Toxic Rifle\n\nPrimary Fire: Wads of Tarydium byproduct are lobbed at a medium rate of fire.\n\nSecondary Fire: When trigger is held down, the BioRifle will create a much larger wad of byproduct. When this wad is launched, it will burst into smaller wads which will adhere to any surfaces.\n\nTechniques: Byproducts will adhere to walls, floors, or ceilings. Chain reactions can be caused by covering entryways with this lethal green waste."
     //bAltInstantHit=True
     //InstFlash=-0.150000
     //InstFog=(X=139.000000,Y=218.000000,Z=72.000000)
     InstFlash=-0.300000
     InstFog=(X=400.000000,Y=200.000000)
     AmmoName=Class'Botpack.FlakAmmo'
     PickupAmmoCount=10
     //bAltWarnTarget=True
     //bRapidFire=True
     FiringSpeed=1.000000
     //FireOffset=(X=12.000000,Y=-11.000000,Z=-6.000000)
     FireOffset=(Y=-15.000000,Z=-13.000000)
     //ProjectileClass=Class'WFRailSlug'
     ProjectileClass=Class'WFRailSlug'
     AIRating=0.500000
     //AIRating=0.600000
     RefireRate=0.900000
     AltRefireRate=0.900000
     //FireSound=Sound'UnrealI.BioRifle.GelShot'
     //FireSound=Sound'Botpack.TazerFire'
     //FireSound=Sound'Botpack.WarheadShot'
     FireSound=Sound'StingerAltFire'
     AltFireSound=Sound'Botpack.WarheadShot'
     SelectSound=Sound'UnrealI.flak.load1'
     DeathMessage="%o was perforated by %k's %w."
     NameColor=(R=0,B=0)
     AutoSwitchPriority=4
     InventoryGroup=4
     PickupMessage="You got the Rail Gun."
     ItemName="Rail Gun"
     //PlayerViewOffset=(X=6.5,Y=-6,Z=-4)
     //PlayerViewOffset=(X=1.8,Y=-1.15,Z=-1)
     PlayerViewOffset=(X=2,Y=-1.5,Z=-1)
     PlayerViewMesh=LodMesh'WFMedia.railgun'
     //PlayerViewMesh=LodMesh'railgun_s'
     //PlayerViewScale=.5
     PlayerViewScale=0.13
     ThirdPersonScale=.80
     BobDamping=0.94500
     PickupViewMesh=LodMesh'Botpack.BRifle2Pick'
     ThirdPersonMesh=LodMesh'WFMedia.railthird'
     StatusIcon=Texture'Botpack.Icons.UseBio'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseBio'
     Mesh=LodMesh'WFMedia.railthird'
     bNoSmooth=False
     CollisionHeight=19.000000
}