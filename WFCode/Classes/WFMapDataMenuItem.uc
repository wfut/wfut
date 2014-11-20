//=============================================================================
// WFMapDataMenuItem.
//=============================================================================
class WFMapDataMenuItem expands UMenuModMenuItem;

const SizeX = 100;
const SizeY = 100;//280

// Called when the menu item is chosen
function Execute()
{
	MenuItem.Owner.Root.CreateWindow(class'WFMapDataMenu', (MenuItem.Owner.Root.WinWidth/2 - (SizeX/2)), (MenuItem.Owner.Root.WinHeight/2 - (SizeY/2)), SizeX, SizeY);
}

defaultproperties
{
     MenuCaption="Setup WF Map Data List"
     MenuHelp="Configure the Map Data Lists for the WF game types."
}