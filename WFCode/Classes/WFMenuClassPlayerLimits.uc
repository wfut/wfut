class WFMenuClassPlayerLimits extends UWindowFramedWindow;

function Created()
{
	super.Created();
	if (ClientArea != None)
		WFMenuClassPlayerLimitsCW(ClientArea).FrameOwner = self;
}

function SetupMenu(class<WFS_PCIList> NewClassList)
{
	if (ClientArea != None)
		WFMenuClassPlayerLimitsCW(ClientArea).SetupMenu(NewClassList);
}

defaultproperties
{
	ClientClass=class'WFMenuClassPlayerLimitsCW'
	WindowTitle="WF Class Player Limits"
}