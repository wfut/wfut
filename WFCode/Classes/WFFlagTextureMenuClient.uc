class WFFlagTextureMenuClient extends UWindowDialogClientWindow;

var UWindowVSplitter Splitter;

function Created()
{
	Super.Created();

	Splitter = UWindowVSplitter(CreateWindow(class'UWindowVSplitter', 0, 0, WinWidth, WinHeight));

	Splitter.BottomClientWindow = Splitter.CreateWindow(class'WFFlagTexturePreviewClient', 0, 0, 100, 100);
	Splitter.TopClientWindow = Splitter.CreateWindow(class'WFFlagTextureMenuSC', 0, 0, 100, 100, OwnerWindow);

	Splitter.bBottomGrow = True;
	Splitter.SplitPos = 100;
//	Splitter.MinWinHeight = 300;
}

function Resized()
{
	Super.Resized();
	Splitter.SetSize(WinWidth, WinHeight);
}

defaultproperties
{
}