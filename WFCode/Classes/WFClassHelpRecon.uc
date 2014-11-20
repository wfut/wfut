//=============================================================================
// WFClassHelpRecon.
//=============================================================================
class WFClassHelpRecon extends WFClassHelpHTMLPage;

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
	$				"<h1>[ - Recon - ]</h1>"
	$			"</center>"
	$		"</font>"

	$		"<b>Class Type: </b><font color=#C0C0C0>Offense</font>"
	$		"<br><b>Armor: </b><font color=#C0C0C0>50</font>"
	$		"<br><b>Health: </b><font color=#C0C0C0>75 (150 max)</font>"
	$		"<br><b>Speed: </b><font color=#C0C0C0>Fast</font>"
	$		"<br>"
	$		"<br><b>Weapons: </b><font color=#C0C0C0>Translocator, RDU, Mini Flak, Dual Pistols.</font>"
	$		"<br><b>Grenades: </b><font color=#C0C0C0>Slot 1: Standard, Slot 2: Flash.</font>"
	$		"<br><b>Special Abilities: </b><font color=#C0C0C0>Thrust pack.</font>"

	$		"<p><b>Console Commands:</b>"
	$		"<font color=#C0C0C0>"
	$			"<br>\"special\" -- default ability: use thrust pack"
	$			"<br>\"special thrust\" -- use thrust pack"
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
	$			"<br>The Recon can use the Thrust Pack ability to quickly infiltrate enemy bases and make a "
	$			"grab for the flag. A Recon cannot use the Thrust Pack while carrying the flag however, and "
	$			"has low health and armor. The Recon's Thrust Pack uses 20 energy units per use which slowly "
	$			"recharges. With the primary fire the Recon Defense Unit (RDU) can be used to push enemies out "
	$			"of the way within a certain distance depending on charge and the secondary fire puts up a "
	$			"shield to protect the Recon from the front for a limited time. The amount of time the shield "
	$			"stays up is dependant on the RDU ammo charge."
	$		"</font></p>"

	$	"</BODY>"
	);

	return HTML;
}

defaultproperties
{
}