//=============================================================================
// WFStatusFrozen.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//=============================================================================
class WFStatusFrozen extends WFPlayerStatus;

var() float FrozenTime;
var float OldRate, OldSimRate;

var WFIceEffect MyEffect;

function bool HandleStatusFor(pawn Other)
{
	local WFStatusFrozen s;

	// remove any current status of this type
	s = WFStatusFrozen(Other.FindInventoryType(self.class));
	if ((s != None) && s.bActive)
	{
		// reset the existing frozen status
		s.ResetStatus();
		Destroy();
		return true;
	}

	return false;
}

function ResetStatus()
{
	if (Owner != None)
	{
		SetTimer(FrozenTime, false);
		FreezeOwner();
	}
}

function FreezeOwner()
{
	local WFPlayer PlayerOwner;
	local WFBot BotOwner;

	PlayerOwner = WFPlayer(Owner);
	if (PlayerOwner != None)
	{
		PlayerOwner.FreezePlayer(FrozenTime, 'FrozenStatus');
		PlayerOwner.bNoFrozenAnim = true;
		//PlayerOwner.ReducedDamageType = 'All';
		return;
	}

	BotOwner = WFBot(Owner);
	if (BotOwner != None)
	{
		BotOwner.FreezeBot(FrozenTime, 'FrozenStatus');
		BotOwner.bNoFrozenAnim = true;
		//BotOwner.ReducedDamageType = 'All';
	}
}

function UnfreezeOwner()
{
	local WFPlayer PlayerOwner;
	local WFBot BotOwner;

	PlayerOwner = WFPlayer(Owner);
	if (PlayerOwner != None)
	{
		PlayerOwner.UnfreezePlayer('FrozenStatus');
		PlayerOwner.bNoFrozenAnim = false;
		//PlayerOwner.ReducedDamageType = '';
		return;
	}

	BotOwner = WFBot(Owner);
	if (BotOwner != None)
	{
		BotOwner.UnfreezeBot('FrozenStatus');
		BotOwner.bNoFrozenAnim = false;
		//BotOwner.ReducedDamageType = '';
	}
}

state Activated
{
	function BeginState()
	{
		local WFPlayer PlayerOwner;


		bActive = true;
		PlayerOwner = WFPlayer(Owner);

		FreezeOwner();
		OldRate = Owner.AnimRate;
		OldSimRate = Owner.SimAnim.Y;
		Owner.AnimRate = 0.0;
		Owner.SimAnim.Y = 0.0;
		if (PlayerOwner != None)
			PlayerOwner.ClientAdjustGlow(-0.2,vect(0,0,200));

		if (MyEffect == None)
		{
			MyEffect = spawn(class'WFIceEffect', Owner,, Owner.Location, Owner.Rotation);
			MyEffect.InitFor(Owner);
		}

		SetTimer(FrozenTime*ScaleFactor, false);
	}


	function Timer()
	{
		UsedUp();
	}
}

function Destroyed()
{
	local WFPlayer PlayerOwner;

	if (MyEffect != None)
		MyEffect.Destroy();

	PlayerOwner = WFPlayer(Owner);
	if (PlayerOwner != None)
		PlayerOwner.ClientAdjustGlow(0.2,vect(0,0,-200));
	if (Owner == None)
		warn("WARNING: WFStatusFrozen.Owner == None");
	if (Owner.IsInState('Frozen'))
	{
		UnfreezeOwner();
		Owner.AnimRate = OldRate;
		Owner.SimAnim.Y = OldSimRate;
	}

	super.Destroyed();
}

defaultproperties
{
	PickupMessage="You have been frozen!"
	ExpireMessage="The frozen effect has worn off."
	FrozenTime=5.000000
	StatusID=4
	StatusType="Frozen"
}