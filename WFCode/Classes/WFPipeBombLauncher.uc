class WFPipeBombLauncher extends WFWeapon;

var WFPipeBombList BombList;
var int NumPipeBombs; // updated by BombList

replication
{
	reliable if (bNetOwner && (Role == ROLE_Authority))
		NumPipeBombs;
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	local Color C;

	C.R = 255;
	C.G = 0;
	C.B = 0;

	Tex.DrawColoredText( 20, 18, String(NumPipeBombs), Font'LEDFont2', C );
}

simulated event RenderOverlays( canvas Canvas )
{
	Texture'MiniAmmoled'.NotifyActor = Self;
	Super.RenderOverlays(Canvas);
	Texture'MiniAmmoled'.NotifyActor = None;
}

function GiveTo(pawn Other)
{
	super.GiveTo(Other);
	if (Owner == Other)
	{
		BombList = WFPipeBombList(class'WFS_PlayerClassInfo'.static.FindRelatedActorClass(Other, class'WFPipeBombList'));
		if (BombList == None)
		{
			BombList = spawn(class'WFPipeBombList', Other,, Location);
			class'WFS_PlayerClassInfo'.static.AddRelatedActor(Other, BombList);
			BombList.PBL = self;
			NumPipeBombs = 0;
		}
		else
		{
			BombList.PBL = self;
			NumPipeBombs = BombList.NumPipeBombs;
		}
	}
}

simulated function PlayFiring()
{
	PlayOwnedSound(class'UT_EightBall'.Default.AltFireSound, SLOT_None, 4.0*Pawn(Owner).SoundDampening);
	PlayAnim('Fire', 0.40, 0.05);
}

simulated function PlayAltFiring()
{
	PlayOwnedSound(Misc1Sound, SLOT_None, 4.0*Pawn(Owner).SoundDampening);
	PlayAnim('Fire2', 0.30, 0.05);
}

function Fire( float Value )
{
	local WFPipeBomb b;

	if (!WeaponActive())
		return;

	if ( (AmmoType == None) && (AmmoName != None) )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1) )
	{
		GotoState('NormalFire');
		NotifyFired();
		bPointing=True;
		bCanClientFire = true;
		ClientFire(Value);
		if ( bRapidFire || (FiringSpeed > 0) )
			Pawn(Owner).PlayRecoil(FiringSpeed);
		if ( bInstantHit )
			TraceFire(0.0);
		else
		{
			b = WFPipeBomb(ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget));
			if (BombList != None)
				BombList.AddPipeBomb(b);
		}
	}
}

function AltFire( float Value )
{
	if (!WeaponActive())
		return;

	if (NumPipeBombs > 0)
	{
		NotifyFired();
		GotoState('AltFiring');
		bPointing=True;
		bCanClientFire = true;
		ClientAltFire(Value);
		BombList.DetPipes();
	}
}

/*
state AltFiring
{
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
			else if ( (PawnOwner.bAltFire != 0) && (NumPipeBombs > 0) && (FRand() < AltRefireRate) )
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
		else if ( ((PawnOwner.bAltFire!=0) || bForceAlt) && (NumPipeBombs > 0) )
			Global.AltFire(0);
		else
			GotoState('Idle');
	}
}*/

//
// Change weapon to that specificed by F matching inventory weapon's Inventory Group.
function Weapon WeaponChange( byte F )
{
	local Weapon newWeapon;

	if ( InventoryGroup == F )
	{
		if ( (AmmoType != None) && (AmmoType.AmmoAmount <= 0)
			&& (NumPipeBombs <= 0))
		{
			if ( Inventory == None )
				newWeapon = None;
			else
				newWeapon = Inventory.WeaponChange(F);
			if ( newWeapon == None )
				Pawn(Owner).ClientMessage( ItemName$MessageNoAmmo );
			return newWeapon;
		}
		else
			return self;
	}
	else if ( Inventory == None )
		return None;
	else
		return Inventory.WeaponChange(F);
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
		if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0)
			&& (NumPipeBombs <= 0))
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
	else if ( ((PawnOwner.bAltFire!=0) || bForceAlt ) && (NumPipeBombs > 0) )
		Global.AltFire(0);
	else
		GotoState('Idle');
}

// Return the switch priority of the weapon (normally AutoSwitchPriority, but may be
// modified by environment (or by other factors for bots)
function float SwitchPriority()
{
	local float temp;
	local int bTemp;

	if ( !Owner.IsA('PlayerPawn') )
		return RateSelf(bTemp);
	else if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) && (NumPipeBombs <= 0))
	{
		if ( Pawn(Owner).Weapon == self )
			return -0.5;
		else
			return -1;
	}
	else
		return AutoSwitchPriority;
}

defaultproperties
{
     WeaponDescription="Classification: Heavy Ballistic"
     AmmoName=Class'Botpack.RocketPack'
     PickupAmmoCount=6
     bWarnTarget=True
     bAltWarnTarget=True
     bSplashDamage=True
     bRecommendSplashDamage=True
     FiringSpeed=1.000000
     FireOffset=(X=10.000000,Y=-5.000000,Z=-8.800000)
     ProjectileClass=Class'WFPipeBomb'
     shakemag=350.000000
     shaketime=0.200000
     shakevert=7.500000
     AIRating=0.750000
     RefireRate=0.250000
     AltRefireRate=0.250000
     AltFireSound=Sound'UnrealShare.Eightball.EightAltFire'
     CockingSound=Sound'UnrealShare.Eightball.Loading'
     SelectSound=Sound'UnrealShare.Eightball.Selecting'
     Misc1Sound=Sound'UnrealShare.Eightball.SeekLock'
     Misc2Sound=Sound'UnrealShare.Eightball.SeekLost'
     Misc3Sound=Sound'UnrealShare.Eightball.BarrelMove'
     DeathMessage="%o was smacked down by %k's %w."
     NameColor=(G=0,B=0)
     AutoSwitchPriority=3
     InventoryGroup=3
     PickupMessage="You got the Pipe Bomb Launcher."
     ItemName="Pipe Bomb Launcher"
     PlayerViewOffset=(X=3,Y=-2.25,Z=-2.19)
     PlayerViewMesh=LodMesh'pblauncher'
     PlayerViewScale=0.200000
     BobDamping=0.975000
     PickupViewMesh=LodMesh'plthird1'
     ThirdPersonMesh=LodMesh'plthird1'
     StatusIcon=Texture'WFMedia.WeaponPipeBombs'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.Use8ball'
     Mesh=LodMesh'plthird1'
     bNoSmooth=False
     CollisionHeight=10.000000
}
