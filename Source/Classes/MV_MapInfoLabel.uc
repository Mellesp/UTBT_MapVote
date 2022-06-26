//=============================================================================
// MV_MapInfoLabel made by OwYeaW
//=============================================================================
class MV_MapInfoLabel expands UWindowLabelControl;
//-----------------------------------------------------------------------------
var MV_MainWindow	Main;
//-----------------------------------------------------------------------------
function Created()
{
	Super.Created();
	Main = MV_MainWindow(ParentWindow);
}
//-----------------------------------------------------------------------------
function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;

	Super.BeforePaint(C, X, Y);

	C.Font = Main.Fonts[Main.F_Button];
	TextSize(C, Text, W, H);
	WinHeight = H+1;

	TextY = (WinHeight - H) / 2;
	switch(Align)
	{
		case TA_Left:
			break;
		case TA_Center:
			TextX = (WinWidth - W)/2;
			break;
		case TA_Right:
			TextX = WinWidth - W;
			break;
	}	
}
//-----------------------------------------------------------------------------
function Paint(Canvas C, float X, float Y)
{
	if(Text != "")
	{
		C.DrawColor = Main.MapInfoColor;
		ClipText(C, TextX, TextY, Text);
	}
}