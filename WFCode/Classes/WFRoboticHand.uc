class WFRoboticHand extends WFWeapon;

var float ChargeSize, Count;
var() sound AltFireSound;
var() sound TensionSound;

var() float RepairRange;
var float MaxScale;
var float ScaleRate;
var float RecoilSpeed;

var int BaseAmount;
var int RandomAmount;

function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist;
	local bool bRetreating;
	local Pawn P;

	bUseAltMode = 0;
	P = Pawn(Owner);

	if ( (P == None) || (P.Enemy == None) )
		return 0;

	EnemyDist = VSize(P.Enemy.Location - Owner.Location);
	if ( (EnemyDist < 750) && P.IsA('Bot') && Bot(P).bNovice && (P.Skill <= 2) && !P.Enemy.IsA('Bot') && (ImpactHammer(P.Enemy.Weapon) != None) )
		return FClamp(300/(EnemyDist + 1), 0.6, 0.75);

	if ( EnemyDist > 400 )
		return 0.1;
	if ( (P.Weapon != self) && (EnemyDist < 120) )
		return 0.25;

	return ( FMin(0.8, 81/(EnemyDist + 1)) );
}

function float SuggestAttackStyle()
{
	return 10.0;
}

function float SuggestDefenseStyle()
{
	return -2.0;
}

simulated function PlayPostSelect()
{
	local Bot B;

	if ( Level.NetMode == NM_Client )
	{
		Super.PlayPostSelect();
		return;
	}

	B = Bot(Owner);

	if ( (B != None) && (B.Enemy != None) )
	{
		B.PlayFiring();
		B.bFire = 1;
		B.bAltFire = 0;
		Fire(1.0);
	}
}

simulated function bool ClientFire( float Value )
{
	if ( bCanClientFire )
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
		Owner.PlayOwnedSound(Misc1Sound, SLOT_Misc, 1.3*Pawn(Owner).SoundDampening);
		PlayAnim('Pull', 0.2, 0.05);
		if ( Role < ROLE_Authority )
			GotoState('ClientFiring');
		return true;
	}
	return false;
}

function Fire( float Value )
{
	if (!WeaponActive())
		return;

	NotifyFired();
	bPointing=True;
	bCanClientFire = true;
	ClientFire(Value);
	Pawn(Owner).PlayRecoil(FiringSpeed);
	GoToState('Firing');
}

function AltFire( float Value )
{
	if (!WeaponActive())
		return;

	NotifyFired();
	bPointing=True;
	bCanClientFire = true;
	Pawn(Owner).PlayRecoil(FiringSpeed);
	TraceAltFire();
	ClientAltFire(value);
	GoToState('AltFiring');
}

simulated function ClientWeaponEvent(name EventType)
{
	if ( EventType == 'FireBlast' )
	{
		PlayFiring();
		GotoState('ClientFireBlast');
	}
}

simulated function PlayFiring()
{
	if (Owner != None)
	{
		if ( Affector != None )
			Affector.FireEffect();
		Owner.PlayOwnedSound(FireSound, SLOT_Misc, 1.7*Pawn(Owner).SoundDampening,,,);
		if ( PlayerPawn(Owner) != None )
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		PlayAnim( 'Fire', 0.65 );
	}
}

simulated function PlayAltFiring()
{
	if (Owner != None)
	{
		if ( Affector != None )
			Affector.FireEffect();
		PlayOwnedSound(AltFireSound, SLOT_Misc, 1.7*Pawn(Owner).SoundDampening,,,);
		LoopAnim( 'Fire', 0.65);
	}
}

state Firing
{
	function AltFire(float F)
	{
	}

	function Tick( float DeltaTime )
	{
		local Pawn P;
		local Rotator EnemyRot;
		local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
		local actor HitActor;

		if ( bChangeWeapon )
			GotoState('DownWeapon');

		if (  Bot(Owner) != None )
		{
			if ( Bot(Owner).Enemy == None )
				Bot(Owner).bFire = 0;
			else
				Bot(Owner).bFire = 1;
		}
		P = Pawn(Owner);
		if ( P == None )
		{
			AmbientSound = None;
			GotoState('');
			return;
		}
		else if( P.bFire==0 )
		{
			TraceFire(0);
			PlayFiring();
			GoToState('FireBlast');
			return;
		}

		ChargeSize += 0.75 * DeltaTime;
		ThirdPersonScale = FMin(ThirdPersonScale + (ScaleRate * DeltaTime), MaxScale);

		Count += DeltaTime;
		if ( Count > 0.2 )
		{
			Count = 0;
			Owner.MakeNoise(1.0);
		}
		if (ChargeSize > 1)
		{
			if ( !P.IsA('PlayerPawn') && (P.Enemy != None) )
			{
				EnemyRot = Rotator(P.Enemy.Location - P.Location);
				EnemyRot.Yaw = EnemyRot.Yaw & 65535;
				if ( (abs(EnemyRot.Yaw - (P.Rotation.Yaw & 65535)) > 8000)
					&& (abs(EnemyRot.Yaw - (P.Rotation.Yaw & 65535)) < 57535) )
					return;
				GetAxes(EnemyRot,X,Y,Z);
			}
			else
				GetAxes(P.ViewRotation, X, Y, Z);
			StartTrace = P.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
			if ( (Level.NetMode == NM_Standalone) && P.IsA('PlayerPawn') )
				EndTrace = StartTrace + 25 * X;
			else
				EndTrace = StartTrace + 60 * X;
			HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
			if ( (HitActor != None) && (HitActor.DrawType == DT_Mesh) )
			{
				ProcessTraceHit(HitActor, HitLocation, HitNormal, vector(AdjustedAim), Y, Z);
				PlayFiring();
				GoToState('FireBlast');
			}
		}
	}

	function BeginState()
	{
		ChargeSize = 0.0;
		Count = 0.0;
	}

	function EndState()
	{
		Super.EndState();
		AmbientSound = None;
		ThirdPersonScale = 0.0;
		Pawn(Owner).PlayRecoil(FiringSpeed);
	}

Begin:
	FinishAnim();
	AmbientSound = TensionSound;
	SoundVolume = 255*Pawn(Owner).SoundDampening;
	LoopAnim('Shake', 0.9);
}

state ClientFiring
{
	simulated function AnimEnd()
	{
		AmbientSound = TensionSound;
		SoundVolume = 255*Pawn(Owner).SoundDampening;
		LoopAnim('Shake', 0.9);
		Disable('AnimEnd');
	}
}

state FireBlast
{
	function Fire(float F)
	{
	}
	function AltFire(float F)
	{
	}

Begin:
	if ( (Level.NetMode != NM_Standalone) && Owner.IsA('PlayerPawn')
		&& (ViewPort(PlayerPawn(Owner).Player) == None) )
		PlayerPawn(Owner).ClientWeaponEvent('FireBlast');
	FinishAnim();
	Finish();
}

state ClientFireBlast
{
	simulated function bool ClientFire(float Value)
	{
		return false;
	}

	simulated function bool ClientAltFire(float Value)
	{
		return false;
	}

	simulated function AnimEnd()
	{
		if ( Pawn(Owner) == None )
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

function TraceFire(float accuracy)
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local actor Other;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, AimError, False, False);
	EndTrace = StartTrace + 120.0 * vector(AdjustedAim);
	Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, EndTrace, StartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim), Y, Z);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local pawn PawnOther;

	if ( (Other == None) || (Other == Owner) || (Other == self) || (Owner == None))
		return;

	ChargeSize = FMin(ChargeSize, 1.5);
	if ( (Other == Level) || Other.IsA('Mover') )
	{
		ChargeSize = FMax(ChargeSize, 1.0);
		if ( VSize(HitLocation - Owner.Location) < 80 )
			Spawn(class'ImpactMark',,, HitLocation+HitNormal, Rotator(HitNormal));
		Owner.TakeDamage(36.0, Pawn(Owner), HitLocation, -69000.0 * ChargeSize * X, MyDamageType);
	}
	if ( Other != Level )
	{
		if ( Other.bIsPawn && (VSize(HitLocation - Owner.Location) > 90) )
			return;
		Other.TakeDamage(60.0 * ChargeSize, Pawn(Owner), HitLocation, 66000.0 * ChargeSize * X, MyDamageType);
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
		if (Other.bIsPawn)
		{
			PawnOther = pawn(Other);
			if (PawnOther.bIsPlayer && (PawnOther.Health > 0))
				GiveConcussionTo(PawnOther);
		}
	}
}

function GiveConcussionTo(pawn Other)
{
	local class<WFPlayerClassInfo> PCI;
	local WFPlayerStatus s;

	PCI = class<WFPlayerClassInfo>(class'WFS_PlayerClassInfo'.static.GetPCIFor(Other));
	if ( (!class'WFPlayerClassInfo'.static.PawnIsImmuneTo(Other, class'WFStatusConcussed'))
		&& (Other.PlayerReplicationInfo.Team != pawn(Owner).PlayerReplicationInfo.Team))
	{
		s = spawn(class'WFStatusConcussed',,, Other.Location);
		s.GiveStatusTo(Other, pawn(Owner), FClamp(ChargeSize/2.0, 0.25, 1.0));
	}
}

function TraceAltFire()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local actor Other;
	local pawn aPawn, best;
	local Projectile P;
	local float speed, bestproduct, dotproduct;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	bestproduct = 0.0;
	best = None;
	foreach VisibleCollidingActors(class'pawn', aPawn, RepairRange, Owner.Location)
	{
		if ((aPawn != None) && aPawn.bIsPlayer && (aPawn.Health > 0)
			&& (aPawn.PlayerReplicationInfo.Team == pawn(owner).PlayerReplicationInfo.Team))
		{
			dotproduct = Normal(aPawn.Location - Owner.Location) dot X;
			if ((dotproduct > 0.7) && (dotproduct > bestproduct))
			{
				best = aPawn;
				bestProduct = dotproduct;
			}
		}
	}

	if (Best != None)
	{
		HitNormal = normal(Owner.Location - Best.Location);
		ProcessAltTraceHit(Best, Best.Location + HitNormal*20.0 + vect(0,0,1)*20, HitNormal, X, Y, Z);
	}
}

function ProcessAltTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local vector realLoc;
	local inventory Item, BestArmor;

	if ( (Other == None) || (Other == Owner) || (Other == self) || (Owner == None) )
		return;

	if (Other.bIsPawn)
	{
		BestArmor = None;
		for (Item = Other.Inventory; Item != None; Item = Item.Inventory)
		{
			if ( Item.bIsAnArmor && ((BestArmor == None)
				|| (Item.AbsorptionPriority > BestArmor.AbsorptionPriority)) )
					BestArmor = Item;
		}
	}

	if (BestArmor != None)
	{
		if (CanRepairArmor(BestArmor))
		{
			spawn(class'WFRoboticHandArmorSparks',,, HitLocation + HitNormal * 4, rotator(HitNormal));
			RepairArmor(BestArmor);
		}
	}
}

function RepairArmor(inventory Item)
{
	local int amount;
	amount = (BaseAmount + Rand(RandomAmount));
	if (Item.IsA('WFS_PCSArmor'))
		WFS_PCSArmor(Item).AddArmor(amount);
	else
		Item.Charge = Min(Item.Charge + amount, Item.default.Charge);
}

function bool CanRepairArmor(inventory Item)
{
	if (Item.IsA('WFS_PCSArmor'))
		return Item.Charge < WFS_PCSArmor(Item).MaxCharge;

	return (Item.Charge < Item.default.Charge);
}

simulated function PlayIdleAnim()
{
	local Bot B;

	B = Bot(Owner);

	if ( (B != None) && (B.Enemy != None) )
	{
		B.PlayFiring();
		B.bFire = 1;
		B.bAltFire = 0;
		Fire(1.0);
	}
	else if ( Mesh != PickupViewMesh )
		TweenAnim( 'Still', 1.0);
}

defaultproperties
{
	RepairRange=150.0
	AltFireSound=Sound'Botpack.ASMD.ImpactFire'
	TensionSound=Sound'Botpack.ASMD.ImpactLoop'
	WeaponDescription="Classification: Melee Piston\n\nPrimary Fire: When trigger is held down, touch opponents with this piston to inflict massive damage.\n\nSecondary Fire: Damages opponents at close range and has the ability to deflect projectiles.\n\nTechniques: Shoot at the ground while jumping to jump extra high."
	InstFog=(X=475.000000,Y=325.000000,Z=145.000000)
	bMeleeWeapon=True
	bRapidFire=True
	MyDamageType=impact
	RefireRate=1.000000
	AltRefireRate=1.000000
	FireSound=Sound'Botpack.ASMD.ImpactAltFireRelease'
	SelectSound=Sound'Botpack.ASMD.ImpactPickup'
	Misc1Sound=Sound'Botpack.ASMD.ImpactAltFireStart'
	DeathMessage="%o got smeared by %k's %w."
	NameColor=(G=192,B=0)
	PickupMessage="You got the Robotic Hand."
	ItemName="Robotic Hand"
	PlayerViewOffset=(X=3.800000,Y=-1.600000,Z=-1.800000)
	PlayerViewMesh=LodMesh'Botpack.ImpactHammer'
	PickupViewMesh=Mesh'TazerProja'
	//ThirdPersonMesh=LodMesh'Botpack.ImpactHandm'
	ThirdPersonMesh=Mesh'TazerProja'
	ThirdPersonScale=0.0
    StatusIcon=Texture'WFMedia.WeaponRobotHand'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Icon=Texture'Botpack.Icons.UseHammer'
	Mesh=LodMesh'Botpack.ImpPick'
	bNoSmooth=False
	InventoryGroup=2
	AutoSwitchPriority=1
	SoundRadius=50
	SoundVolume=200
	MaxScale=1.0
	RecoilSpeed=1.0
	ScaleRate=0.75
	Mass=15
	bRapidFire=False
    BaseAmount=10
    RandomAmount=10
}
