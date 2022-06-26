//=============================================================================
// MV_Requester made by OwYeaW
//=============================================================================
class MV_Requester extends UBrowserHTTPClient;

var MV_Mutator	Mut;
var MV_Settings	Settings;
var MV_Cache	Cache;

var string	HostAddress;
var int		CheckUpdateInterval;
var string	Update_URI;
var string	Announcement_URI;
var string	MapList_URI;
var string	Categories_URI;

var string Date;
var string cats[128];
var string maps[4096];
var string announcement;

var int catPos;
var int catCount;
var int mapCount;

auto state Initializing
{
	function BeginState()
	{
		Mut					= MV_Mutator(Owner);
		Settings			= Mut.Settings;
		Cache				= Mut.Cache;
		HostAddress 		= Settings.HostAddress;
		CheckUpdateInterval	= Clamp(Settings.MapListCheckUpdateIntervalSeconds, 10, 3600);

		Update_URI 			= Settings.Update_URI;
		Announcement_URI	= Settings.Announcement_URI;
		MapList_URI			= Settings.MapList_URI;
		Categories_URI		= Settings.Categories_URI;

		Request(Update_URI);
	}

	function HTTPReceivedData(string Data)
	{
		if(Left(Data, len("[update]")) == "[update]")
		{
			// Log("[UTBT]-[MapVote]-[Received]> update.ini - " $ "[" $ len(Data) $ "]");
			checkIfUpdateNeeded(Mid(Data, InStr(Data, LF) + 1));
		}
		else
		{
			Log("[UTBT]-[MapVote] [ERROR: Received Incorrect Data] [Expected Header: \"[update]\"] ["$HostAddress$Update_URI$"]");
			GoToState('Finished', 'Failed');
		}
	}

	function checkIfUpdateNeeded(string Data)
	{
		local string updateDate;

		updateDate = Left(Data, InStr(Data, LF));
		if(Cache.Date == updateDate)
		{
			GoToState('Finished', 'NoChanges');
		}
		else
		{
			Log("[UTBT]-[MapVote]-[New update found] [Starting Update of MapList]");
			Date = updateDate;
			GotoState('GetMapList');
		}
	}

	function HTTPError(int Code)
	{
		Log("[UTBT]-[MapVote] [ERROR: Response code "$Code$"] [During: Initializing] ["$HostAddress$Update_URI$"]");
		GoToState('Finished', 'Failed');
	}
}

state GetMapList
{
	function BeginState()
	{
		Request(MapList_URI);
	}

	function HTTPReceivedData(string Data)
	{
		if(Left(Data, len("[maplist]")) == "[maplist]")
		{
			// Log("[UTBT]-[MapVote]-[Received]> maplist.ini - " $ "[" $ len(Data) $ "]");
			loadMapList(Mid(Data, InStr(Data, LF) + 1));
			GotoState('GetCategories');
		}
		else
		{
			Log("[UTBT]-[MapVote] [ERROR: Received Incorrect Data] [Expected Header: \"[maplist]\"] ["$HostAddress$MapList_URI$"]");
			GoToState('Finished', 'Failed');
		}
	}

	function LoadMapList(string Data)
	{
		local int i, p;

		p = InStr(Data, LF);
		while(p >= 0 && i < arraycount(maps))
		{
			maps[i++] = Left(Data, p) $ "|";
			Data = Mid(Data, p + 1);
			p = InStr(Data, LF);
		}

		mapCount = i;
	}

	function HTTPError(int Code)
	{
		Log("[UTBT]-[MapVote] [ERROR: Response code "$Code$"] [During: GetMapList] ["$HostAddress$MapList_URI$"]");
		GoToState('Finished', 'Failed');
	}
}

state GetCategories
{
	function BeginState()
	{
		Request(Categories_URI);
	}

	function HTTPReceivedData(string Data)
	{
		if(Left(Data, len("[categories]")) == "[categories]")
		{
			// Log("[UTBT]-[MapVote]-[Received]> Categories.ini - " $ "[" $ len(Data) $ "]");
			loadCategories(Mid(Data, InStr(Data, LF) + 1));
			GotoState('GetCategoriesContents');
		}
		else
		{
			Log("[UTBT]-[MapVote] [ERROR: Received Incorrect Data] [Expected Header: \"[categories]\"] ["$HostAddress$Categories_URI$"]");
			GoToState('Finished', 'Failed');
		}
	}

	function loadCategories(string Data)
	{
		local int i, p;

		p = InStr(Data, LF);
		while(p >= 0 && i < arraycount(cats))
		{
			cats[i++] = Left(Data, p);
			Data = Mid(Data, p + 1);
			p = InStr(Data, LF);
		}

		catCount = i;
	}

	function HTTPError(int Code)
	{
		Log("[UTBT]-[MapVote] [ERROR: Response code "$Code$"] [During: GetCategories] ["$HostAddress$Categories_URI$"]");
		GoToState('Finished', 'Failed');
	}
}

state GetCategoriesContents
{
	function BeginState()
	{
		catPos = 0;
		RequestCategoryContent();
	}

	function RequestCategoryContent()
	{
		Request("/" $ URL_Encode(cats[catPos]) $ ".ini");
	}

	function HTTPReceivedData(string Data)
	{
		local string catName;

		catName = "["$cats[catPos]$"]";
		if(Left(Data, len(catName)) == catName)
		{
			// Log("[UTBT]-[MapVote]-[Received]> "$cats[catPos]$".ini - " $ "[" $ len(Data) $ "]");
			loadCategoryContents(Mid(Data, InStr(Data, LF) + 1));

			if(++catPos < catCount)
				RequestCategoryContent();
			else if(catPos == catCount)
				GotoState('GetAnnouncement');
		}
		else
		{
			Log("[UTBT]-[MapVote] [ERROR: Received Incorrect Data] [Expected Header: \""$catName$"\"] ["$HostAddress$Categories_URI$"]");
			GoToState('Finished', 'Failed');
		}
	}

	function loadCategoryContents(string Data)
	{
		local int i, p;

		p = InStr(Data, LF);
		while(p >= 0 && i < arraycount(maps))
		{
			setCatforMap(Left(Data, p));
			
			Data = Mid(Data, p + 1);
			p = InStr(Data, LF);
		}
	}

	function setCatforMap(string map)
	{
		local int i;

		for(i = 0; i < arraycount(maps); i++)
		{
			if(Left(maps[i], InStr(maps[i], "|")) == map)
			{
				maps[i] = maps[i] $ catPos $ "?";
				break;
			}
			else if(maps[i] == "")
				break;
		}
	}

	function HTTPError(int Code)
	{
		Log("[UTBT]-[MapVote] [ERROR: Response code "$Code$"] [During: GetCategoriesContents] ["$HostAddress$"/"$cats[catPos]$".ini]");
		GoToState('Finished', 'Failed');
	}
}

state GetAnnouncement
{
	function BeginState()
	{
		Request(Announcement_URI);
	}

	function HTTPReceivedData(string Data)
	{
		if(Left(Data, len("[announcement]")) == "[announcement]")
		{
			// Log("[UTBT]-[MapVote]-[Received]> announcement.ini - " $ "[" $ len(Data) $ "]");
			LoadAnnouncement(Mid(Data, InStr(Data, LF) + 1));
			GotoState('CompleteData');
		}
		else
		{
			Log("[UTBT]-[MapVote] [ERROR: Received Incorrect Data] [Expected Header: \"[announcement]\"] ["$HostAddress$Announcement_URI$"]");
			GoToState('Finished', 'Failed');
		}
	}

	function LoadAnnouncement(string Data)
	{
		announcement = Data;
	}

	function HTTPError(int Code)
	{
		Log("[UTBT]-[MapVote] [ERROR: Response code "$Code$"] [During: GetAnnouncement] ["$HostAddress$Announcement_URI$"]");
		GoToState('Finished', 'Failed');
	}
}

state CompleteData
{
	function BeginState()
	{
		local int i;
		local string cache_hash, new_hash, str1, str2;

		//	Creating MD5 from Cache
		for(i = 0; i < arraycount(Cache.Maps); i++)
		{
			if(Cache.maps[i] == "")
				break;

			str1 = str1 $ Cache.maps[i];
		}

		for(i = 0; i < arraycount(Cache.Categories); i++)
		{
			if(Cache.Categories[i] == "")
				break;
			
			str1 = str1 $ Cache.Categories[i];
		}

		cache_hash = Class'uHash'.static.MD5(str1);
		//	-----------------------------------------

		//	Creating MD5 from newly downloaded Data
		for(i = 0; i < arraycount(maps); i++)
		{
			if(maps[i] == "")
				break;

			str2 = str2 $ maps[i];
		}

		for(i = 0; i < arraycount(cats); i++)
		{
			if(cats[i] == "")
				break;
			
			str2 = str2 $ cats[i];
		}

		new_hash = Class'uHash'.static.MD5(str2);
		//	-----------------------------------------

		//	comparing 2 MD5 hashes + comparing dates - making sure every bit of data is updated
		if(new_hash != cache_hash || new_hash != Cache.MD5 || Cache.Date != Date)
			writeCache(new_hash);

		Log("[UTBT]-[MapVote]-[Finished Downloading] [" $ mapCount $ " Maps] [" $ catCount $ " Categories]");
		GoToState('Finished', 'Updated');
	}

	function writeCache(string new_hash)
	{
		local int i;

		for(i = 0; i < arraycount(maps); i++)
		{
			if(maps[i] == "")
				break;
			else
				Cache.Maps[i] = maps[i];
		}

		for(i = 0; i < arraycount(cats); i++)
		{
			if(cats[i] == "")
				break;
			else
				Cache.Categories[i] = cats[i];
		}

		Cache.MD5			= new_hash;
		Cache.Date			= Date;
		Cache.Announcement	= announcement;
		Cache.SaveConfig();
	}
}

state Finished
{
	function BeginState()
	{
		Disable('Tick');
		SetTimer(CheckUpdateInterval, true);
	}

	function Timer()
	{
		Request("/update.ini");
	}

	function HTTPReceivedData(string Data)
	{
		if(Left(Data, len("[update]")) == "[update]")
		{
			// Log("[UTBT]-[MapVote]-[Received]> update.ini - " $ "[" $ len(Data) $ "]");
			checkIfUpdateNeeded(Mid(Data, InStr(Data, LF) + 1));
		}
		else
		{
			Log("[UTBT]-[MapVote] [ERROR: Received Incorrect Data] [Expected Header: \"[update]\"] ["$HostAddress$Update_URI$"]");
			GoToState('Finished', 'Failed');
		}
	}

	function checkIfUpdateNeeded(string Data)
	{
		local string updateDate;

		updateDate = Left(Data, InStr(Data, LF));
		if(Cache.Date != updateDate)
		{
			Log("[UTBT]-[MapVote]-[New update found] [Starting Update of MapList]");
			Date = updateDate;
			GotoState('GetMapList');
		}
	}

	function HTTPError(int Code)
	{
		Log("[UTBT]-[MapVote] [ERROR: Response code "$Code$"] [During: CheckingUpdates] ["$HostAddress$Update_URI$"]");
		Log("[UTBT]-[MapVote]-[Update Failed] [Trying again in "$CheckUpdateInterval$" seconds]");
	}

	NoChanges:
		Log("[UTBT]-[MapVote]-[No New Updates found] [Initialized MapVote]");
		Mut.GoToState('Ready', 'Initialized');
		stop;

	Updated:
		Log("[UTBT]-[MapVote]-[Update Success] [Initialized MapVote with new Updates]");
		Mut.GoToState('Ready', 'UpdateClients');
		stop;

	Failed:
		Log("[UTBT]-[MapVote]-[Update Failed] [Initialized MapVote without Updates]");
		Mut.GoToState('Ready', 'Initialized');
		stop;
}

function string URL_Encode(string str)
{
	local int i;
	local string s, r;

	for(i = 0; i < len(str); i++)
	{
		//	https://www.url-encode-decode.com
		s = Mid(str, i, 1);
		if(s == " ")		r = r $ "%20";
		else if(s == "!")	r = r $ "%2A";
		else if(s == "*")	r = r $ "%27";
		else if(s == "'")	r = r $ "%28";
		else if(s == "(")	r = r $ "%29";
		else if(s == ")")	r = r $ "%3B";
		else if(s == ";")	r = r $ "%3A";
		else if(s == ":")	r = r $ "%40";
		else if(s == "@")	r = r $ "%26";
		else if(s == "&")	r = r $ "%3D";
		else if(s == "=")	r = r $ "%2B";
		else if(s == "+")	r = r $ "%24";
		else if(s == "$")	r = r $ "%2C";
		else if(s == ",")	r = r $ "%2F";
		else if(s == "/")	r = r $ "%20";
		else if(s == "?")	r = r $ "%3F";
		else if(s == "%")	r = r $ "%25";
		else if(s == "#")	r = r $ "%23";
		else if(s == "[")	r = r $ "%5B";
		else if(s == "]")	r = r $ "%5D";
		else				r = r $ s;
	}

	return r;
}

function Request(string InURI)
{
	Log("[UTBT]-[MapVote]-[Request]> [" $ HostAddress $ InURI $ "]");
	Browse(HostAddress, InURI);
}

function SetError(int Code)
{
	Disable('Tick');
	ResetBuffer();

	CurrentState = HadError;
	ErrorCode = Code;

	if(!IsConnected() || !Close())
		HTTPError(ErrorCode);
}