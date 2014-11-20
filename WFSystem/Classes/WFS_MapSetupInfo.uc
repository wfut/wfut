//=============================================================================
// WFS_MapSetupInfo.
// Author: Ob1-Kenobi (ob1@planetunreal)
//
// Data class used to setup maps. (may implement as 'static' class later)
//=============================================================================
class WFS_MapSetupInfo extends WFS_PCSystemInfo
	abstract;

function SetupMap();

// returns the name of the current map
function string GetMapString()
{
	return Left(self, Len(self) - (Len(name)+1));
}

//=============================================================================
// Option parsing functions from GameInfo.

// Grab the next option from a string.
function bool GrabOption( out string Options, out string Result )
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
function GetKeyValue( string Pair, out string Key, out string Value )
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
function bool HasOption( string Options, string InKey )
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
function string ParseOption( string Options, string InKey )
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

function int GetIntOption( string Options, string ParseString, int CurrentValue)
{
	local string InOpt;

	InOpt = ParseOption( Options, ParseString );
	if ( InOpt != "" )
	{
		//log(ParseString@InOpt);
		return int(InOpt);
	}
	return CurrentValue;
}


defaultproperties
{
	RemoteRole=ROLE_None
}