//=============================================================================
// WFS_TestScoutInv.
//=============================================================================
class WFS_TestScoutInv extends WFS_InventoryInfo;

static function AddInventory(actor GameActor, pawn PawnOther)
{
	local Enforcer Enforcer1, Enforcer2;
	local Inventory Item;

	super.AddInventory(GameActor, PawnOther);

	// setup double enforcer
	//Item = PawnOther.FindInventoryType(class'DoubleEnforcer');
	Item = PawnOther.FindInventoryType(class'Enforcer');
	if (Enforcer(Item) != none)
	{
		//Enforcer1 = DoubleEnforcer(Item);
		Enforcer1 = Enforcer(Item);
		Enforcer2 = GameActor.Spawn(class'DoubleEnforcer', PawnOther);
		Enforcer2.BecomeItem();
		Enforcer1.ItemName = Enforcer1.DoubleName;
		Enforcer1.SlaveEnforcer = Enforcer2;
		Enforcer1.SetTwoHands();
		Enforcer1.AIRating = 0.4;
		Enforcer1.SlaveEnforcer.SetUpSlave( PawnOther.Weapon == Enforcer1 );
		Enforcer1.SlaveEnforcer.SetDisplayProperties(Enforcer1.Style, Enforcer1.Texture, Enforcer1.bUnlit, Enforcer1.bMeshEnviromap);
		Enforcer1.SetTwoHands();
		Enforcer1.WeaponSet(PawnOther);
		// increase ammo
		Enforcer1.AmmoType.AddAmmo(100);
	}
}

defaultproperties
{
	Pickups(0)=class'ThighPads'
	Pickups(1)=class'EClip'
	Pickups(2)=class'miniammo'
}