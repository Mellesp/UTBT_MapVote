//=============================================================================
// MV_ActivityTracker made by OwYeaW
//=============================================================================
class MV_ActivityTracker extends Info;

var MV_Mutator	Mut;
var MV_Settings	Settings;

var int EmptyMinutes;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
	SetTimer(60, true);
}

event Timer()
{
	if(Level.Game.NumPlayers == 0)
	{
		if(++EmptyMinutes >= Settings.EmptyServerTimeMinutes)
		{
			Mut.EmptyServerTrigger();
			return;
		}
	}
	else
		EmptyMinutes = 0;
}

defaultproperties
{
	EmptyMinutes=0
}