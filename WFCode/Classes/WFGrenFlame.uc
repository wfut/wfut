class WFGrenFlame extends WFGrenadeItem;

defaultproperties
{
	ProjectileClass=class'WFGrenFlameProj'
	GrenadeSlot=2
	bCanHaveMultipleCopies=True
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="You picked up a Flame Grenade"
	ItemName="Flame Grenade"
	PickupViewMesh=LodMesh'UnrealShare.VoiceBoxMesh'
	PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
	Icon=Texture'UnrealI.Icons.I_SludgeAmmo'
	CollisionRadius=18.000000
	CollisionHeight=8.000000
	PrimingTime=0.500000
	StatusIcon=Texture'WFMedia.GrenadeFlame'
	NumCopies=1
}
