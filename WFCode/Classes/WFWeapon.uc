class WFWeapon extends TournamentWeapon;

var() bool bRegisterWeapon;

var() float WeaponActivateDelay; // delay before weapon can fire
var float FirstCreated; // time weapon was first created

function function PostBeginPlay()
{
	FirstCreated = Level.TimeSeconds;
	super.PostBeginPlay();
}

// serverside weapon event
function WeaponEvent(name EventType);

function DropFrom(vector StartLocation)
{
	if (!bCanThrow)
	{
		Destroy();
		return;
	}

	super.DropFrom(StartLocation);
}

function bool WeaponActive()
{
	if ((Owner != None) && Owner.IsA('Bot'))
		return true; // don't need to worry about this for bots

	if ( (FirstCreated != 0.0) && (Owner != None) && (Pawn(Owner).Weapon == Self)
		&& ((Level.TimeSeconds - FirstCreated) >= WeaponActivateDelay) )
		return true;

	return false;
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
	else if ( (PawnOwner.bAltFire!=0) || bForceAlt )
		Global.AltFire(0);
	else
		GotoState('Idle');
}

function Fire( float Value )
{
	if (!WeaponActive())
		return;

	if ( (AmmoType == None) && (AmmoName != None) )
	{
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.UseAmmo(1) )
	{
		NotifyFired();
		GotoState('NormalFire');
		bPointing=True;
		bCanClientFire = true;
		ClientFire(Value);
		if ( bRapidFire || (FiringSpeed > 0) )
			Pawn(Owner).PlayRecoil(FiringSpeed);
		if ( bInstantHit )
			TraceFire(0.0);
		else
			ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
	}
}

function NotifyFired()
{
	local inventory Item;

	for (Item = pawn(Owner).Inventory; Item!=None; Item = Item.Inventory)
	{
		if (WFPickup(Item) != None)
			WFPickup(Item).WeaponFired(self);
		/*
		if (WFCloaker(Item) != None)
			WFCloaker(Item).WeaponFired(self);

		if (WFDisguise(Item) != None)
			WFDisguise(Item).WeaponFired(self);

		if (WFSawnProtector(Item) != None)
			WFDisguise(Item).WeaponFired(self);
		*/
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
	if (AmmoType.UseAmmo(1))
	{
		NotifyFired();
		GotoState('AltFiring');
		bPointing=True;
		bCanClientFire = true;
		ClientAltFire(Value);
		if ( bRapidFire || (FiringSpeed > 0) )
			Pawn(Owner).PlayRecoil(FiringSpeed);
		if ( bAltInstantHit )
			TraceFire(0.0);
		else
			ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
	}
}

function SetSwitchPriority(pawn Other)
{
	local int i;
	local name temp, carried;

	if (!bRegisterWeapon)
		return;

	if ( PlayerPawn(Other) != None )
	{
		for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
			if ( PlayerPawn(Other).WeaponPriority[i] == class.name )
			{
				AutoSwitchPriority = i;
				return;
			}
		// else, register this weapon
		carried = class.name;
		for ( i=AutoSwitchPriority; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++ )
		{
			if ( PlayerPawn(Other).WeaponPriority[i] == '' )
			{
				PlayerPawn(Other).WeaponPriority[i] = carried;
				return;
			}
			else if ( i<ArrayCount(PlayerPawn(Other).WeaponPriority)-1 )
			{
				temp = PlayerPawn(Other).WeaponPriority[i];
				PlayerPawn(Other).WeaponPriority[i] = carried;
				carried = temp;
			}
		}
	}
}

defaultproperties
{
	WeaponActivateDelay=1.0
	bRegisterWeapon=False
	bCanThrow=False
}