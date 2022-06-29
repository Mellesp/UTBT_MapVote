//=============================================================================
// MV_LogoWindow made by OwYeaW
//=============================================================================
class MV_LogoWindow extends UMenuDialogClientWindow;
//-----------------------------------------------------------------------------
#exec texture IMPORT NAME=UTBT_Logo			FILE=TEXTURES\UTBT_Logo.PCX			FLAGS=2		MIPS=OFF
//-----------------------------------------------------------------------------
function Paint(Canvas C, float X, float Y) 
{
	if(bMouseDown)
	{
		C.DrawColor.R = 200;
		C.DrawColor.G = 200;
		C.DrawColor.B = 255;
	}
	else if(X >= 0
	&& X <= WinWidth
	&& Y >= 0
	&& Y <= WinHeight)
	{
		C.DrawColor.R = 160;
		C.DrawColor.G = 160;
		C.DrawColor.B = 200;
	}
	else
	{
		C.DrawColor.R = 96;
		C.DrawColor.G = 96;
		C.DrawColor.B = 128;
	}
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'UTBT_Logo');
}
