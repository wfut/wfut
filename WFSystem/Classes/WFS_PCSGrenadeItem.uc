//=============================================================================
// WFS_PCSGrenadeItem.
//
// This is an abstract class that handles all the off-hand grenade throwing
// code using the bGrenX variables from WFS_PCSystemPlayer.
//
// To implement a grenade handle the ThrowGrenade() and ExplodedWhileHeld()
// functions in a sub-class to spawn the actual grenade class.
//=============================================================================
class WFS_PCSGrenadeItem extends TournamentPickup
	abstract;

var() byte GrenadeSlot; // the input var used to throw grenade (1 for bGren1, 2 for bGren2, etc)

var() float DetonationTime; // time before grenade explodes
var() float PrimingTime; // the minimum wait before the grenade is thrown
var() float ThrowDelayTime; // the delay between grenades

var() bool bAutoThrow; // automatically throw the grenade after AutoThrowTime seconds
var() float AutoThrowTime; // time before the grenade is automatically thrown

var() bool bSingleGrenade; // only one grenade can be thrown out at a time

// Sound variables.
var() sound ThrowSound; // sound played when grenade is thrown

// Internal variables.
var WFS_PCSystemPlayer PCSOwner; // the WFS_PCSystemPlayer owner of this grenade

var bool bThrowing;
var float ThrowingTime; // how long grenade has been held for

var actor ThrownGrenade; // used to prevent more than one grenade being thrown out at a time if bSingleGrenade

function PreBeginPlay()
{
	// For some reason this needs to be done or the item will auto-activate
	// even if bAutoActivate is set to false.
	bAutoActivate = default.bAutoActivate;
}

function GiveTo(pawn Other)
{
	super.GiveTo(Other);

	if (Other.IsA('WFS_PCSystemPlayer'))
		PCSOwner = WFS_PCSystemPlayer(Other);
}

// Check the grenade input vars while in Idle2 state (while in players inventory)
state Idle2
{
	function Tick(float DeltaTime)
	{
		if ((Role == ROLE_Authority) && (Owner != None))
		{
			if ((PCSOwner == None) || (NumCopies < 0))
				return;

			// if last grenade activated before it was thrown wait until
			// grenade var is reset to false (stops another grenade from being
			// thrown immediately after the last one)
			if (bThrowing)
			{
				if (CheckForThrow())
					bThrowing = false;
				else return;
			}

			switch (GrenadeSlot)
			{
				case 1:
					if (PCSOwner.bGren1 && CanThrowGrenade())
						GotoState('Throwing');
					break;
				case 2:
					if (PCSOwner.bGren2 && CanThrowGrenade())
						GotoState('Throwing');
					break;
				case 3:
					if (PCSOwner.bGren3 && CanThrowGrenade())
						GotoState('Throwing');
					break;
				case 4:
					if (PCSOwner.bGren4 && CanThrowGrenade())
						GotoState('Throwing');
					break;
			}
		}
	}
}

// checks to see if grenade input var has been released
// returns true if var is false
function bool CheckForThrow()
{
	switch (GrenadeSlot)
	{
		case 1:
			if (!PCSOwner.bGren1)
				return true;
			break;
		case 2:
			if (!PCSOwner.bGren2)
				return true;
			break;
		case 3:
			if (!PCSOwner.bGren3)
				return true;
			break;
		case 4:
			if (!PCSOwner.bGren4)
				return true;
			break;
	}

	return false;
}

// returns the value of the grenade var for the current GrenadeSlot
function bool CheckGrenadeSlot()
{
	switch (GrenadeSlot)
	{
		case 1:
			return PCSOwner.bGren1;
			break;
		case 2:
			return PCSOwner.bGren2;
			break;
		case 3:
			return PCSOwner.bGren3;
			break;
		case 4:
			return PCSOwner.bGren4;
			break;
	}
}

// the grenade is being thrown
state Throwing
{
	function Tick(float DeltaTime)
	{
		if (Role == ROLE_Authority)
		{
			ThrowingTime += DeltaTime;

			if ((DetonationTime > 0) && (ThrowingTime >= DetonationTime))
			{
				NumCopies--;
				ThrownGrenade = ExplodedWhileHeld();
				/*if (NumCopies < 0)
					Destroy();
				else*/ if (bSingleGrenade || (ThrowDelayTime > 0.0))
					GotoState('Delay');
				else GotoState('Idle2');
			}

			if (CheckForThrow() || (bAutoThrow && (ThrowingTime >= AutoThrowTime)))
			{
				NumCopies--;
				bThrowing = false;
				Owner.PlaySound(ThrowSound);
				ThrownGrenade = ThrowGrenade();
				/*if (NumCopies < 0)
					Destroy();
				else*/ if (bSingleGrenade || (ThrowDelayTime > 0.0))
					GotoState('Delay');
				else GotoState('Idle2');
			}
		}
	}

Begin:
	ThrowingTime = 0;
	bThrowing = true;
	if (PrimingTime > 0.0)
	{
		Disable('Tick');
		Sleep(PrimingTime);
		Enable('Tick');
	}
}

state Delay
{
	function Tick(float DeltaTime)
	{
		if (CanThrowGrenade())
			GotoState('Idle2');
	}

Begin:
	if (ThrowDelayTime > 0.0)
	{
		Disable('Tick');
		Sleep(ThrowDelayTime);
		Enable('Tick');
	}
}

function bool CanThrowGrenade()
{
	if (bSingleGrenade && ((ThrownGrenade == None) || ThrownGrenade.bDeleteMe))
		return true;

	return false;
}

//=============================================================================
// Grenade Code.
// Implement these functions in a sub-class.
// The return value should be the spawned grenade (if any).

// the grenade detonated before the player could throw it
function actor ExplodedWhileHeld();

// throw the grenade
function actor ThrowGrenade();

defaultproperties
{
	bCanHaveMultipleCopies=True
	bAutoActivate=False
	bActivatable=True
	bSingleGrenade=True
}