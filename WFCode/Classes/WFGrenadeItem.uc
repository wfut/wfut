//=============================================================================
// WFGrenadeItem.
//
// Throws out a projectile of type 'ProjectileClass'.
//=============================================================================
class WFGrenadeItem extends WFS_PCSGrenadeItem
	abstract;

var() float BaseVelocity;
var() float MaximumVelocity;
var() class<Projectile> ProjectileClass;

var() localized string DeathMessage; // death message used
var() localized string SuicideMessage; // suicide message used

function actor ThrowGrenade()
{
	local vector dir, InitialVelocity;
	local float VelocityScale;
	local inventory Item;

	// calculate the grenades starting direction and velocity
	dir = vector(pawn(Owner).ViewRotation);
	dir.z = dir.Z + 0.35 * (1 - Abs(dir.Z));

	VelocityScale = Max(1.0, ThrowingTime);
	InitialVelocity = (FMin(BaseVelocity * VelocityScale, MaximumVelocity) * Normal(dir)) + Owner.Velocity*0.5;

	// notify any WFPickups that a grenade was thrown
	for (Item=pawn(Owner).Inventory; Item!=None; Item=Item.Inventory)
	{
		if ((Item != None) && Item.IsA('WFPickup'))
			WFPickup(Item).GrenadeThrown(self);
		//if ((Item != None) && Item.IsA('WFCloaker') && Item.IsInState('Active'))
		//	WFCloaker(Item).GrenadeThrown(self);
	}

	return DropProjectile(InitialVelocity);
}

function projectile DropProjectile(vector InitialVelocity)
{
	local projectile p;
	local vector ThrowOffset;

	if (ProjectileClass == None)
		return None;

	ThrowOffset = vect(0,0,1)*Owner.CollisionHeight*0.5;
	p = spawn(ProjectileClass,,, Owner.Location + ThrowOffset, pawn(Owner).ViewRotation);
	p.Velocity = InitialVelocity;

	return p;
}

defaultproperties
{
	BaseVelocity=400.000000
	MaximumVelocity=800.000000
	ThrowSound=sound'Swing1t'
	DeathMessage="%o was killed by %k's %w."
}