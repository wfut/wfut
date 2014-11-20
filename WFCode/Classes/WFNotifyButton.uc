class WFNotifyButton extends NotifyButton;

var bool bUseRegionScale;
var UWindowDialogClientWindow DialogNotifyWindow;

// had to re-implement this, since the region code assumed that the button regions would
// just be used to rescale the texture keeping the same X:Y ratio
function Paint(Canvas C, float X, float Y)
{
	local float Wx, Hy;
	local int W, H;

	C.Font = Root.Fonts[Font];

	if(bDisabled) {
		if(DisabledTexture != None)
		{
			if(bUseRegion)
			{
				if (bUseRegionScale)
					DrawStretchedTextureSegment( C, ImageX, ImageY, DisabledRegion.W*RegionScale, DisabledRegion.H*RegionScale,
											DisabledRegion.X, DisabledRegion.Y,
											DisabledRegion.W, DisabledRegion.H, DisabledTexture );
				else
					DrawStretchedTextureSegment( C, ImageX, ImageY, WinWidth, WinHeight,
											DisabledRegion.X, DisabledRegion.Y,
											DisabledRegion.W, DisabledRegion.H, DisabledTexture );

			}
			else if(bStretched)
				DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, DisabledTexture );
			else
				DrawClippedTexture( C, ImageX, ImageY, DisabledTexture);
		}
	} else {
		if(bMouseDown)
		{
			if(DownTexture != None)
			{
				if(bUseRegion)
				{
					if (bUseRegionScale)
						DrawStretchedTextureSegment( C, ImageX, ImageY, DownRegion.W*RegionScale, DownRegion.H*RegionScale,
												DownRegion.X, DownRegion.Y,
												DownRegion.W, DownRegion.H, DownTexture );
					else
						DrawStretchedTextureSegment( C, ImageX, ImageY, WinWidth, WinHeight,
												DownRegion.X, DownRegion.Y,
												DownRegion.W, DownRegion.H, DownTexture );

				}
				else if(bStretched)
					DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, DownTexture );
				else
					DrawClippedTexture( C, ImageX, ImageY, DownTexture);
			}
		} else {
			if(MouseIsOver()) {
				if(OverTexture != None)
				{
					if(bUseRegion)
					{
						if (bUseRegionScale)
							DrawStretchedTextureSegment( C, ImageX, ImageY, OverRegion.W*RegionScale, OverRegion.H*RegionScale,
													OverRegion.X, OverRegion.Y,
													OverRegion.W, OverRegion.H, OverTexture );
						else
							DrawStretchedTextureSegment( C, ImageX, ImageY, WinWidth, WinHeight,
													OverRegion.X, OverRegion.Y,
													OverRegion.W, OverRegion.H, OverTexture );

					}
					else if(bStretched)
						DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, OverTexture );
					else
						DrawClippedTexture( C, ImageX, ImageY, OverTexture);
				}
			} else {
				if(UpTexture != None)
				{
					if(bUseRegion)
					{
						if (bUseRegionScale)
							DrawStretchedTextureSegment( C, ImageX, ImageY, UpRegion.W*RegionScale, UpRegion.H*RegionScale,
													UpRegion.X, UpRegion.Y,
													UpRegion.W, UpRegion.H, UpTexture );
						else
							DrawStretchedTextureSegment( C, ImageX, ImageY, WinWidth, WinHeight,
													UpRegion.X, UpRegion.Y,
													UpRegion.W, UpRegion.H, UpTexture );

					}
					else if(bStretched)
						DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, UpTexture );
					else
						DrawClippedTexture( C, ImageX, ImageY, UpTexture);
				}
			}
		}
	}

	W = WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	if (bDontSetLabel)
	{
		if (LabelWidth == 0)
			LabelWidth = WinWidth;
		if (LabelHeight == 0)
			LabelHeight = WinHeight;
	} else {
		LabelWidth = WinWidth;
		LabelHeight = WinHeight;
	}

	C.DrawColor = TextColor;
	C.Font = MyFont;
	TextSize(C, Text, Wx, Hy);
	if (bLeftJustify)
		ClipText(C, XOffset, 0, Text);
	else
		ClipText(C, (LabelWidth - Wx)/2, (LabelHeight - Hy)/2, Text);
}

simulated function Click(float X, float Y)
{
	if (!bDisabled && (DownSound != None))
		GetPlayerOwner().PlaySound(DownSound, SLOT_Interact);
	Notify(DE_Click);
}

function Notify(byte E)
{
	if (DialogNotifyWindow != None)
		DialogNotifyWindow.Notify(Self, E);
	if (NotifyWindow != None)
		NotifyWindow.Notify(Self, E);
}
