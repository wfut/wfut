//=============================================================================
// WFS_PCSystemAutoCannon.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
// A player maintainable sentry cannon.
//=============================================================================
class WFS_PCSystemAutoCannon extends MinigunCannon;

var Pawn PlayerOwner;					// the player that the cannon actually belongs to
var Pawn PlayerManager;					// the player that is currently responsible for maintanance

var() class<actor> GunBaseClass;		// the gun base class used by the cannon

var byte CurrentSlot;					// the current weapon slot being fired

var float LastFired[4]; 				// time the weapon slot was last fired

var() class<WFS_AutoCannonWeaponInfo> WeaponInfo; 	// used to setup weapon slots for each tech level,
												// to determine max ammo for weapon slots, and other
												// weapon related functions

var(Weapons) int AmmoAmount[4]; 		// current amount of ammo
var(Weapons) class<Ammo> AmmoTypes[4];	// types of ammo used
var(Weapons) int AmmoUsed[4]; 			// ammo used per shot
var(Weapons) name DamageType[4]; 		// type of damage inflicted
var(Weapons) float RefireRate[4]; 		// re-fire rate for each slot in seconds (fires when RefireCount == RefireRate)
var(Weapons) sound FireSounds[4]; 		// sound played for fired shot

// if ProjectileClass is 'None', then it's assumed that this slot is instant hit
var(Weapons) class<Projectile> ProjectileClass[4]; 	// projectile class fired
var(Weapons) byte bLeadTargetForSlot[4]; 			// lead target for slot

var(Weapons) int SlotDamage[4]; 		// used for instant hit shots
var(Weapons) int DamageVariation[4]; 	// random range added to ShotDamage for instant hits
var(Weapons) byte bAlwaysHit[4]; 		// always hits the enemy actor (eg. InstaGib)

var() bool bPowerDown; 		// sentry cannon powers down when health < 0, otherwise it explodes
var() float PowerDownTime; 	// how long sentry stays powered down before reactivating

var int OldTechLevel;
var int NewTechLevel;
var() int TechLevel;
var() int MaxTechLevel;
var() float TechLevelDelay; // time taken to upgrade/downgrade sentry

var() float BuildTime;		// how long it takes to deploy cannon
var() float RemoveTime;		// how long it takes to remove cannon

var() int MaxHealth[4]; // max health for the sentry: [0] = TechLevel 1, [1] = TechLevel 2, etc

var float LastBump;
var() float BumpTime;

var() class<WFS_HUDMenuInfo> HUDMenuClass; 	// menu class displayed when bumped

var() class<Effects> SelfDestructEffect;

var() bool bOnlyMaintainedByOwner;		// only the owner can maintain this cannon

var() sound TechLevelIncreasedSound;	// sound cannon makes when upgraded
var() sound TechLevelDecreasedSound;	// sound cannon makes when downgraded

// skins
var() bool bUseTeamSkins;
var() texture CannonTeamSkins[4];
var() texture GunBaseTeamSkins[4];

var float DisableTime;

replication
{
	reliable if (Role == ROLE_Authority)
		AmmoAmount, AmmoTypes, TechLevel;
}

function PostBeginPlay()
{
	super.PostBeginPlay();

	// make sure that MaxTechLevel is valid
	if (MaxTechLevel > 4) MaxTechLevel = 4;
	else if (MaxTechLevel < 0) MaxTechLevel = 0;
}

function Trigger( actor Other, pawn EventInstigator )
{
}

function IncreaseTechLevel(optional pawn Other)
{
	if (TechLevel == (MaxTechLevel-1))
		return;

	OldTechLevel = TechLevel;
	NewTechLevel = TechLevel + 1;

	if (NewTechLevel > (MaxTechLevel-1)) NewTechLevel = MaxTechLevel-1;

	if (Other != None) PlayerManager = Other;
	else PlayerManager = PlayerOwner;

	GotoState('ChangingTechLevel');
}

function DecreaseTechLevel(optional pawn Other)
{
	if (TechLevel == 0)
		return;

	OldTechLevel = TechLevel;
	NewTechLevel = TechLevel - 1;

	if (NewTechLevel < 0) NewTechLevel = 0;

	if (Other != None) PlayerManager = Other;
	else PlayerManager = PlayerOwner;

	GotoState('ChangingTechLevel');
}

function TechLevelChanged()
{
	Health = MaxHealth[TechLevel];
}

// 'Amount' is the amount of ammo to be added, modify if whole amount wasn't used
function IncreaseAmmo(byte Slot, out int Amount)
{
	local int MaxAmount;

	MaxAmount = GetMaxAmmoForSlot(Slot);
	if (!(MaxAmount <= 0) && (AmmoAmount[Slot] + Amount > MaxAmount))
	{
		Amount = MaxAmount - AmmoAmount[Slot];
		AmmoAmount[Slot] = MaxAmount;
	}
	else AmmoAmount[Slot] += Amount;
}

function SetTeam(int TeamNum)
{
	MyTeam = TeamNum;
	if (bUseTeamSkins)
		UpdateTeamSkins(TeamNum);
}

function UpdateTeamSkins(int TeamNum)
{
	// update the team skins
	MultiSkins[1] = CannonTeamSkins[TeamNum];
	if (GunBase != None)
		GunBase.MultiSkins[1] = GunBaseTeamSkins[TeamNum];
}

function int FindSlotForAmmo(ammo AmmoType)
{
	if (WeaponInfo != none)
		return WeaponInfo.static.FindSlotForAmmo(self, AmmoType);

	return -1;
}

function int GetMaxAmmoForSlot(byte Slot)
{
	if (WeaponInfo != none)
		return WeaponInfo.static.GetMaxSlotAmmo(self, Slot);

	return 0; // no max ammo limit
}

function Repair(int AddHealth)
{
	if (Health + AddHealth > MaxHealth[TechLevel])
		Health = MaxHealth[TechLevel];
	else Health += AddHealth;
}

function SelfDestruct()
{
	if (SelfDestructEffect != none)
		spawn(SelfDestructEffect);
	PlayExplode(vect(0,0,0),vect(0,0,0));
	HurtRadius(250, 500, '', 87000, Location);
	Destroy();
}

function SetCannonRotation(rotator NewRotation)
{
	DesiredRotation = NewRotation;
	StartingRotation = NewRotation;
	SetRotation(NewRotation);
	UpdateGunBaseRotation(NewRotation);
}

function UpdateGunBaseRotation(rotator NewRotation)
{
	if (GunBase != None)
		GunBase.SetRotation(NewRotation);
}

function RemoveCannon()
{
	if (RemoveTime > 0)
		GotoState('Removing');
	else
		Destroy();
}

function DeployCannon();

function SetWeaponInfo(class<WFS_AutoCannonWeaponInfo> NewWeaponInfo)
{
	if (NewWeaponInfo != none)
	{
		WeaponInfo = NewWeaponInfo;
		WeaponInfo.static.TechLevelChanged(self);
	}
}

event Bump(actor Other)
{
	if (!Other.IsA('WFS_PCSystemPlayer') || !SameTeamAs(PlayerPawn(Other).PlayerReplicationInfo.Team))
		return;
	else if (Other.IsA('WFS_PCSystemPlayer') && (WFS_PCSystemPlayer(Other).PCInfo != WFS_PCSystemPlayer(PlayerOwner).PCInfo))
		return;
	else if (bOnlyMaintainedByOwner)
		return;

	if ((Level.TimeSeconds - LastBump) > BumpTime)
	{
		LastBump = Level.TimeSeconds;
		WFS_PCSystemPlayer(Other).ClientDisplayHUDMenu(HUDMenuClass, self);
	}
}

function SpawnBase()
{
	GunBase = Spawn(GunBaseClass, self);
}

function SetPlayerOwner(pawn Other)
{
	PlayerOwner = Other;
	SetOwner(Other);
}

function Shoot()
{
	local Actor HitActor;
	local Vector HitLocation, HitNormal, EndTrace, FireSpot, ProjStart, X,Y,Z;
	local rotator ShootRot;
	local sound NewSound;
	local projectile p;
	local int i;

	if (DesiredRotation.Pitch < -10000) Return;

	// update the ambient sound if necessary
	NewSound = WeaponInfo.static.GetAmbientFiringSound(self);
	if (AmbientSound != NewSound)
		AmbientSound = NewSound;

	// calculate ProjStart
	GetAxes(Rotation,X,Y,Z);
	ProjStart = PrePivot + Location + X*20 + 12 * Y + 16 * Z;

	// update muzzle flash
	if (!MuzzFlash.bHidden)
		MuzzFlash.SetLocation(ProjStart);

	for (CurrentSlot=0; CurrentSlot<4; CurrentSlot++)
	{
		if ( ((Level.TimeSeconds - LastFired[CurrentSlot]) >= RefireRate[CurrentSlot])
			&& HasAmmo(CurrentSlot) && TargetWithinWeaponRange(CurrentSlot))
		{
			// calculate ShootRot
			ShootRot = CalcShootRot(ProjStart);
			GetAxes(ShootRot,X,Y,Z);
			PlayAnim(PickAnim());

			// play fire sound
			if (FireSounds[CurrentSlot] != none)
				PlaySound(FireSounds[CurrentSlot], SLOT_None, 5.0);

			// fire projectile
			if (ProjectileClass[CurrentSlot] != none)
			{
				if (LeadTargetForSlot(CurrentSlot))
				{
					FireSpot = Enemy.Location + FMin(1, 0.7 + 0.6 * FRand()) * (Enemy.Velocity * VSize(Enemy.Location - ProjStart)/ProjectileType.Default.Speed);
					if ( !FastTrace(FireSpot, ProjStart) )
						FireSpot = 0.5 * (FireSpot + Enemy.Location);
					DesiredRotation = Rotator(FireSpot - ProjStart);
				}
				p = Spawn (ProjectileClass[CurrentSlot],,,ProjStart,DesiredRotation);
				if ( Enemy.IsA('WarShell') )
					p.speed *= 2;
				LastFired[CurrentSlot] = Level.TimeSeconds;
				UseAmmo(CurrentSlot);
			}
			else if (AlwaysHit(CurrentSlot))
			{
				// find the 'direct hit' rotation
				ShootRot = rotator(Enemy.Location - ProjStart);
				DesiredRotation = ShootRot;
				HitActor = TraceShot(HitLocation, HitNormal, ProjStart + 10000.0 * X, ProjStart);
				ProssessAlwaysHit(HitActor, HitLocation, HitNormal, X,Y,Z);
				// adjust the visual firing rotations
				ShootRot.Pitch = ShootRot.Pitch & 65535;
				if ( ShootRot.Pitch < 32768 )
					ShootRot.Pitch = Min(ShootRot.Pitch, 5000);
				else
					ShootRot.Pitch = Max(ShootRot.Pitch, 60535);
				MuzzFlash.SetRotation(ShootRot);
				ShootRot.Pitch = 0;
				SetRotation(ShootRot);
				LastFired[CurrentSlot] = Level.TimeSeconds;
				UseAmmo(CurrentSlot);
			}
			else // trace an instant hit
			{
				if ( FRand() < 0.4 ) // could remove this bit, or move it somewhere else
					Spawn(class'MTracer',,, ProjStart, ShootRot);
				HitActor = TraceShot(HitLocation,HitNormal,ProjStart + 10000.0 * X,ProjStart);
				ProcessTraceHit(HitActor, HitLocation, HitNormal, X,Y,Z);
				ShootRot.Pitch = ShootRot.Pitch & 65535;
				if ( ShootRot.Pitch < 32768 )
					ShootRot.Pitch = Min(ShootRot.Pitch, 5000);
				else
					ShootRot.Pitch = Max(ShootRot.Pitch, 60535);
				MuzzFlash.SetRotation(ShootRot);
				ShootRot.Pitch = 0;
				SetRotation(ShootRot);
				LastFired[CurrentSlot] = Level.TimeSeconds;
				UseAmmo(CurrentSlot);
			}
		}
	}

	// weapon fired
	bShoot=false;
}

function rotator CalcShootRot(vector ProjStart)
{
	local rotator ShootRot;

	if ((WeaponInfo != None) && WeaponInfo.static.CalcShootRot(self, ProjStart, ShootRot))
		return ShootRot;

	ShootRot = rotator(Enemy.Location - ProjStart);
	ShootRot.Yaw = ShootRot.Yaw + 1024 - Rand(2048);
	DesiredRotation = ShootRot;
	ShootRot.Pitch = ShootRot.Pitch + 256 - Rand(512);
	return ShootRot;
}

function bool TargetWithinWeaponRange(byte Slot)
{
	return WeaponInfo.static.IsInWeaponRange(self, Target, Slot);
}

function bool LeadTargetForSlot(byte Slot)
{
	return bool(bLeadTargetForSlot[Slot]);
}

// used for instant hit shots
function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local UT_Shellcase s;
	local int rndDam;

	PlayFiringEffect(CurrentSlot);
	s = Spawn(class'UT_ShellCase',, '', PrePivot + Location + 20 * X + 10 * Y + 30 * Z);
	if ( s != None )
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);

	if (Other == Level)
	{
		if (CurrentSlot == 0)
			Spawn(class'UT_LightWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
	}
	else if ( (Other!=self) && (Other != None) )
	{
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
		else
			Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);
		rndDam = SlotDamage[CurrentSlot] + Rand(DamageVariation[CurrentSlot]);
		Other.TakeDamage(rndDam, self, HitLocation, rndDam*500.0*X, 'shot');
	}
}

function ProssessAlwaysHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local vector ProjStart;

	if (currentslot == 1)
	{
		GetAxes(Rotation,X,Y,Z);
		ProjStart = PrePivot + Location + X*20 + 12 * Y + 16 * Z;
		if (Other==None)
		{
			HitNormal = -X;
			HitLocation = Location + X*10000.0;
		}

		SpawnEffect(HitLocation, ProjStart);

		Spawn(class'ut_SuperRing2',,, HitLocation+HitNormal*8,rotator(HitNormal));

		if ( (Other != self) && (Other != Owner) && (Other != None) )
			Other.TakeDamage(SlotDamage[CurrentSlot] + Rand(DamageVariation[CurrentSlot]), Pawn(Owner), HitLocation, 60000.0*X, DamageType[CurrentSlot]);
	}
}

function bool HasAmmo(byte Slot)
{
	if (AmmoAmount[Slot] > 0)
		return true;

	return false;
}

function bool AlwaysHit(byte Slot)
{
	return bool(bAlwaysHit[Slot]);
}

function UseAmmo(byte Slot)
{
	AmmoAmount[Slot] -= AmmoUsed[Slot];
	if (AmmoAmount[Slot] < 0) AmmoAmount[Slot] = 0;
}

// effects
function PlayFiringEffect(byte Slot);

function SpawnEffect(vector HitLocation, vector SmokeLocation)
{
	local SuperShockBeam Smoke,shock;
	local Vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;

	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/135.0;
	if ( NumPoints < 1 )
		return;
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);

	Smoke = Spawn(class'SuperShockBeam',,,SmokeLocation,SmokeRotation);
	Smoke.MoveAmount = DVector/NumPoints;
	Smoke.NumPuffs = NumPoints - 1;
}


function PlayHitEffect(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z);


function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
					Vector momentum, name damageType)
{
	local int actualDamage;

	MakeNoise(1.0);
	actualDamage = Level.Game.ReduceDamage(NDamage, DamageType, self, instigatedBy);
	Health -= actualDamage;

	if (Health <0)
	{
		if (bPowerDown)
		{
			PlaySound(DeActivateSound, SLOT_None,5.0);
			NextState = 'Idle';
			Enemy = None;
			Spawn(class'UT_BlackSmoke');
			GotoState('DamagedState');
		}
		else
		{
			PlayExplode(HitLocation, Momentum);
			Died(instigatedBy, damagetype, hitlocation);
		}
	}
	else if ( instigatedBy == None )
		return;
	else if (!IsValidTarget(Enemy) && (Enemy != PlayerOwner) && IsValidTarget(instigatedBy))
	{
		Enemy = instigatedBy;
		GotoState('ActiveCannon');
	}
}

function Carcass SpawnCarcass()
{
	return None;
}

function PlayExplode(vector HitLocation, vector Momentum)
{
	local int i, NumFrags;
	local float DSize;
	local SpriteBallExplosion s;
	local RingExplosion3 r;
	local Fragment f;

	s = spawn(class'SpriteBallExplosion');
	//s.RemoteRole = ROLE_None;

	r = Spawn(class'RingExplosion3');
	//r.RemoteRole = ROLE_None;

	NumFrags = 5 + Rand(5);

	DSize = FRand() * 1.0 + 1.0;

	for (i=0 ; i<NumFrags ; i++)
	{
		f = Spawn( class'Fragment1', Owner);
		f.CalcVelocity(Momentum/100,0);
		f.Skin = texture'jCannon1';//texture'jGrBase'; // could randomise this a little
		f.DrawScale = DSize*0.5+0.7*DSize*FRand();
	}
}

function bool UseMuzzleFlash()
{
	if (WeaponInfo != none)
		return WeaponInfo.static.UseMuzzleFlash(self);
}

state DamagedState
{
	ignores TakeDamage, SeePlayer, EnemyNotVisible, IncreaseTechLevel, DecreaseTechLevel, SelfDestruct;

Begin:
	Enemy = None;
	StartDeactivate();
	Sleep(0.0);
	PlayDeactivate();
	FinishAnim();
	Spawn(class'UT_BlackSmoke');
	Sleep(1.0);
	Spawn(class'UT_BlackSmoke');
	Sleep(1.0);
	Spawn(class'UT_BlackSmoke');
	if ((PowerDownTime - 2) > 0)
		Sleep(PowerDownTime-2);
	Health = MaxHealth[TechLevel];
	GotoState(NextState);
}

state DisabledState
{
ignores SeePlayer, EnemyNotVisible, IncreaseTechLevel, DecreaseTechLevel;

	function DisableCannon(float Delay)
	{
		DisableTime = Delay;
		GotoState('DisabledState', 'Disabled');
	}

Begin:
	Enemy = None;
	StartDeactivate();
	Sleep(0.0);
	PlayDeactivate();
	FinishAnim();
Disabled:
	Spawn(class'UT_BlackSmoke');
	Sleep(1.0);
	Spawn(class'UT_BlackSmoke');
	Sleep(1.0);
	Spawn(class'UT_BlackSmoke');
	if (DisableTime-2 > 0.0)
		Sleep(DisableTime-2);
	GotoState(NextState);
}

function DisableCannon(float Delay)
{
	DisableTime = Delay;
	NextState = 'Idle';
	GotoState('DisabledState');
}

state ActiveCannon
{
	ignores SeePlayer;

	// TODO: add some valid target checks here
	function Timer()
	{
		local Pawn P;

		/*if (!IsValidTarget(Enemy))
		{
			Log(self$": Enemy is not valid, calling EnemyNotVisible()");
			EnemyNotVisible();
		}*/
		DesiredRotation = rotator(Enemy.Location - Location - PrePivot);
		DesiredRotation.Yaw = DesiredRotation.Yaw & 65535;
		//MuzzFlash.bHidden = false;
		MuzzFlash.bHidden = !UseMuzzleFlash();
		if ( bShoot )
			Shoot();
		else
		{
			TweenAnim(PickAnim(), 0.2);
			bShoot=True;
			SetTimer(SampleTime,True);
		}

	}

	function EnemyNotVisible()
	{
		local Pawn P;

		Enemy = None;
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
            if (IsValidTarget(P))
			{
				Enemy = P;
				return;
			}
		GotoState('Idle');
	}

	function EndState()
	{
		AmbientSound = None;
		MuzzFlash.bHidden = true;
	}

Begin:
	Disable('Timer');
	FinishAnim();
	PlayActivate();
	FinishAnim();
	ActivateComplete();
	Enable('Timer');
	SetTimer(SampleTime,True);
	RotationRate.Yaw = TrackingRate;
	SetPhysics(PHYS_Rotating);
	AmbientSound = WeaponInfo.static.GetAmbientFiringSound(self);
	bShoot=True;

FaceEnemy:
	TurnToward(Enemy);
	Goto('FaceEnemy');
}

auto state Building
{
	ignores TakeDamage, SeePlayer, EnemyNotVisible, IncreaseTechLevel, DecreaseTechLevel, RemoveCannon, /*SelfDestruct, */Bump;

Begin:
	if (PlayerOwner.IsA('WFS_PCSystemPlayer'))
		WFS_PCSystemPlayer(PlayerOwner).FreezePlayer(BuildTime, 'BuildingCannon');
	bHidden = true;
	Sleep(BuildTime/2);
	bHidden = false;
	Sleep(BuildTime/2);
	if (WeaponInfo != none)
	{
		WeaponInfo.static.TechLevelChanged(self);
		WeaponInfo.static.SetupAmmoLevels(self, PlayerOwner);
	}
	TechLevelChanged();
	if (PlayerOwner.IsA('WFS_PCSystemPlayer'))
		WFS_PCSystemPlayer(PlayerOwner).UnfreezePlayer('BuildingCannon');
	PlaySound(ActivateSound, SLOT_None, 10.0);
	GotoState('Idle');
}

state ChangingTechLevel
{
	ignores TakeDamage, SeePlayer, EnemyNotVisible, IncreaseTechLevel, DecreaseTechLevel, RemoveCannon, SelfDestruct, Bump;

Begin:
	// sleep for a specified time before changing techlevel
	if (TechLevelDelay > 0.0)
	{
		// stop the player from moving
		if (PlayerManager.IsA('WFS_PCSystemPlayer'))
			WFS_PCSystemPlayer(PlayerManager).FreezePlayer(TechLevelDelay, 'UpgradingCannon');
		Sleep(TechLevelDelay);
	}

	// change to the new techlevel
	TechLevel = NewTechLevel;
	if (WeaponInfo != none)
	{
		WeaponInfo.static.TechLevelChanged(self);
		WeaponInfo.static.SetupAmmoLevels(self, PlayerOwner);
	}
	TechLevelChanged();

	// play sound
	if (TechLevel > OldTechLevel)
		PlaySound(TechLevelIncreasedSound, SLOT_None, 10.0);
	else if (TechLevel < OldTechLevel)
		PlaySound(TechLevelDecreasedSound, SLOT_None, 10.0);

	// return player back to normal
	if ((TechLevelDelay > 0.0) && PlayerManager.IsA('WFS_PCSystemPlayer'))
		WFS_PCSystemPlayer(PlayerManager).UnfreezePlayer('UpgradingCannon');

	GotoState('Idle');
}

state Removing
{
	ignores TakeDamage, SeePlayer, EnemyNotVisible, IncreaseTechLevel, DecreaseTechLevel, RemoveCannon, SelfDestruct, Bump;

Begin:
	if ((RemoveTime > 0.0) && PlayerOwner.IsA('WFS_PCSystemPlayer'))
		WFS_PCSystemPlayer(PlayerOwner).FreezePlayer(RemoveTime, 'RemovingCannon');
	Sleep(RemoveTime/2);
	bHidden = true;
	Sleep(RemoveTime/2);
	if ((RemoveTime > 0.0) && PlayerOwner.IsA('WFS_PCSystemPlayer'))
		WFS_PCSystemPlayer(PlayerOwner).UnfreezePlayer('RemovingCannon');
	Destroy();
}

function bool IsValidTarget(actor Other)
{
	if (Other == None)
		return false;

	if (Other.IsA('Pawn'))
	{
		if (pawn(Other).IsInState('Waiting') || pawn(Other).IsInState('PCSpectating')
			|| (pawn(Other).Health <= 0) || Other.bHidden || !IsVisibleTarget(Other)
			|| (Other.Mesh == none))
				return false;

        if ( !Other.bCollideActors || ((Pawn(Other).PlayerReplicationInfo != none)
        	&& SameTeamAs(Pawn(Other).PlayerReplicationInfo.Team) && Level.Game.bTeamGame))
				return false;

		if (Other.IsA('WFS_PCSystemAutoCannon') && SameTeamAs(WFS_PCSystemAutoCannon(Other).MyTeam))
			return false;
	}

	if (Other == self)
	{
		Log(self.name$".IsValidTarget(): New target was self!!");
		return false;
	}

	return true;
}

function bool IsVisibleTarget(actor Other)
{
	local pawn PawnOther;

	PawnOther = pawn(Other);
	// check for invisibilty items, test visibility, etc.
	if (!LineOfSightTo(Other))
		return false;
	if ((PawnOther != None) && (PawnOther.Visibility == 0))
		return false;

	return true;
}

state Idle
{
	ignores EnemyNotVisible;

	function SeePlayer(Actor SeenPlayer)
	{
        if (IsValidTarget(SeenPlayer))
		{
			Enemy = Pawn(SeenPlayer);
			GotoState('ActiveCannon');
		}
	}

	function BeginState()
	{
		Enemy = None;
	}

Begin:
	TweenAnim(AnimSequence, 0.25);
	Sleep(5.0);
	StartDeactivate();
	Sleep(0.0);
	PlayDeactivate();
	Sleep(2.0);
	SetPhysics(PHYS_None);
}

state TrackWarhead
{
	ignores SeePlayer, EnemyNotVisible;

	function FindEnemy()
	{
		local Pawn P;

		Target = None;
		Enemy = None;
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
            if ( IsValidTarget(P) )
			{
				Enemy = P;
				GotoState('ActiveCannon');
			}
		GotoState('Idle');
	}

	function EndState()
	{
		AmbientSound = None;
		MuzzFlash.bHidden = true;
	}
}

defaultproperties
{
	SampleTime=0.100000
	OldTechLevel=-1
	MaxTechLevel=4
	BuildTime=5.000000
	RemoveTime=5.000000
	MenuName="Automatic Cannon"
	PowerDownTime=15
	BumpTime=2.000000
	HUDMenuClass=class'WFS_TestEngineerHUDMenu'
	SelfDestructEffect=class'UnrealShare.BallExplosion'
	TechLevelIncreasedSound=Sound'UnrealI.Cannon.CannonActivate'
	GunBaseClass=class'WFS_PCSGrBase'
	CannonTeamSkins(0)=Texture'PCSCannonRed'
	CannonTeamSkins(1)=Texture'PCSCannonBlue'
	CannonTeamSkins(2)=Texture'PCSCannonGreen'
	CannonTeamSkins(3)=Texture'jgrfinalgun'
	GunBaseTeamSkins(0)=Texture'PCSGunBaseRed'
	GunBaseTeamSkins(1)=Texture'PCSGunBaseBlue'
	GunBaseTeamSkins(2)=Texture'PCSGunBaseGreen'
	GunBaseTeamSkins(3)=Texture'jGrBase'
	MyTeam=255
}
