class WFMapDataList extends UWindowListBoxItem;

var string DisplayName;
var string DataClass;

// Call only on sentinel
function WFMapDataList FindMapData(string FindDataClass)
{
	local WFMapDataList I;

	for(I = WFMapDataList(Next); I != None; I = WFMapDataList(I.Next))
		if(I.DataClass ~= FindDataClass)
			return I;

	return None;
}

defaultproperties
{
}