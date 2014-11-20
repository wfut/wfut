//=============================================================================
// WFS_PCNotifyWindowObject.
//
// This can be used as a notify message router for using NotifyButton controls
// with framed UWindow client areas.
//
// Set NotifyButton.NotifyWindow to this object, and this objects NoftifyWindow
// to the client window of the GUI UWindow client area.
//=============================================================================
class WFS_PCNotifyWindowObject extends NotifyWindow;

var UWindowDialogClientWindow NotifyWindow;

function Notify(UWindowWindow Window, byte E)
{
	if (UWindowDialogControl(Window) != none)
		NotifyWindow.Notify(UWindowDialogControl(Window), E);
}

defaultproperties
{
}
