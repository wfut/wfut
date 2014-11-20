class WFGameMenuItem extends UMenuModMenuItem;

function execute()
{

	local int WinWidth, WinHeight, WinLeft, WinTop;

	WinWidth = Min(400, MenuItem.Owner.Root.WinWidth - 50);
	WinHeight = Min(400, MenuItem.Owner.Root.WinHeight - 50);

	WinLeft = MenuItem.Owner.Root.WinWidth/4;
	WinTop = MenuItem.Owner.Root.WinHeight/4;

	MenuItem.Owner.Root.CreateWindow(class'WFGameMenu', WinLeft, WinTop, WinWidth, WinHeight);
}

defaultproperties
{
     MenuCaption="WFUT Menu"
     MenuHelp="Weapons Factory UT Menu"
}
