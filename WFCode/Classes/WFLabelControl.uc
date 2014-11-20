class WFLabelControl extends UWindowLabelControl;

var font TextFont;

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;

	Super(UWindowDialogControl).BeforePaint(C, X, Y);

	if (TextFont != None) C.Font = TextFont;
	else C.Font = Root.Fonts[Font];
	TextSize(C, Text, W, H);
	WinHeight = H+1;
	//WinWidth = W+1;
	TextY = (WinHeight - H) / 2;
	switch (Align)
	{
		case TA_Left:
			break;
		case TA_Center:
			TextX = (WinWidth - W)/2;
			break;
		case TA_Right:
			TextX = WinWidth - W;
			break;
	}
}

function Paint(Canvas C, float X, float Y)
{
	if(Text != "")
	{
		C.DrawColor = TextColor;
		if (TextFont != None) C.Font = TextFont;
		else C.Font = Root.Fonts[Font];
		ClipText(C, TextX, TextY, Text);
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
	}
}

function SetTextFont(font NewFont)
{
	TextFont = NewFont;
}