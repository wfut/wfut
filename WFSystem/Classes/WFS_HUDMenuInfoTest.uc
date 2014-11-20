//=============================================================================
// WFS_HUDMenuInfoTest.
//=============================================================================
class WFS_HUDMenuInfoTest extends WFS_HUDTextMenu;

// proccess a selection
function ProcessSelection(int Selection)
{
	DisplayTimeLeft = DisplayTime;

	if (ChildMenu != none)
	{
		ChildMenu.ProcessSelection(Selection);
		return;
	}

	switch (Selection)
	{
		case 1:
			PlayerOwner.PlaySound(sound'cd1', SLOT_Interface, 10.0, true);
			PlayerOwner.PlaySound(sound'cd1', SLOT_Misc, 10.0, true);
			break;
		case 2:
			PlayerOwner.PlaySound(sound'cd2', SLOT_Interface, 10.0, true);
			PlayerOwner.PlaySound(sound'cd2', SLOT_Misc, 10.0, true);
			break;
		case 3:
			PlayerOwner.PlaySound(sound'cd3', SLOT_Interface, 10.0, true);
			PlayerOwner.PlaySound(sound'cd3', SLOT_Misc, 10.0, true);
			break;
		case 4:
			PlayerOwner.PlaySound(sound'cd4', SLOT_Interface, 10.0, true);
			PlayerOwner.PlaySound(sound'cd4', SLOT_Misc, 10.0, true);
			break;
		case 5:
			PlayerOwner.PlaySound(sound'cd5', SLOT_Interface, 10.0, true);
			PlayerOwner.PlaySound(sound'cd5', SLOT_Misc, 10.0, true);
			break;
		case 6:
			PlayerOwner.PlaySound(sound'cd6', SLOT_Interface, 10.0, true);
			PlayerOwner.PlaySound(sound'cd6', SLOT_Misc, 10.0, true);
			break;
		case 7:
			PlayerOwner.PlaySound(sound'cd7', SLOT_Interface, 10.0, true);
			PlayerOwner.PlaySound(sound'cd7', SLOT_Misc, 10.0, true);
			break;
		case 8:
			PlayerOwner.PlaySound(sound'cd8', SLOT_Interface, 10.0, true);
			PlayerOwner.PlaySound(sound'cd8', SLOT_Misc, 10.0, true);
			break;
		case 9:
			PlayerOwner.PlaySound(sound'cd9', SLOT_Interface, 10.0, true);
			PlayerOwner.PlaySound(sound'cd9', SLOT_Misc, 10.0, true);
			break;
		case 10:
			CloseMenu();
			break;
	}
}

simulated function DisplayMenu(canvas Canvas)
{
	local int num, i;
	local float XL, YL, YOffset, XLMax;
	local string MenuString;

	if (ChildMenu != none)
	{
		ChildMenu.DisplayMenu(Canvas);
		return;
	}

	MenuDisplaySetup(Canvas);

	Canvas.StrLen("TEST", XL, YL);
	YOffset = YL;

	XLMax = GetLongestStringWidth(Canvas);

	// draw title string
	Canvas.StrLen(MenuTitle, XL, YL);
	Canvas.SetPos(Canvas.ClipX/2 - XL/2, (Canvas.ClipY/2 - ((NumOptions/2)*YOffset)) - YOffset);
	Canvas.DrawText(MenuTitle);

	// draw options
	for (i=0; i<10; i++)
	{
		if (MenuOptions[i] != "")
		{
			if (i == 9) MenuString = SeparatorString$MenuOptions[i];
			else MenuString = i+1$SeparatorString$MenuOptions[i];
			Canvas.StrLen(MenuString, XL, YL);
			Canvas.SetPos(Canvas.ClipX/2 - (XLMax/2), (Canvas.ClipY/2 - ((NumOptions/2)*YOffset)) + YOffset*num);
			Canvas.DrawText(MenuString);
			num++;
		}
	}
}

function MenuDisplaySetup(canvas Canvas)
{
	Canvas.DrawColor = class'ChallengeHUD'.default.WhiteColor;
	Canvas.Font = OwnerHUD.MyFonts.GetBigFont(Canvas.ClipX);
}

defaultproperties
{
	DisplayTime=10
	NumOptions=10
	MenuTitle="--- WFS_HUDMenuInfo Test ---"
	MenuOptions(0)="One"
	MenuOptions(1)="Two"
	MenuOptions(2)="Three"
	MenuOptions(3)="Four"
	MenuOptions(4)="Five"
	MenuOptions(5)="Six"
	MenuOptions(6)="Seven"
	MenuOptions(7)="Eight"
	MenuOptions(8)="Nine"
	MenuOptions(9)="Exit"
}
