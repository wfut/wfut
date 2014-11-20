//=============================================================================
// WFClassHelpFieldMedic.
//=============================================================================
class WFClassHelpFieldMedic extends WFClassHelpHTMLPage;

static function string GetHTML
(
	optional string Options, 		// an optional string of options/information
	optional int SwitchNum, 		// an optional switch number
	optional Object OptionalObject	// an optional object reference
)
{
	local string HTML, TeamColor;

	TeamColor = GetHTMLTeamColor(GetIntOption(Options, "Team", 0));

	HTML = (
		"<BODY BGCOLOR=\"#000000\" LINK=\"#FF0000\" ALINK=\"#FF00FF\">"
	$		"<font color=#"$TeamColor$">"
	$			"<center>"
	$				"<h1>[ - Field Medic - ]</h1>"
	$			"</center>"
	$		"</font>"

	$		"<b>Class Type: </b><font color=#C0C0C0>Support</font>"
	$		"<br><b>Armor: </b><font color=#C0C0C0>50</font>"
	$		"<br><b>Health: </b><font color=#C0C0C0>100 (199 max)</font>"
	$		"<br><b>Speed: </b><font color=#C0C0C0>Medium</font>"
	$		"<br>"
	$		"<br><b>Weapons: </b><font color=#C0C0C0>Translocator, Med Kit, Machine Gun, Bio Rifle.</font>"
	$		"<br><b>Grenades: </b><font color=#C0C0C0>Slot 1: Frag, Slot 2: Plague.</font>"
	$		"<br><b>Special Abilities: </b><font color=#C0C0C0>Healing depot.</font>"

	$		"<p><b>Console Commands:</b>"
	$		"<font color=#C0C0C0>"
	$			"<br>\"special\" -- default ability: display ability menu"
	$			"<br>\"special deploydepot\" -- deploy/move healing depot"
	$		"</font></p>"

	$		"<p><b>Recommended Key Aliases:</b>"
	$		"<font color=#C0C0C0>"
	$			"<br>Use these commands with the \"set input &lt;key&gt; &lt;command&gt;\" console command "
	$			"to bind these aliases to a key. The \"gren1\" and \"gren2\" bindings are input buttons "
	$			"and the longer you hold the key down, the further the grenade from that slot will be thrown."
	$			"<br>"
	$			"<br>\"special\" -- default ability"
	$			"<br>\"button gren1\" -- use grenade slot 1"
	$			"<br>\"button gren2\" -- use grenade slot 2"
	$		"</font></p>"

	$		"<p><b>Class Notes:</b>"
	$		"<font color=#C0C0C0>"
	$			"<br>The Field Medic is invaluable at keeping a team's health in top shape during combat. The "
	$			"Field Medic can deploy a Medic Depot which will heal teammates who stand on it. The Field Medic "
	$			"can heal teammates with the primary fire of the Med Kit and the alternate fire will expel a "
	$			"small cloud of infectious gas which causes enemies to slowly die of disease. Only another Field "
	$			"Medic or Medic Depot on their team can heal them. The Field Medic carries a plague grenade which "
	$			"produces a gas cloud that has a large chance of infecting an enemy that enters it. Any players "
	$			"who are infected and are hit with the Field Medic's Bio-Rifle will have their rate of infection "
	$			"doubled."
	$		"</font></p>"

	$	"</BODY>"
	);

	return HTML;
}

defaultproperties
{
}