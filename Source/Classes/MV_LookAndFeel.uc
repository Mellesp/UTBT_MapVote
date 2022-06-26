//=============================================================================
// MV_LookAndFeel made by OwYeaW
//=============================================================================
class MV_LookAndFeel expands UMenuBlueLookAndFeel;
//-----------------------------------------------------------------------------
#exec TEXTURE IMPORT NAME=SB				FILE=TEXTURES\SB.BMP						MIPS=OFF
#exec TEXTURE IMPORT NAME=NewButton			FILE=TEXTURES\NewButton.BMP			FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=UTBT_LookAndFeel	FILE=TEXTURES\UTBT_LookAndFeel.PCX	FLAGS=2 MIPS=OFF
//-----------------------------------------------------------------------------
var MV_MainWindow	Main;
//-----------------------------------------------------------------------------
function SB_VDraw(UWindowVScrollbar W, Canvas C)
{
	C.DrawColor.R = 8;
	C.DrawColor.G = 8;
	C.DrawColor.B = 8;
	W.DrawStretchedTexture(C, W.WinWidth/5*2, 3, W.WinWidth/5, W.WinHeight-6, Texture'WhiteTexture');

	if(!W.bDisabled)
	{
		C.DrawColor.R = 96;
		C.DrawColor.G = 96;
		C.DrawColor.B = 96;
		W.DrawStretchedTexture(C, 0, W.ThumbStart, Size_ScrollbarWidth, W.ThumbHeight, Texture'SB');
	}
}

function SB_SetupUpButton(UWindowSBUpButton W)
{
	local Texture T;

	T = Texture'UTBT_LookAndFeel';

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = SBUpUp;
	W.DownRegion = SBUpDown;
	W.OverRegion = SBUpUp;
	W.DisabledRegion = SBUpDisabled;
}

function SB_SetupDownButton(UWindowSBDownButton W)
{
	local Texture T;

	T = Texture'UTBT_LookAndFeel';

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = SBDownUp;
	W.DownRegion = SBDownDown;
	W.OverRegion = SBDownUp;
	W.DisabledRegion = SBDownDisabled;
}

function Button_DrawSmallButton(UWindowSmallButton B, Canvas C)
{
	local float Y, H, W;
	local float SB;

	if(B.bDisabled)
		Y = 144;
	else if(B.bMouseDown || B.bRMouseDown)
		Y = 72;
	else
		Y = 0;

	if(MV_Button(B) != None)
		C.DrawColor = MV_Button(B).ButtonColor;

	SB = 6;
	W = B.WinWidth;
	H = B.WinHeight;
	B.DrawStretchedTextureSegment(C, 0      , 0   , SB    , SB    , 0,		Y,		34,		31, SmallButton);	//TL
	B.DrawStretchedTextureSegment(C, 0      , SB  , SB    , H-SB*2, 0,		Y+31,	34,		2, SmallButton);	//CL
	B.DrawStretchedTextureSegment(C, 0      , H-SB, SB    , SB    , 0,		Y+33,	34,		31, SmallButton);	//BL
	B.DrawStretchedTextureSegment(C, SB     , 0   , W-SB*2, SB    , 34,		Y,		124,	31, SmallButton);	//T
	B.DrawStretchedTextureSegment(C, SB     , SB  , W-SB*2, H-SB*2, 34,		Y+31,	124,	2, SmallButton);	//C
	B.DrawStretchedTextureSegment(C, SB     , H-SB, W-SB*2, SB    , 34,		Y+33,	124,	31, SmallButton);	//B
	B.DrawStretchedTextureSegment(C, W-SB   , 0   , SB    , SB    , 158,	Y,		34,		31, SmallButton);	//TR
	B.DrawStretchedTextureSegment(C, W-SB   , SB  , SB    , H-SB*2, 158,	Y+31,	34,		2, SmallButton);	//CR
	B.DrawStretchedTextureSegment(C, W-SB   , H-SB, SB    , SB    , 158,	Y+33,	34,		31, SmallButton);	//BR
}

function MV_Editbox_SetupSizes(MV_EditControl W, Canvas C)
{
	local float TW, TH;
	local int B;

	B = EditBoxBevel;

	C.Font = Main.Fonts[Main.F_Button];
	W.TextSize(C, W.Text, TW, TH);

	W.WinHeight = W.EditBoxHeight;
	
	switch(W.Align)
	{
		case TA_Left:
			W.EditAreaDrawX = W.WinWidth - W.EditBoxWidth;
			W.TextX = 0;
			break;
		case TA_Right:
			W.EditAreaDrawX = 0;	
			W.TextX = W.WinWidth - TW;
			break;
		case TA_Center:
			W.EditAreaDrawX = (W.WinWidth - W.EditBoxWidth) / 2;
			W.TextX = (W.WinWidth - TW) / 2;
			break;
	}

	W.EditAreaDrawY = W.WinHeight;
	W.TextY = (W.WinHeight - TH) / 2;

	W.EditBox.WinLeft = W.EditAreaDrawX + MiscBevelL[B].W;
	W.EditBox.WinTop = MiscBevelT[B].H;
	W.EditBox.WinWidth = W.EditBoxWidth - MiscBevelL[B].W - MiscBevelR[B].W;
	W.EditBox.WinHeight = W.WinHeight - MiscBevelT[B].H - MiscBevelB[B].H;
}

defaultproperties
{
	Size_MinScrollbarHeight=32
	SmallButton=Texture'NewButton'
}