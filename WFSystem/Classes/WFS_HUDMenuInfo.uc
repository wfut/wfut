//=============================================================================
// WFS_HUDMenuInfo.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//=============================================================================
class WFS_HUDMenuInfo extends WFS_PCSystemInfo
	abstract;

var WFS_PCSystemHUD		OwnerHUD;
var WFS_PCSystemPlayer	PlayerOwner;
var Actor			RelatedActor;
var WFS_HUDMenuInfo		ParentMenu;
var WFS_HUDMenuInfo		ChildMenu;

var() int			DisplayTime;

var() sound			MenuDisplaySound;
var() sound			MenuCloseSound;

var int				DisplayTimeLeft;

function PostBeginPlay()
{
	// don't do this for child menus
	if ((DisplayTime != 0) && (WFS_HUDMenuInfo(Owner) == None))
	{
		DisplayTimeLeft = DisplayTime;
		SetTimer(1.0, true);
	}

	if (MenuDisplaySound != none)
		PlayerOwner.PlaySound(MenuDisplaySound, SLOT_Interface, 10.0);
}

// first place it's safe to access OwnerHUD or PlayerOwner
function Initialise();

// render the menu text (implement in sub-class)
function DisplayMenu(canvas Canvas)
{
	if (ChildMenu != none)
	{
		ChildMenu.DisplayMenu(Canvas);
		return;
	}
	// add menu rendering code here
}

// proccess a selection
function ProcessSelection(int Selection)
{
	DisplayTimeLeft = DisplayTime;

	if (ChildMenu != none)
	{
		ChildMenu.ProcessSelection(Selection);
		return;
	}
}

function WFS_HUDMenuInfo CreateChildMenu(class<WFS_HUDMenuInfo> ChildClass)
{
	ChildMenu = Spawn(ChildClass, self);
	if (ChildMenu != none)
	{
		ChildMenu.ParentMenu = self;
		ChildMenu.OwnerHUD = OwnerHUD;
		ChildMenu.PlayerOwner = PlayerOwner;
		ChildMenu.RelatedActor = RelatedActor;
		ChildMenu.Initialise();
		return ChildMenu;
	}
	return none;
}

// If bHUDMenuMode is true then player will remain in 'HUD Menu' mode after
// menu closes. MenuDynamicHUD uses this when displaying a new menu when a HUDMenu
// is already being displayed (to avoid setting bHUDMenu to false then true again
// for the new menu).
function CloseMenu(optional bool bHUDMenuMode)
{
	if (ParentMenu != none)
		ParentMenu.CloseMenu();
	else
	{
		if (!bHUDMenuMode)
			PlayerOwner.bHUDMenu = false;

		if (MenuCloseSound != none)
			PlayerOwner.PlaySound(MenuCloseSound, SLOT_Interface, 10.0);

		if (ChildMenu != none)
			ChildMenu.Destroy();

		if (OwnerHUD.HUDMenu == self)
			OwnerHUD.HUDMenu = None;

		Destroy();
	}
}

function Timer()
{
	DisplayTimeLeft--;
	if (DisplayTimeLeft <= 0)
		CloseMenu();
}

defaultproperties
{
}