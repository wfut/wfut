class WFFlameThrower expands WFWeapon;

var WFFlameThrowerFlameGen Flames;
var float count;

function Fire( float Value )
{
	if (!WeaponActive())
		return;

	if ( (AmmoType == None) && (AmmoName != None) )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( (GetStateName() == 'AltFiring') || AmmoType.UseAmmo(1) )
	{
		GotoState ('NormalFire');
		bPointing=True;
		bCanClientFire = true;
		ClientFire( value );
	}
}

function AltFire( float Value )
{
}

simulated function bool ClientAltFire( float Value )
{
	return false;
}

state NormalFire
{
ignores AnimEnd;

	function Fire( float Value ) {}
	function AltFire( float Value ) {}

	function BeginState()
	{
		if (Flames == None)
		{
			Flames = spawn(class'WFFlameThrowerFlameGen', self,, Owner.Location);
			Flames.Instigator = Instigator;
			if ( FireOffset.Y == 0 )
				Flames.bCenter = true;
		}
		count = 0;
	}

	function Tick(float DeltaTime)
	{
		count += DeltaTime;
		if (count >= 0.50)
		{
			AmmoType.UseAmmo(1);
			count = 0;
		}

		if (Owner==None)
		{
			GotoState('Pickup');
			return;
		}

		if (Owner.Region.Zone.bWaterZone || ((Pawn(Owner).bFire == 0) || (AmmoType.AmmoAmount == 0)) )
			Finish();
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
		//else if ( (PawnOwner.bAltFire!=0) || bForceAlt )
		//	Global.AltFire(0);
		else
			GotoState('Idle');
	}

	function EndState()
	{
		if (Flames != None)
		{
			Flames.Destroy();
			Flames = None;
		}
		count = 0;
	}
}

function Destroyed()
{
	if (Flames != None)
		Flames.Destroy();
	super.Destroyed();
}

simulated function bool ClientFire( float Value )
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
		PlayFiring();
		if ( Role < ROLE_Authority )
			GotoState('ClientFiring');
		return true;
	}
	return false;
}

state ClientFiring
{
	//simulated function AnimEnd()
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
		//else if ( Pawn(Owner).bFire != 0 )
		//	Global.ClientFire(0);
		//else if ( Pawn(Owner).bAltFire != 0 )
		//	Global.ClientAltFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}
}
defaultproperties
{
     AmmoName=class'BioAmmo'
     FireOffset=(X=15.000000,Y=-9.000000,Z=-16.000000)
     DeathMessage="%o drank a glass of %k's dripping green load."
     PickupAmmoCount=25
     AutoSwitchPriority=3
     InventoryGroup=3
     PickupMessage="You got the FlameThrower"
     ItemName="FlameThrower"
     PlayerViewOffset=(X=2.000000,Y=-0.700000,Z=-1.150000)
     PlayerViewMesh=LodMesh'UnrealI.BRifle'
     PickupViewMesh=LodMesh'UnrealI.BRiflePick'
     ThirdPersonMesh=LodMesh'UnrealI.BRifle3'
     Mesh=LodMesh'UnrealI.BRiflePick'
     Icon=Texture'Botpack.Icons.UseBio'
     bNoSmooth=False
     CollisionRadius=28.000000
     CollisionHeight=15.000000
}
