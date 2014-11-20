//=============================================================================
// WFClassHelpInfiltrator.
//=============================================================================
class WFClassHelpInfiltrator extends WFClassHelpHTMLPage;

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
	$				"<h1>[ - Infiltrator - ]</h1>"
	$			"</center>"
	$		"</font>"

	$		"<b>Class Type: </b><font color=#C0C0C0>Stealth &amp; Intel</font>"
	$		"<br><b>Armor: </b><font color=#C0C0C0>50</font>"
	$		"<br><b>Health: </b><font color=#C0C0C0>100 (199 max)</font>"
	$		"<br><b>Speed: </b><font color=#C0C0C0>Medium</font>"
	$		"<br>"
	$		"<br><b>Weapons: </b><font color=#C0C0C0>Translocator, Enforcer.</font>"
	$		"<br><b>Grenades: </b><font color=#C0C0C0>Slot 1: Frag, Slot 2: Flash.</font>"
	$		"<br><b>Special Abilities: </b><font color=#C0C0C0>Cloak, Disguise.</font>"

	$		"<p><b>Console Commands:</b>"
	$		"<font color=#C0C0C0>"
	$			"<br>\"special\" -- default ability: display disguise menu"
	$			"<br>\"special cloak\" -- activate/deactivate cloak"
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
	$			"<br>The purpose of the Infiltrator is, as the name suggests, to infiltrate "
	$			"an enemy base without detection. An Infiltrator can gain information on enemy "
	$			"defenses, and (if not discovered) can move freely around the enemy base."
	$			"<br>"
	$			"<br>There are two methods by which an Infiltrator can enter an enemy base undetected: "
	$			"using the personal cloaking device, or by disguising as an enemy player."
	$			"<br>"
	$			"<br>The cloaking device renders an Infiltrator virtually invisible except for a faint "
	$			"visual fuzz. While the cloaker is active, it will use energy at the rate of 1 "
	$			"point per second. The amount of enery available is displayed in the top-right of the HUD "
	$			"(just below health) and will recharge at the rate of 1 point per second while the cloaker "
	$			"is not active."
	$			"<br>"
	$			"<br>By using a disguise, the Infiltrator can take on the appearance of a member of another "
	$			"team. Use the disguise menu to change disguise, the current disguised team and class are "
	$			"dislpayed at the bottom of the menu. If you fire use a weapon (except the Translocator) or "
	$			"throw a grenade while disguised, the disguise will be removed."
	$		"</font></p>"

	$	"</BODY>"
	);

	return HTML;
}

defaultproperties
{
}