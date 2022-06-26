//=============================================================================
// MV_LogoMesh made by OwYeaW
//=============================================================================
class MV_LogoMesh extends Info;

// #exec MESH IMPORT MESH=UTBT_Logo ANIVFILE=MODELS\UTBT_Logo_a.3d DATAFILE=MODELS\UTBT_Logo_d.3d X=0 Y=0 Z=0
// #exec MESH ORIGIN MESH=UTBT_Logo X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0

// #exec MESH SEQUENCE MESH=UTBT_Logo SEQ=All    	 STARTFRAME=0 NUMFRAMES=1
// #exec MESH SEQUENCE MESH=UTBT_Logo SEQ=UTBT_Logo STARTFRAME=0 NUMFRAMES=1

// #exec MESHMAP NEW   MESHMAP=UTBT_Logo MESH=UTBT_Logo
// #exec MESHMAP SCALE MESHMAP=UTBT_Logo X=0.1 Y=0.1 Z=0.2

defaultproperties
{
	// Mesh=LodMesh'UTBT_Logo'
	Mesh=LodMesh'Botpack.U'
	Texture=Texture'Botpack.Translocator.Tranglow'
	bMeshEnviroMap=True
	bHidden=False
	bOnlyOwnerSee=True
	bAlwaysTick=True
	Physics=PHYS_Rotating
	RemoteRole=ROLE_None
	DrawType=DT_Mesh
	DrawScale=0.1
	AmbientGlow=255
	bUnlit=True
	CollisionRadius=0.000000
	CollisionHeight=0.000000
}