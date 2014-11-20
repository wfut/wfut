//=============================================================================
// WFS_DynamicHTMLPage.
// Author: Ob1-Kenobi (ob1@planetunreal.com)
//
// A dynamic HTML page (ala ASP, etc).
//=============================================================================
class WFS_DynamicHTMLPage extends Object;

//------------------------------------------------------------------------------
// use this function to generate the HTML page
static function string GetHTML
(
	optional string Options, 		// an optional string of options/information
	optional int SwitchNum, 		// an optional switch number
	optional Object OptionalObject	// an optional object reference
)
{
	return "";
}

static function ReplaceText(out string Text, string Replace, string With)
{
	local int i;
	local string Input;

	Input = Text;
	Text = "";
	i = InStr(Input, Replace);
	while(i != -1)
	{
		Text = Text $ Left(Input, i) $ With;
		Input = Mid(Input, i + Len(Replace));
		i = InStr(Input, Replace);
	}
	Text = Text $ Input;
}

//------------------------------------------------------------------------------
// Option parsing functions from Engine.GameInfo

// Grab the next option from a string.
static function bool GrabOption( out string Options, out string Result )
{
	if( Left(Options,1)=="?" )
	{
		// Get result.
		Result = Mid(Options,1);
		if( InStr(Result,"?")>=0 )
			Result = Left( Result, InStr(Result,"?") );

		// Update options.
		Options = Mid(Options,1);
		if( InStr(Options,"?")>=0 )
			Options = Mid( Options, InStr(Options,"?") );
		else
			Options = "";

		return true;
	}
	else return false;
}

// Break up a key=value pair into its key and value.
static function GetKeyValue( string Pair, out string Key, out string Value )
{
	if( InStr(Pair,"=")>=0 )
	{
		Key   = Left(Pair,InStr(Pair,"="));
		Value = Mid(Pair,InStr(Pair,"=")+1);
	}
	else
	{
		Key   = Pair;
		Value = "";
	}
}

// See if an option was specified in the options string.
static function bool HasOption( string Options, string InKey )
{
	local string Pair, Key, Value;
	while( GrabOption( Options, Pair ) )
	{
		GetKeyValue( Pair, Key, Value );
		if( Key ~= InKey )
			return true;
	}
	return false;
}

// Find an option in the options string and return it.
static function string ParseOption( string Options, string InKey )
{
	local string Pair, Key, Value;
	while( GrabOption( Options, Pair ) )
	{
		GetKeyValue( Pair, Key, Value );
		if( Key ~= InKey )
			return Value;
	}
	return "";
}

static function int GetIntOption( string Options, string ParseString, int DefaultValue)
{
	local string InOpt;

	InOpt = ParseOption( Options, ParseString );
	if ( InOpt != "" )
	{
		log(ParseString@InOpt);
		return int(InOpt);
	}
	return DefaultValue;
}

static function float GetFloatOption( string Options, string ParseString, float DefaultValue)
{
	local string InOpt;

	InOpt = ParseOption( Options, ParseString );
	if ( InOpt != "" )
	{
		log(ParseString@InOpt);
		return float(InOpt);
	}
	return DefaultValue;
}

defaultproperties
{
}