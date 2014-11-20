//=============================================================================
// WFClassHelpHTMLPage.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//
// TODO: add links to other player classes
//=============================================================================
class WFClassHelpHTMLPage extends WFS_DynamicHTMLPage;

// Override this function and use the HTML in this function as a template
// for implmenting the player class help.
static function string GetHTML
(
	optional string Options, 		// an optional string of options/information
	optional int SwitchNum, 		// an optional switch number
	optional Object OptionalObject	// an optional object reference
)
{
	local string HTML, TeamColor;

	// This doesn't need to be done, but demonstrates the use of the option
	// parsing function and makes the page a little more dynamic.
	TeamColor = GetHTMLTeamColor(GetIntOption(Options, "Team", 0));

	HTML = (

	// The main HTML help page.

	// Note that the usual <p>...</p> format is not used for the first paragraph
	// after the heading text, and the <HTML>...</HTML> tags are skipped completely.
	// The UT HTML display has basic HTML parsing, and assumes that the text is HTML.
	// The parser uses the <p> tag as a line space between sections of text (it has the
	// same effect as <br><br>) and the </p> tag is ignored completely.

	// === Notes ===
	// Add the name of the player class here: replace (class name) with the name
	// of the player class.

		"<BODY BGCOLOR=\"#000000\" LINK=\"#FF0000\" ALINK=\"#FF00FF\">"
	$		"<font color=#"$TeamColor$">"
	$			"<center>"
	$				"<h1>[ - (class name) - ]</h1>"
	$			"</center>"
	$		"</font>"

	$		"<b>Class Type: </b><font color=#C0C0C0>(Defense|Midfield|Attack|Support)</font>"
	$		"<br><b>Armor: </b><font color=#C0C0C0>(armor value, eg: 100)</font>"
	$		"<br><b>Health: </b><font color=#C0C0C0>(health values, eg: 100 (199 max))</font>"
	$		"<br><b>Speed: </b><font color=#C0C0C0>(Slow|Medium|Fast)</font>"
	$		"<br>"
	$		"<br><b>Weapons: </b><font color=#C0C0C0>(weapon list goes here)</font>"
	$		"<br><b>Grenades: </b><font color=#C0C0C0>(list of grenades)</font>"
	$		"<br><b>Special Abilities: </b><font color=#C0C0C0>(add ability list here)</font>"

	// === Notes ===
	// List the console commands here. They should be the main commands used
	// by this player class.

	$		"<p><b>Console Commands:</b>"
	$		"<font color=#C0C0C0>"
	$			"<br>\"special\" -- default ability"
	$		"</font></p>"

	// === Notes ===
	// Use this section to recommend any essential commands for the player class,
	// ie. commands that would be used frequently by the player.

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

	// === Notes ===
	// Add a description of the player class here, as well as any gameplay tips.
	// There should be enough information here for the player to gain a basic
	// understanding of what to do when playing as this class.

	$		"<p><b>Class Notes:</b>"
	$		"<font color=#C0C0C0>"
	$			"<br>No information available for this class."
	$		"</font></p>"

	$	"</BODY>"
	);

	return HTML;
}

// gets the HTML colour for a team
static function string GetHTMLTeamColor(int TeamNum)
{
	switch (TeamNum)
	{
		case 0: return "FF0000";
		case 1: return "0080FF";
		case 2: return "00FF00";
		case 3: return "FFFF00";
	}

	return "FFFFFF";
}

defaultproperties
{
}