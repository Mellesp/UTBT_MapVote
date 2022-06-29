//=============================================================================
// MV_Button made by OwYeaW
//=============================================================================
class MV_Button expands UWindowSmallButton;
//-----------------------------------------------------------------------------
var color			ButtonColor;
var MV_MainWindow	Main;
//-----------------------------------------------------------------------------
function Created()
{
	bNoKeyboard = true;

	Super(UWindowButton).Created();
	Main = MV_MainWindow(ParentWindow);

	ToolTipString = "";
	SetText("");
}
//-----------------------------------------------------------------------------
function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;
	C.Font = Main.Fonts[Main.F_Button];
	
	TextSize(C, RemoveAmpersand(Text), W, H);

	TextX = (WinWidth-W)/2;
	TextY = (WinHeight-H)/2;

	if(bMouseDown)
	{
		TextX += 1;
		TextY += 1;
	}		
}
//-----------------------------------------------------------------------------
function MouseEnter()
{
	Super.MouseEnter();

	ButtonColor.R = 80;
	ButtonColor.G = 80;
	ButtonColor.B = 80;
}

function MouseLeave()
{
	Super.MouseLeave();

	ButtonColor.R = 48;
	ButtonColor.G = 48;
	ButtonColor.B = 48;
}
//-----------------------------------------------------------------------------
function Paint(Canvas C, float X, float Y)
{
	LookAndFeel.Button_DrawSmallButton(Self, C);

	if(Text != "")
	{
		C.DrawColor = TextColor;
		ClipText(C, TextX, TextY, Text, True);
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
	}
}
//-----------------------------------------------------------------------------
function RClick(float X, float Y) 
{
	Super.RClick(X, Y);
	GetPlayerOwner().PlaySound(Sound'Botpack.Click', SLOT_Interface);
}
//-----------------------------------------------------------------------------
defaultproperties
{
	TextColor=(R=255,G=255,B=255)
	ButtonColor=(R=48,G=48,B=48)
}