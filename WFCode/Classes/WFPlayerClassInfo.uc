//=============================================================================
// WFPlayerClassInfo.
//=============================================================================
class WFPlayerClassInfo extends WFS_PlayerClassInfo
	abstract
	config(WeaponsFactory);

var() float TranslocatorRange; // the maximum distance that players can translocate
var() float TranslocatorDelay; // the time delay between each use
var() int TranslocatorAmmoUsed; // the amount of charge used per use

var() bool bNoImpactHammer;
var() bool bNoEnforcer;

var() bool bCanIdentify; // if true, this class can be identified using the HUD
var() bool bDisplayArmorID; // if true, player armor values will be displayed for HUD IDs

var() config string CommandSlot[20]; // customisable command slots (accessed by class_commandX)

static function InitialisePlayer(pawn Other)
{
	SetClassName(Other, default.ClassName);
	super.InitialisePlayer(Other);
}

static function SendEvent(pawn Other, string EventID)
{
	if ((WFPlayer(Other) == None) || (EventID == ""))
		return;

	WFPlayer(Other).ClientReceiveEvent(EventID, 'Special');
}

// used to determine if a player class is immune to a status type
static function bool IsImmuneTo(class<WFPlayerStatus> StatusClass)
{
	return false;
}

static function bool PawnIsImmuneTo(pawn Other, class<WFPlayerStatus> StatusClass)
{
	local WFPlayer WFP;
	local WFBot WFB;

	WFP = WFPlayer(Other);
	if (WFP != None)
		return WFP.IsImmuneTo(StatusClass);
	else
	{
		WFB = WFBot(Other);
		if (WFB != None)
			return WFB.IsImmuneTo(StatusClass);
	}

	return false;
}

static function PlayerTakeDamage(pawn Other, out int Damage, out Pawn instigatedBy,	out vector hitlocation, out vector momentum, out name damageType, out byte bIgnoreDamage)
{
	if (Other.IsInState('Frozen') && (Other.FindInventoryType(class'WFStatusFrozen') != None))
		Damage *= 0.5;

	if (Other.Level.Game.bTeamGame && (instigatedBy != None) && (instigatedBy != Other)
		&& TeamGamePlus(Other.Level.Game).IsOnTeam(instigatedBy, Other.PlayerReplicationInfo.Team))
			Momentum *= TeamGamePlus(Other.Level.Game).FriendlyFireScale;

	super.PlayerTakeDamage(Other, Damage, instigatedBy, hitlocation, momentum, damageType, bIgnoreDamage);
}

static function SetClassName(pawn Other, string NewClassName)
{
	local WF_PRI WFPRI;
	local WF_BotPRI WFBotPRI;

	WFPRI = WF_PRI(Other.PlayerReplicationInfo);
	if (WFPRI != None)
		WFPRI.ClassName = NewClassName;
	else
	{
		WFBotPRI = WF_BotPRI(Other.PlayerReplicationInfo);
		if (WFBotPRI != None)
			WFBotPRI.ClassName = NewClassName;
	}
}

static function string GetClassName(pawn Other)
{
	local WF_PRI WFPRI;
	local WF_BotPRI WFBotPRI;

	WFPRI = WF_PRI(Other.PlayerReplicationInfo);
	if (WFPRI != None)
		return WFPRI.ClassName;
	else
	{
		WFBotPRI = WF_BotPRI(Other.PlayerReplicationInfo);
		if (WFBotPRI != None)
			return WFBotPRI.ClassName;
	}

	return "";
}

// called to see if item class is valid (return true if ItemClass is valid)
static function bool ValidInventoryType(pawn Other, class<inventory> ItemClass)
{
	if (default.DefaultInventory.static.IsDefaultInventory(ItemClass))
		return true;

	if (ItemClass == class'Enforcer')
		return true;

	if (ItemClass.default.bIsAnArmor && (default.Armor > 0))
		return true;

	if (ClassIsChildOf(ItemClass, class'WFBackPack'))
		return true;

	// allow standard UDamage, JumpBoot, and Invisibility pickups
	// (can be removed for some player classes later if necessary)
	if (ItemClass == class'UDamage')
		return true;

	if (ItemClass == class'UT_JumpBoots')
		return true;

	if (ItemClass == class'UT_Invisibility')
		return true;

	// debug
	if (ClassIsChildOf(ItemClass, class'WFS_PCSGrenadeItem'))
		return true;

	if (ClassIsChildOf(ItemClass, class'WFPlayerStatus'))
		return true;

	return false;
}

// handle a pickup query
static function bool HandlePickupQuery(Pawn Other, inventory Item)
{
	local weapon w;

	if (Item.IsA('Enforcer'))
	{
		w = weapon(Other.FindInventoryType(class'Enforcer'));
		if ((w != none) && (w.AmmoType != none))
		{
			w.AmmoType.AddAmmo(weapon(Item).PickupAmmoCount);
			Item.PlaySound(item.PickupSound);
			Item.SetRespawn();
		}

		return true;
	}

	return false;
}

// ensure that players can't throw out their default weapons
static function AddDefaultInventory(actor GameActor, pawn Other)
{
	local inventory Inv;
	local bot aBot;
	local WFTranslocator TL;

	//super.AddDefaultInventory(GameActor, Other);

	for (Inv=Other.Inventory; Inv!=None; Inv=Inv.Inventory)
		if (Inv.IsA('Weapon'))
			Weapon(Inv).bCanThrow = False;

	// replace the standard translocator with the WF translocator
	Inv = Other.FindInventoryType(class'Translocator');

	// Spawn the WF Translocator.
	if (!default.bNoTranslocator && (Other.FindInventoryType(class'WFTranslocator') == None))
	{
		TL = GameActor.Spawn(class'WFTranslocator',,, Other.Location);
		if( TL != None )
		{
			TL.Instigator = Other;
			TL.BecomeItem();
			Other.AddInventory(TL);
			TL.GiveAmmo(Other);
			TL.SetSwitchPriority(Other);
			TL.WeaponSet(Other);
			TL.TranslocateDelay = default.TranslocatorDelay;
			TL.AmmoUsed = default.TranslocatorAmmoUsed;
			TL.MaximumRange = default.TranslocatorRange;
		}
	}

	// remove the old translocator from the players inventory
	if (Inv != None)
	{
		if (Other.IsA('Bot') && (Bot(Other).MyTranslocator == Inv))
		{
			if (TL != None) Bot(Other).MyTranslocator = TL;
			else Bot(Other).MyTranslocator = None;
		}

		Other.DeleteInventory(Inv);
		Inv.Destroy();
	}

	// remove the impact hammer for this player class if bNoImpactHammer set
	Inv = Other.FindInventoryType(class'ImpactHammer');
	if (Inv != None)
	{
		if (default.bNoImpactHammer)
		{
			//Other.DeleteInventory(Inv);
			Inv.Destroy();
			aBot = bot(Other);
			if (aBot != None)
				aBot.bHasImpactHammer = false;
		}
		else Inv.AutoSwitchPriority = Inv.default.AutoSwitchPriority;
	}

	if (default.bNoEnforcer)
	{
		Inv = Other.FindInventoryType(class'Enforcer');
		if (Inv != None)
		{
			//Other.DeleteInventory(Inv);
			if (Weapon(Inv).AmmoType != none)
				Weapon(Inv).AmmoType.AmmoAmount = 0;
			Inv.Destroy();
			aBot = bot(Other);
			if (aBot != None)
				aBot.bHasImpactHammer = false;
		}
	}

	// add default inventory for this class
	if (default.DefaultInventory != none)
		default.DefaultInventory.static.AddInventory(GameActor, Other);

	// set up the players starting armor
	if (default.Armor > 0)
		AddDefaultArmor(GameActor, Other);

	Inv = Other.FindInventoryType(class'WFArmor');
	if (Inv != None)
		WFArmor(Inv).UpdateCharge();
}

defaultproperties
{
	bAllowFeignDeath=false
	bNoTranslocator=False
    ExtendedHUD=Class'WFCustomHUDInfo'
	TranslocatorAmmoUsed=15
	TranslocatorDelay=0.000000
	ArmorManagerClass=class'WFArmor'
	bCanIdentify=True
}
