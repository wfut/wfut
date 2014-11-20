//=============================================================================
// WFGrenConc.
// A concussion grenade: Low damage. High momentun transfer.
//=============================================================================
class WFGrenConc extends WFGrenadeItem;

defaultproperties
{
	ProjectileClass=class'WFGrenConcProj'
	GrenadeSlot=2
	bCanHaveMultipleCopies=True
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="You picked up a Concussion Grenade"
	ItemName="Concussion Grenade"
	PickupViewMesh=LodMesh'UnrealShare.VoiceBoxMesh'
	PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
	Icon=Texture'UnrealI.Icons.I_SludgeAmmo'
	CollisionRadius=18.000000
	CollisionHeight=8.000000
	PrimingTime=0.500000
	bSingleGrenade=True
}