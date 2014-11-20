class WFWallGrenade extends WFGrenadeItem;

defaultproperties
{
	GrenadeSlot=1
	NumCopies=1
	bCanHaveMultipleCopies=True
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="You picked up a Sticky Grenade"
	ItemName="Sticky Grenade"
	PickupViewMesh=LodMesh'UnrealShare.VoiceBoxMesh'
	PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
	Icon=Texture'UnrealI.Icons.I_SludgeAmmo'
	CollisionRadius=18.000000
	CollisionHeight=8.000000
	PrimingTime=0.500000
	bSingleGrenade=False
	ProjectileClass=class'WFWallGrenadeProj'
}