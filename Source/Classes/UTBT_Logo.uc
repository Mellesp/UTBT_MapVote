//=============================================================================
// UTBT_Logo.
//=============================================================================
class UTBT_Logo expands actor;

// #exec MESH IMPORT MESH=UTBT_Logo ANIVFILE=Models\UTBT_Logo_a.3d DATAFILE=Models\UTBT_Logo_d.3d X=0 Y=0 Z=0 LODSTYLE=10 LODFRAME=0 
// #exec MESH ORIGIN MESH=UTBT_Logo X=0 Y=0 Z=0 YAW=-64 PITCH=0 ROLL=0

// #exec MESH SEQUENCE MESH=UTBT_Logo SEQ=ALL    STARTFRAME=0 NUMFRAMES=0 RATE=24
// #exec MESH SEQUENCE MESH=UTBT_Logo SEQ=Still    STARTFRAME=0 NUMFRAMES=1 RATE=24

// #exec MESHMAP NEW MESHMAP=UTBT_Logo MESH=UTBT_Logo
// #exec MESHMAP SCALE MESHMAP=UTBT_Logo X=0.1 Y=0.1 Z=0.2

// // #exec TEXTURE IMPORT NAME=Texture FILE=Textures\Texture.PCX GROUP=Skins FLAGS=2
// // #exec MESHMAP SETTEXTURE MESHMAP=UTBT_Logo NUM=0 TEXTURE=Texture

// defaultproperties
// {
//     DrawType=DT_Mesh
//     Mesh=UTBT_Logo
// }