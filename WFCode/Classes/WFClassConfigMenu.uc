//=============================================================================
// WFClassConfigMenu.
//=============================================================================
class WFClassConfigMenu expands UWindowFramedWindow;

function Created()
{
	super.Created();

	WinWidth = 250;
	//WinHeight = 150;
	WinHeight = 216;

	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;

	WFClassConfigMenuCW(ClientArea).OwnerFrame = self;
}

defaultproperties
{
	ClientClass=class'WFClassConfigMenuCW'
	WindowTitle="WF Class Configuration"
}


