//=============================================================================
// MV_Mutator made by OwYeaW
//=============================================================================
class MV_Mutator expands Mutator;
//-----------------------------------------------------------------------------
var MV_Requester			Requester;
var MV_Settings				Settings;
var MV_RequesterSettings	RequesterSettings;
var MV_Cache				Cache;

var int CurrentID, CurrentPlayerCount, TimeLeft, ScoreBoardTime;
var string msgPrefix, NextMap;
var bool bMidGameVote, bSwitchingLevel, bServerTravel, bSwitchFailed;

struct PlayerInfo
{
	var PlayerPawn	PP;
	var bool		bVoted;
	var string		VotedMap;
	var MV_Client	Client;
};
var PlayerInfo PPI[32];

struct VoteStatus
{
	var string	MapName;
	var int		VoteCount;
};
var VoteStatus VS[32];
//-----------------------------------------------------------------------------
function PreBeginPlay()
{
	local Object Obj;
	local MV_ActivityTracker AT;

	Obj = new (none, 'UTBT_MapVote') class'Object';

	Settings = new (Obj, 'Settings') class'MV_Settings';
	Settings.SaveConfig();

	RequesterSettings = new (Obj, 'Requester') class'MV_RequesterSettings';
	RequesterSettings.SaveConfig();

	Cache = new (Obj, 'Cache') class'MV_Cache';
	Cache.SaveConfig();

	Requester = Spawn(class'MV_Requester', Self);

	Level.Game.RegisterMessageMutator(Self);

	if(Settings.bSwitchLevelOnEmptyServer)
	{
		AT = Spawn(class'MV_ActivityTracker');
		AT.Mut		= Self;
		AT.Settings	= Settings;
	}
}
//-----------------------------------------------------------------------------
auto state Initializing
{
	ignores Mutate, MutatorTeamMessage, MutatorBroadcastMessage;
}
//-----------------------------------------------------------------------------
state Ready
{
	function Tick(float DeltaTime)
	{
		local Pawn P;

		Super.Tick(DeltaTime);

		if(Level.Game.CurrentID > CurrentID)
		{
			for(P = Level.PawnList; P != None; P = P.NextPawn)
				if(P.PlayerReplicationInfo.PlayerID == CurrentID)
					break;
			CurrentID++;

			if(PlayerPawn(P) != None && P.bIsPlayer)
			{
				initPlayer(PlayerPawn(P));
				TallyVotes();
			}
		}

		if(Level.Game.NumPlayers > CurrentPlayerCount)
			CurrentPlayerCount = Level.Game.NumPlayers;
		else if(Level.Game.NumPlayers < CurrentPlayerCount)
		{
			CurrentPlayerCount = Level.Game.NumPlayers;
			cleanPPI();

			if(CurrentPlayerCount > 0)
				TallyVotes();
		}
	}

	Initialized:
		UpdateClientCaches();
		BroadcastAdd("Initialized - Ready for use!", true);
	stop;

	UpdateClients:
		ResetVoteStatus();
		ClearAllOpenWRI();
		UpdateClientCaches();
		BroadcastAdd("New Maplist Update!", true);
	stop;
}
//-----------------------------------------------------------------------------
state SwitchingLevel
{
	ignores Mutate, MutatorTeamMessage, MutatorBroadcastMessage;

	function BeginState()
	{
		local MV_WRI WRI;

		foreach allactors(class'MV_WRI', WRI)
		{
			WRI.CloseWindow();
			WRI.Destroy();
		}

		SetTimer(0.5, true);
	}

	function Timer()
	{
		local string RandomMap;

		if(bSwitchFailed)
		{
			bSwitchingLevel	= false;
			bServerTravel	= false;
			bSwitchFailed	= false;
			bMidGameVote	= false;
			BroadcastAdd("Map switch failed. Bad or missing map files.", true);

			if(Settings.bSwitchToRandomMapAtFailedMapSwitch)
			{
				SetTimer(0, false);
				RandomMap = Cache.GetRandomMap();
				BroadcastAdd("Switching to Random map: "$RandomMap, true);
				GotoState('Ready');
				SwitchLevel(RandomMap);
			}
			else
			{
				SetTimer(0, false);
				BroadcastAdd("Please vote another map.", true);
				GotoState('Ready');
			}
		}
		else if(!bServerTravel)
		{
			bServerTravel = true;
			Level.ServerTravel(NextMap$".unr?game="$string(Level.Game.Class), false);
		}
		else if(Level.NextSwitchCountdown < 0)
		{
			bSwitchFailed = true;
			SetTimer(1.5, false);
		}
	}
}
//-----------------------------------------------------------------------------
function ClearAllOpenWRI()
{
	local MV_WRI WRI;

	foreach allactors(class'MV_WRI', WRI)
		WRI.ClearAll();
}

function ResetVoteStatus()
{
	local int i;

	for(i = 0; i < ArrayCount(PPI); i++)
	{
		PPI[i].bVoted	= false;
		PPI[i].VotedMap	= "";
	}

	for(i = 0; i < ArrayCount(VS); i++)
	{
		VS[i].MapName	= "";
		VS[i].VoteCount	= 0;
	}
}

function UpdateClientCaches()
{
	local int i;

	for(i = 0; i < ArrayCount(PPI); i++)
		if(PPI[i].PP != None)
			if(PPI[i].Client != None)
				PPI[i].Client.Update();
}

function cleanPPI()
{
	local int i;

	for(i = 0; i < ArrayCount(PPI); i++)
	{
		if(PPI[i].PP == None || PPI[i].PP.Player == None)
		{
			PPI[i].PP		= None;
			PPI[i].bVoted	= false;
			PPI[i].VotedMap	= "";
			PPI[i].Client	= None;
		}
	}
}

function initPlayer(PlayerPawn PP)
{
	local int i;

	i = FindFreePPISlot();

	PPI[i].PP		= PP;
	PPI[i].bVoted	= false;
	PPI[i].VotedMap	= "";
	PPI[i].Client	= Spawn(class'MV_Client', PP);
	PPI[i].Client.Init(Self);
}

function int FindFreePPISlot()
{
	local int i;

	for(i = 0; i < ArrayCount(PPI); i++)
	{
		if(PPI[i].PP == none)
			return i;
		else if(PPI[i].PP.Player == none)
			return i;
	}
}

function int FindPlayer(PlayerPawn PP)
{
	local int i;

	for(i = 0; i < 32; i++)
		if(PPI[i].PP == PP)
			return i;
	return -1;
}

function OpenMapVote(PlayerPawn PP)
{
	local int i;
	local MV_WRI WRI;

	foreach allactors(class'MV_WRI', WRI)
		if(PP == WRI.Owner)
			return;

	i = FindPlayer(PP);

	if(i != -1)
	{
		PPI[i].Client.WRI = Spawn(class'MV_WRI', PP, , PP.Location);
		PPI[i].Client.WRI.Client = PPI[i].Client;
		PPI[i].Client.WRI.Mut = Self;
	}
}
// ==========================================================================
// VOTE (SAY) COMMANDS
// ==========================================================================
function Mutate(string MutateString, PlayerPawn Sender)
{
	local string MapName;

	Super.Mutate(MutateString, Sender);

	//	UTBT: keeping the oldskool commands
	if(left(Caps(MutateString), 19) == "BDBMAPVOTE VOTEMENU")
	{
		OpenMapVote(Sender);
	}
	else if(left(Caps(MutateString), 14) == "BDBMAPVOTE MAP")
	{
		MapName = Right(MutateString, len(MutateString)-15);

		if(Cache.DoesMapExist(MapName))
			VoteMap(Sender, MapName);
		else
			Sender.ClientMessage(msgPrefix$"Map name not found in map list");
	}
}

function bool MutatorTeamMessage(Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep)
{
	if(Sender == Receiver && PlayerPawn(Receiver) != None)
		if(S ~= "!V" || S ~= "!VOTE")
			OpenMapVote(PlayerPawn(Receiver));

	if(NextMessageMutator != None)
		return NextMessageMutator.MutatorTeamMessage(Sender, Receiver, PRI, S, Type, bBeep);
	else
		return true;
}

function bool MutatorBroadcastMessage(Actor Sender, Pawn Receiver, out coerce string Msg, optional bool bBeep, out optional name Type)
{
	if(Sender == Receiver && PlayerPawn(Receiver) != None)
		if(Right(Msg, 2) ~= "!V" || Right(Msg, 5) ~= "!VOTE")
			OpenMapVote(PlayerPawn(Receiver));

	if(NextMessageMutator != None)
		return NextMessageMutator.MutatorBroadcastMessage(Sender, Receiver, Msg, bBeep, Type);
	else
		return true;
}
// ==========================================================================
// Vote functions
// ==========================================================================
function VoteMap(PlayerPawn PP, string MapName)
{
	local int i;

	if(bSwitchingLevel)
		return;

	i = FindPlayer(PP);

	if(i != -1)
	{
		if(PP.bAdmin)
		{
			BroadcastAdd(PP.PlayerReplicationInfo.PlayerName$" has forced a map switch to "$MapName);
			SwitchLevel(MapName);
		}
		else if(PP.PlayerReplicationInfo.bIsSpectator && !PP.PlayerReplicationInfo.bWaitingPlayer && !Settings.bAllowSpectatorVotes)
		{
			PP.ClientMessage("Spectators are not allowed to vote");
			return;
		}
		else if(PPI[i].VotedMap == MapName)
		{
			PPI[i].VotedMap = "";
			PPI[i].bVoted = false;
			BroadcastAdd(PP.PlayerReplicationInfo.PlayerName$" revoked their vote for "$MapName);
		}
		else
		{
			PPI[i].VotedMap = MapName;
			PPI[i].bVoted = true;
			BroadcastAdd(PP.PlayerReplicationInfo.PlayerName$" voted for "$MapName);
		}

		TallyVotes();
	}
}

function updateVoteStatus()
{
	local int i, x;
	local bool bFound;

	for(i = 0; i < ArrayCount(VS); i++)
	{
		VS[i].MapName	= "";
		VS[i].VoteCount	= 0;
	}

	for(i = 0; i < ArrayCount(PPI); i++)
	{
		if(PPI[i].PP != None)
		{
			if(PPI[i].bVoted && PPI[i].VotedMap != "")
			{
				bFound = false;
				for(x = 0; x < ArrayCount(VS); x++)
				{
					if(VS[x].MapName == PPI[i].VotedMap)
					{
						VS[x].VoteCount++;
						bFound = true;
						break;
					}
					else if(VS[x].MapName == "")
						break;
				}
				if(!bFound)
				{
					VS[x].MapName = PPI[i].VotedMap;
					VS[x].VoteCount = 1;
				}
			}
		}
	}
}

function rankVoteStatus()
{
	local int i, x, tmpVoteCount;
	local string tmpMapName;
	local bool bSwap;

	for(i = 0; i < ArrayCount(VS) - 1; i++)
	{
		x = i + 1;
		bSwap = false;
	
		if(VS[i].MapName == "")
			break;
		else if(VS[x].MapName == "")
			break;
		else
		{
			if(VS[i].VoteCount == VS[x].VoteCount)
			{
				if(VS[i].MapName > VS[x].MapName)
					bSwap = true;
			}
			else if(VS[i].VoteCount < VS[x].VoteCount)
				bSwap = true;

			if(bSwap)
			{
				tmpMapName		= VS[i].MapName;
				tmpVoteCount	= VS[i].VoteCount;

				VS[i].MapName	= VS[x].MapName;
				VS[i].VoteCount	= VS[x].VoteCount;

				VS[x].MapName	= tmpMapName;
				VS[x].VoteCount	= tmpVoteCount;
			}
		}
	}
}

function updateWRI(MV_WRI WRI)
{
	local int i;

	//	Clear WRI
	WRI.ClearStatus();

	//	Update PlayerList
	for(i = 0; i < ArrayCount(PPI); i++)
		if(PPI[i].PP != None)
			WRI.AddPlayer(PPI[i].PP.PlayerReplicationInfo.PlayerName, PPI[i].bVoted, PPI[i].VotedMap);

	//	Update VoteList
	for(i = 0; i < ArrayCount(VS); i++)
	{
		if(VS[i].MapName != "")
			WRI.AddVote(VS[i].MapName, VS[i].VoteCount);
		else
			break;
	}
}

function TallyVotes()
{
	local int i, totalVotes;
	local float votedPercent;
	local MV_WRI WRI;

	if(bSwitchingLevel)
		return;

	updateVoteStatus();
	rankVoteStatus();

	foreach allactors(class'MV_WRI', WRI)
		updateWRI(WRI);

	for(i = 0; i < ArrayCount(VS) - 1; i++)
	{
		if(VS[i].MapName == "")
			break;
		else
			totalVotes += VS[i].VoteCount;
	}

	if(CurrentPlayerCount <= 0)
		votedPercent = 0;
	else
		votedPercent = float(totalVotes) / float(CurrentPlayerCount);

	if(votedPercent == 1)
	{
		EndVoting();
	}
	else if(votedPercent*100 > Settings.MidGameVotePercent && !bMidGameVote)
	{
		bMidGameVote = true;
		BroadcastAdd("Mid-Game Map Voting has been initiated!", true);
		TimeLeft = Settings.VoteTimeLimit;
		SetTimer(1, true);
	}
}

event Timer()
{
	local Pawn P;
	local int i;

	if(ScoreBoardTime > 0)
	{
		ScoreBoardTime--;
		if(ScoreBoardTime == 0)
		{
			for(i = 0; i < ArrayCount(PPI); i++)
				if(PPI[i].PP != None && !PPI[i].bVoted)
					OpenMapVote(PPI[i].PP);
		}
		return;
	}

	if(TimeLeft == 60)
	{
		BroadcastAdd("1 Minute left to vote!", true);
		for(P = Level.PawnList; P != None; P = P.nextPawn)
			if(P.IsA('TournamentPlayer'))
				TournamentPlayer(P).TimeMessage(12);
	}
	else if(TimeLeft == 30)
	{
		BroadcastAdd("30 seconds left to vote!", true);
		for(P = Level.PawnList; P != None; P = P.nextPawn)
			if(P.IsA('TournamentPlayer'))
				TournamentPlayer(P).TimeMessage(11);
	}
	else if(TimeLeft < 11 && TimeLeft > 0)
	{
		if(TimeLeft == 10)
			BroadcastAdd("10 seconds left to vote!", true);
		for(P = Level.PawnList; P != None; P = P.nextPawn)
			if(P.IsA('TournamentPlayer'))
				TournamentPlayer(P).TimeMessage(TimeLeft);
	}
	else if(TimeLeft <= 0)
	{
		SetTimer(0, false);
		EndVoting();
	}

	TimeLeft--;
}

function EndVoting()
{
	local int i, topMapCount, topVoteCount, rng;
	local string RandomMap;

	for(i = 0; i < ArrayCount(VS) - 1; i++)
	{
		if(VS[i].MapName == "")
		{
			break;
		}
		else if(i == 0)
		{
			topVoteCount	= VS[i].VoteCount;
			topMapCount		= 1;
		}
		else if(topVoteCount == VS[i].VoteCount)
		{
			topMapCount++;
		}
	}

	if(topMapCount == 0)
	{
		if(Settings.bSwitchToRandomMap)
		{
			RandomMap = Cache.GetRandomMap();
			BroadcastAdd("No map voted. Switching to Random map: "$RandomMap, true);
			SwitchLevel(RandomMap);
		}
		else
		{
			BroadcastAdd("No map voted. Switching to Default map: "$Settings.DefaultMap, true);
			SwitchLevel(Settings.DefaultMap);
		}
	}
	else if(topMapCount == 1)
	{
		BroadcastAdd(VS[0].MapName$" has won!", true);
		SwitchLevel(VS[0].MapName);
	}
	else
	{
		BroadcastAdd(topMapCount$" top voted maps. Picking a random map from these "$topMapCount$".", true);
		rng = Rand(topMapCount);
		BroadcastAdd(VS[rng].MapName$" has won!", true);
		SwitchLevel(VS[rng].MapName);
	}
}

function SwitchLevel(string MapName)
{
	bSwitchingLevel = true;
	NextMap = MapName;
	GotoState('SwitchingLevel');
}

function bool HandleEndGame()
{
	Super.HandleEndGame();

	DeathMatchPlus(Level.Game).bDontRestart = true;
	TimeLeft		= Settings.VoteTimeLimit;
	ScoreBoardTime	= Settings.ScoreBoardDelay;
	SetTimer(1, true);
	return false;
}

function EmptyServerTrigger()
{
	local string RandomMap;

	if(Settings.bSwitchToRandomMap)
	{
		RandomMap = Cache.GetRandomMap();
		BroadcastAdd("Inactivity for "$Settings.EmptyServerTimeMinutes$" minutes. Switching to Random map: "$RandomMap, true);
		SwitchLevel(RandomMap);
	}
	else
	{
		BroadcastAdd("Inactivity for "$Settings.EmptyServerTimeMinutes$" minutes. Switching to Default map: "$Settings.DefaultMap, true);
		SwitchLevel(Settings.DefaultMap);
	}
}

event BroadcastAdd(string msg, optional bool bPrefix)
{
	local Pawn P;

	if(bPrefix)
		msg = msgPrefix $ msg;

	for(P = Level.PawnList; P != None; P = P.nextPawn)
		if(P.IsA('PlayerPawn'))
			P.ClientMessage(Msg, 'Event', true);
}
//-----------------------------------------------------------------------------
defaultproperties
{
	bSwitchingLevel=false
	bServerTravel=false
	bSwitchFailed=false
	msgPrefix="[UTBT MapVote] "
}