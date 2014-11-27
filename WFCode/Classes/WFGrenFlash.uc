//=============================================================================
// WFGrenFlash.
// A flash grenade: Blinds players within radius.
//=============================================================================
class WFGrenFlash extends WFGrenadeItem;

defaultproperties
{
	ProjectileClass=class'WFGrenFlashProj'
	GrenadeSlot=2
	bCanHaveMultipleCopies=True
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="You picked up a Flash Grenade"
	ItemName="Flash Grenade"
	PickupViewMesh=LodMesh'UnrealShare.VoiceBoxMesh'
	PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
	Icon=Texture'UnrealI.Icons.I_SludgeAmmo'
	CollisionRadius=18.000000
	CollisionHeight=8.000000
	PrimingTime=0.500000
	bSingleGrenade=True
	StatusIcon=Texture'WFMedia.GrenadeFlash'
}
