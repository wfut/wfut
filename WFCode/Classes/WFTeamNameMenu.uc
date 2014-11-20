//=============================================================================
// WFTeamNameMenu.
//=============================================================================
class WFTeamNameMenu expands UWindowFramedWindow;

function Created()
{
	super.Created();

	WinWidth = 250;
	WinHeight = 150;

	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;
}

defaultproperties
{
	ClientClass=class'WFTeamNameMenuCW'
	WindowTitle="Customise Team Names"
}


