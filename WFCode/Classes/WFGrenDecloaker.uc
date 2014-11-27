//=============================================================================
// WFGrenDecloaker.
//=============================================================================
class WFGrenDecloaker extends WFGrenadeItem;

function actor ThrowGrenade()
{
	local vector dir, InitialVelocity;
	local float VelocityScale;
	local projectile DroppedGrenade;

	// calculate the grenades starting direction and velocity
	dir = vector(pawn(Owner).ViewRotation);
	dir.z = dir.Z + 0.35 * (1 - Abs(dir.Z));

	VelocityScale = Max(1.0, ThrowingTime);
	InitialVelocity = (FMin(BaseVelocity * VelocityScale, MaximumVelocity) * Normal(dir)) + Owner.Velocity*0.5;

	DroppedGrenade = DropProjectile(InitialVelocity);
	//class'WFS_PlayerClassInfo'.static.AddRelatedActor(PCSOwner, DroppedGrenade);

	return DroppedGrenade;
}

/*function bool CanThrowGrenade()
{
	if (class'WFS_PlayerClassInfo'.static.RelatedActorCount(PCSOwner, class'WFGrenDecloakerProj') < 2)
		return true;

	return false;
}*/

defaultproperties
{
	GrenadeSlot=2
	PickupViewMesh=LodMesh'UnrealShare.VoiceBoxMesh'
	PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
	ProjectileClass=class'WFGrenDecloakerProj'
	PrimingTime=0.500000
	bSingleGrenade=True
	CollisionRadius=18.000000
	CollisionHeight=8.000000
	ItemName="Decloaker"
	StatusIcon=Texture'WFMedia.GrenadeDecloaker'
}
