class WFFlagTextureMenuSC extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'WFFlagTextureMenuCW';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
