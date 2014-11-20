class WFBasicKeyBindingsItem extends UMenuModMenuItem;

var int SizeX;
var int SizeY;

// Called when the menu item is chosen
function Execute()
{
	MenuItem.Owner.Root.CreateWindow(class'WFBasicKeyBindingMenu', (MenuItem.Owner.Root.WinWidth/2 - (SizeX/2)), (MenuItem.Owner.Root.WinHeight/2 - (SizeY/2)), SizeX, SizeY);
}

defaultproperties
{
     MenuCaption="WF Config Test"
     MenuHelp="Configure basic WFUT key bindings."
     SizeY=312
     SizeX=250
}

