//=============================================================================
// MV_Cache made by OwYeaW
//=============================================================================
class MV_Cache expands Object config(UTBT_MapVote) perobjectconfig;

var config string Date;
var config string MD5;
var config string Announcement;
var config string Maps[4096];
var config string Categories[128];

function bool DoesMapExist(string MapName)
{
	local int i, posM;
	local string str;

	for(i = 0; i < ArrayCount(Maps); i++)
	{
		str = Maps[i];

		posM = InStr(str, "*");
		if(posM > 0)
		{
			str = Left(str, posM);
			if(str == MapName)
				return true;
		}
		else
		{
			posM = InStr(str, "|");
			if(posM > 0)
			{
				str = Left(str, posM);
				if(str == MapName)
					return true;
			}
		}
	}
	return false;
}

function string GetRandomMap()
{
	local int i, posM, mapCount, rng;
	local string MapName;

	for(i = 0; i < ArrayCount(Maps); i++)
		if(Maps[i] != "")
			mapCount++;

	rng = Rand(mapCount);
	MapName = Maps[rng];

	posM = InStr(MapName, "*");
	if(posM > 0)
	{
		MapName = Left(MapName, posM);
		return MapName;
	}
	else
	{
		posM = InStr(MapName, "|");
		if(posM > 0)
		{
			MapName = Left(MapName, posM);
			return MapName;
		}
	}
}

defaultproperties
{
	Date=""
	MD5=""
	Announcement=""
	Maps(0)=""
	Categories(0)=""
}