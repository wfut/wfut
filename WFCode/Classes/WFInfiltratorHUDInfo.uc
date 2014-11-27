class WFInfiltratorHUDInfo extends WFCustomHUDInfo;

var() texture CustomIconTexture;

// could make this a general use function and move to WFHUDInfo and WFITSHUDInfo
simulated function DrawStatus(out byte bOverrideFunction, Canvas Canvas)
{
  local byte         Style;
	local color        DigitBackground;
  local texture      DigitTexure;
  local int          ResourceAmount;
  local WFCustomHUD MyOwnerHUD;
  local float H1, H2;

  MyOwnerHUD = WFCustomHUD( OwnerHUD );

  // Preserve the current style
  Style = Canvas.Style;

  Canvas.SetPos( Canvas.ClipX - ( 128 * MyOwnerHUD.MyStatusScale ),
	               68 * MyOwnerHUD.MyStatusScale );

  MyOwnerHUD.DrawPanel( Canvas,
                        MyOwnerHUD.EPanel.PLeft,
                        ERenderStyle.STY_Modulated,
                        32, 32, MyOwnerHUD.HUDColor,
												MyOwnerHUD.MyOpacity,
                        MyOwnerHUD.MyStatusScale );
  MyOwnerHUD.DrawPanel( Canvas,
                        MyOwnerHUD.EPanel.PMiddle,
	                      ERenderStyle.STY_Modulated,
	                      96, 32, MyOwnerHUD.HUDColor,
												MyOwnerHUD.MyOpacity,
	                      MyOwnerHUD.MyStatusScale );

   ResourceAmount = GetIconValue();
   if( ResourceAmount < 0 )
     ResourceAmount = 0;

	if (ResourceAmount == 0)
	{
		// make the colour flash
		H1 = 1.5 * MyOwnerHUD.TutIconBlink;
		H2 = 1 - H1;
		Canvas.DrawColor = MyOwnerHUD.BaseColor * H2 + (MyOwnerHUD.HUDColor - MyOwnerHUD.BaseColor) * H1;
	}
	else Canvas.DrawColor = MyOwnerHUD.HUDColor;
	 Canvas.Style = MyOwnerHUD.MySolidStyle;

   Canvas.SetPos( Canvas.ClipX - ( 110 * MyOwnerHUD.MyStatusScale ),
	                68 * MyOwnerHUD.MyStatusScale );
   Canvas.DrawTile( Texture'ResourceIcon', 32 * MyOwnerHUD.MyStatusScale,
	                  32 * MyOwnerHUD.MyStatusScale, 0, 0, 32.0, 32.0);


   Canvas.SetPos( Canvas.ClipX - ( 72 * MyOwnerHUD.MyStatusScale ),
	                68 * MyOwnerHUD.MyStatusScale );
   MyOwnerHUD.DrawDigits( Canvas,
                          ResourceAmount,
						              3,
						              MyOwnerHUD.HUDColor,
						              MyOwnerHUD.HUDBackgroundColor,
						              MyOwnerHUD.MySolidStyle,
						              ERenderStyle.STY_Translucent,
									  MyOwnerHUD.MyStatusScale,
									  (resourceAmount <= 0));

}

function int GetIconValue()
{
	local inventory Inv;

	Inv = OwnerHUD.PawnOwner.FindInventoryType(class'WFCloaker');
	if (Inv != None)
		return Inv.Charge;

	return -1;
}

defaultproperties
{
	CustomIconTexture=Texture'EnergyHUDIcon'
}