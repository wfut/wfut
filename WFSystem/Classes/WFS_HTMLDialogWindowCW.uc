class WFS_HTMLDialogWindowCW extends UWindowDialogClientWindow;

var UWindowHTMLTextArea ClassHelpArea;

function Created()
{
	ClassHelpArea = UWindowHTMLTextArea(CreateWindow(class'UWindowHTMLTextArea', 0, 0, WinWidth, WinHeight));
	ClassHelpArea.Register(self);
}

function Paint(Canvas C, float X, float Y)
{
	ClassHelpArea.SetSize(WinWidth, WinHeight);
	super.Paint(C, X, Y);
}

function SetHTML(string HTML)
{
	if (ClassHelpArea != None)
		ClassHelpArea.SetHTML(HTML);
}

defaultproperties
{
}