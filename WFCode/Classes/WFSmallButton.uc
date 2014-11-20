class WFSmallButton extends UWindowSmallButton;

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;
	C.Font = Root.Fonts[Font];

	TextSize(C, RemoveAmpersand(Text), W, H);

	TextX = (WinWidth-W)/2;
	TextY = (WinHeight-H)/2;

	//TextX += 1;
	//TextY += 1;
}
