class WFMapDataInfoButton extends UWindowSmallButton;

function Click(float X, float Y)
{
	local UWindowFramedWindow W;
	local WFMapDataListCW C;

	W = UWindowFramedWindow(GetParent(class'UWindowFramedWindow'));
	if (W != None)
	{
		C = WFMapDataListCW(w.ClientArea);
		if (C != None)
			C.DisplayInfo();
	}
}

defaultproperties
{
}