class WFGrenEMP extends WFGrenadeItem;

defaultproperties
{
	ProjectileClass=class'WFGrenEMPProj'
	PickupMessage="You picked up an EMP Grenade"
	ItemName="EMP Grenade"
	GrenadeSlot=2
	PickupViewMesh=LodMesh'UnrealShare.VoiceBoxMesh'
	PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
	Icon=Texture'UnrealI.Icons.I_SludgeAmmo'
	CollisionRadius=18.000000
	CollisionHeight=8.000000
	PrimingTime=0.500000
	NumCopies=1
	bSingleGrenade=True
	StatusIcon=Texture'WFMedia.GrenadeEMP'
}
