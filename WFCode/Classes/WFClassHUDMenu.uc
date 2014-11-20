class WFClassHUDMenu extends WFS_HUDTextMenu;

function MenuDisplaySetup(canvas Canvas)
{
	Canvas.DrawColor = class'ChallengeHUD'.default.WhiteColor;
	Canvas.Font = OwnerHUD.MyFonts.GetSmallFont(Canvas.ClipX);
}
