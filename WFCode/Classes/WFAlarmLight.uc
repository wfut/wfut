class WFAlarmLight extends Effects;

var() float FlashTime;

function PostBeginPlay()
{
	SetTimer(FlashTime, true);
}

function Timer()
{
	if (Owner.bHidden)
		bHidden = true;
	else
		bHidden = !bHidden;
}


defaultproperties
{
	bHidden=True
	bNetTemporary=False
	Physics=PHYS_Trailer
	RemoteRole=ROLE_None
	FlashTime=0.500000
	DrawScale=0.200000
	DrawType=DT_Sprite
	Style=STY_Translucent
	Sprite=Texture'Botpack.Translocator.Tranglow'
	Texture=Texture'Botpack.Translocator.Tranglow'
	Skin=Texture'Botpack.Translocator.Tranglow'
}