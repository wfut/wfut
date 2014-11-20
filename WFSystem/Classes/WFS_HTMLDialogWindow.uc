class WFS_HTMLDialogWindow extends UWindowFramedWindow;

function SetHTML(string HTML, optional string NewTitle)
{
	WFS_HTMLDialogWindowCW(ClientArea).SetHTML(HTML);
	if (NewTitle != "")
		WindowTitle = NewTitle;
}

defaultproperties
{
	ClientClass=class'WFS_HTMLDialogWindowCW'
	bSizable=True
	MinWinWidth=200
	MinWinHeight=100
}