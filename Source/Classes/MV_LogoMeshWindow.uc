//=============================================================================
// MV_LogoMeshWindow made by OwYeaW
//=============================================================================
class MV_LogoMeshWindow extends UMenuDialogClientWindow;
//-----------------------------------------------------------------------------
var MV_LogoMesh Logo;
var rotator ViewRotator;
//-----------------------------------------------------------------------------
function Created()
{
	Super.Created();

	Logo = GetEntryLevel().Spawn(class'MV_LogoMesh', GetEntryLevel());
	ViewRotator = rot(0, 32768, 0);
}
//-----------------------------------------------------------------------------
function BeforePaint(Canvas C, float X, float Y)
{
	if(bMouseDown)
		ViewRotator.Yaw += 128;
}

function Paint(Canvas C, float X, float Y) 
{
	local float OldFov;

	if(Logo != None)
	{
		OldFov = GetPlayerOwner().FOVAngle;
		GetPlayerOwner().SetFOVAngle(30);
		DrawClippedActor( C, WinWidth/2, WinHeight/2, Logo, False, ViewRotator, vect(0, 0, 0) );
		GetPlayerOwner().SetFOVAngle(OldFov);
	}
}

function Tick(float Delta)
{
	if(!bMouseDown)
		ViewRotator.Yaw += 32;
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	if(Logo != None)
	{
		Logo.Destroy();
		Logo = None;
	}
}

defaultproperties
{
	
}