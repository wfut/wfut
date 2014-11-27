//=============================================================================
// WFEngineer.
//=============================================================================
class WFEngineerHUDInfo extends WFCustomHUDInfo;

var() texture CustomIconTexture;

// could make this a general use function and move to WFHUDInfo and WFITSHUDInfo
simulated function DrawStatus(out byte bOverrideFunction, Canvas Canvas)
{
	local byte         Style;
	local color        DigitBackground;
	local texture      DigitTexure;
	local int          ResourceAmount;
	local WFCustomHUD MyOwnerHUD;

	MyOwnerHUD = WFCustomHUD( OwnerHUD );

  // Preserve the current style
  Style = Canvas.Style;

  Canvas.SetPos( Canvas.ClipX - ( 128 * MyOwnerHUD.MyStatusScale ),
	               68 * MyOwnerHUD.MyStatusScale );
  MyOwnerHUD.DrawPanel( Canvas,
                        MyOwnerHUD.EPanel.PLeft,
                        ERenderStyle.STY_Modulated,
		 	  							  32, 32, MyOwnerHUD.HUDColor,
                        MyOwnerHUD.Opacity,
                        MyOwnerHUD.MyStatusScale );
  MyOwnerHUD.DrawPanel( Canvas,
                        MyOwnerHUD.EPanel.PMiddle,
                        ERenderStyle.STY_Modulated,
		 								    96, 32, MyOwnerHUD.HUDColor,
                        MyOwnerHUD.Opacity,
                        MyOwnerHUD.MyStatusScale );

  Canvas.DrawColor = MyOwnerHUD.HUDColor;
	 Canvas.Style = MyOwnerHUD.MySolidStyle;

  Canvas.SetPos( Canvas.ClipX - ( 110 * MyOwnerHUD.MyStatusScale ),
	               68 * MyOwnerHUD.MyStatusScale );
  Canvas.DrawTile( Texture'ResourceIcon', 32 * MyOwnerHUD.MyStatusScale,
	                                        32 * MyOwnerHUD.MyStatusScale,
	                                        0, 0, 32.0, 32.0);

	ResourceAmount = GetIconValue();
  if( ResourceAmount < 0 )
	{
	  ResourceAmount = 0;
	}

  Canvas.SetPos( Canvas.ClipX - ( 72 * MyOwnerHUD.MyStatusScale ),
	               68 * MyOwnerHUD.MyStatusScale );
  MyOwnerHUD.DrawDigits( Canvas,
	              ResourceAmount,
                3,
	              MyOwnerHUD.HUDColor,
								MyOwnerHUD.HUDBackgroundColor,
                MyOwnerHUD.MySolidStyle,
                ERenderStyle.STY_Translucent,
								MyOwnerHUD.MyStatusScale);

}

function int GetIconValue()
{
	local inventory Inv;

	Inv = OwnerHUD.PawnOwner.FindInventoryType(class'WFEngineerResource');
	if (Inv != None)
		return ammo(Inv).AmmoAmount;

	return -1;
}

defaultproperties
{
	CustomIconTexture=Texture'EngResourceIcon'
}