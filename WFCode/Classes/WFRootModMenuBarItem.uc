class WFRootModMenuBarItem extends UWindowMenuBarItem;

var bool OkayToLoad;
var UWindowMessageBox VerificationBox;
var float OrigX, OrigY;

function Select()
{
	if (VerificationBox != None) return;
	else if (!OkayToLoad)
	{
		VerificationBox = Owner.MessageBox("Mod Menu Load Verification", "Are you sure you want to load the contents of the mod menu?", MB_YesNo, MR_No, MR_Yes, 20 );
		OrigX = Owner.Root.MouseX;
		OrigY = Owner.Root.MouseY;
		return;
	}

	Owner.LookAndFeel.PlayMenuSound(Owner, MS_MenuPullDown);
	Menu.ShowWindow();
	Menu.WinLeft = ItemLeft + Owner.WinLeft;
	Menu.WinTop = 14;
	Menu.WinWidth = 100;
	Menu.WinHeight = 100;
}

defaultproperties
{
}
