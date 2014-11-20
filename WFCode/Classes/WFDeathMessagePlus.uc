class WFDeathMessagePlus extends DeathMessagePlus;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch (Switch)
	{
		case 10: // hand grenade death
			if (RelatedPRI_1 == None)
				return "";
			if (RelatedPRI_1.PlayerName == "")
				return "";
			/*if (RelatedPRI_2 == None)
				return "";
			if (RelatedPRI_2.PlayerName == "")
				return "";*/
			if (Class<WFGrenadeItem>(OptionalObject) == None)
			{
				return "";
			}
			if (RelatedPRI_2 != None)
			{
				return class'GameInfo'.Static.ParseKillMessage(
					RelatedPRI_1.PlayerName,
					RelatedPRI_2.PlayerName,
					Class<WFGrenadeItem>(OptionalObject).Default.ItemName,
					Class<WFGrenadeItem>(OptionalObject).Default.DeathMessage
				);
			}
			else // suicide message
			{
				return class'GameInfo'.Static.ParseKillMessage(
					RelatedPRI_1.PlayerName,
					RelatedPRI_2.PlayerName,
					Class<WFGrenadeItem>(OptionalObject).Default.ItemName,
					Class<WFGrenadeItem>(OptionalObject).Default.SuicideMessage
				);
			}
			break;

		case 11: // status death
			if (RelatedPRI_1 == None)
				return "";
			if (RelatedPRI_1.PlayerName == "")
				return "";
			/*if (RelatedPRI_2 == None)
				return "";
			if (RelatedPRI_2.PlayerName == "")
				return "";*/
			if (Class<WFPlayerStatus>(OptionalObject) == None)
			{
				return "";
			}
			if (RelatedPRI_2 != None)
			{
				return class'GameInfo'.Static.ParseKillMessage(
					RelatedPRI_1.PlayerName,
					RelatedPRI_2.PlayerName,
					Class<WFPlayerStatus>(OptionalObject).Default.ItemName,
					Class<WFPlayerStatus>(OptionalObject).Default.DeathMessage
				);
			}
			else // suicide message
			{
				return class'GameInfo'.Static.ParseKillMessage(
					RelatedPRI_1.PlayerName,
					RelatedPRI_2.PlayerName,
					Class<WFPlayerStatus>(OptionalObject).Default.ItemName,
					Class<WFPlayerStatus>(OptionalObject).Default.SuicideMessage
				);
			}
			break;
	}

	return super.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}