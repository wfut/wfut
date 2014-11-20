class WFMapDataListBox extends UWindowListBox;

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	if(WFMapDataList(Item).bSelected)
	{
		C.DrawColor.r = 0;
		C.DrawColor.g = 0;
		C.DrawColor.b = 128;
		DrawStretchedTexture(C, X, Y, W, H-1, Texture'WhiteTexture');
		C.DrawColor.r = 255;
		C.DrawColor.g = 255;
		C.DrawColor.b = 255;
	}
	else
	{
		C.DrawColor.r = 0;
		C.DrawColor.g = 0;
		C.DrawColor.b = 0;
	}

	C.Font = Root.Fonts[F_Normal];

	ClipText(C, X+2, Y, WFMapDataList(Item).DisplayName);
}

function SetSelected(float X, float Y)
{
	local UWindowListBoxItem NewSelected;

	NewSelected = GetItemAt(X, Y);
	SetSelectedItem(NewSelected);
	if ((NewSelected != None) && (DoubleClickList != None)
		&& (DoubleClickList.SelectedItem != None))
	{
		DoubleClickList.SelectedItem.bSelected = false;
		DoubleClickList.SelectedItem = None;
	}
}

defaultproperties
{
     ItemHeight=13.000000
     ListClass=Class'WFMapDataList'
}