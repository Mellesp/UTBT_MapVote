//=============================================================================
// MV_HTMLTextArea made by OwYeaW
//=============================================================================
class MV_HTMLTextArea expands UWindowHTMLTextArea;
//-----------------------------------------------------------------------------
var MV_MainWindow	Main;
//-----------------------------------------------------------------------------
function Created()
{
	Super.Created();
	Main = MV_MainWindow(ParentWindow);
}
//-----------------------------------------------------------------------------
function Paint(Canvas C, float X, float Y)
{
	Super(UWindowDynamicTextArea).Paint(C, X, Y);
	bReleased = False;
}
//-----------------------------------------------------------------------------
function SetCanvasStyle(Canvas C, HTMLStyle CurrentStyle)
{
	if(CurrentStyle.bLink)
		C.DrawColor = LinkColor;
	else
		C.DrawColor = CurrentStyle.TextColor;

	if(CurrentStyle.bHeading)
		C.Font = Main.Fonts[Main.F_HeaderBold];
	else if(CurrentStyle.bBold)
		C.Font = Main.Fonts[Main.F_ListItemBold];
	else
		C.Font = Main.Fonts[Main.F_ListItem];
}