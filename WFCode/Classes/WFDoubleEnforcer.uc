//=============================================================================
// WFDoubleEnforcer.
//=============================================================================
class WFDoubleEnforcer extends WFEnforcer;

function GiveTo(pawn Other)
{
	local WFEnforcer Enforcer2;
	super.GiveTo(Other);
	if (Owner == Other)
	{
		Enforcer2 = Spawn(class'WFEnforcer', Other,, Other.Location);
		Enforcer2.BecomeItem();
		SlaveEnforcer = Enforcer2;
		SetTwoHands();
		AIRating = 0.4;
		//SlaveEnforcer.SetUpSlave( Other.Weapon == self );
		SlaveEnforcer.SetUpSlave(false);
		SlaveEnforcer.SetDisplayProperties(Style, Texture, bUnlit, bMeshEnviromap);
		SetTwoHands();
	}
}

defaultproperties
{
	ItemName="Double Enforcer"
	InventoryGroup=3
	AutoSwitchPriority=3
}