#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
//#include <sdkhooks>



#define INFO_NAME "Left 4 Dead 2 Cheat Survivor Bot"
#define INFO_AUTHOR "Randerion(HaoJun0823)"
#define INFO_DESCRIPTION "Modify survivor bot ability."
#define INFO_VERSION "0.1c"
#define INFO_URL "https://steamcommunity.com/id/HaoJun0823/"

#define TEAM_SPECTATORS 1
#define TEAM_SURVIVORS 2
#define TEAM_INFECTED 3

/* Thanks for Peace-Maker address:https://forums.alliedmods.net/showthread.php?t=289217 */
#define L4D2_WEPUPGFLAG_NONE            (0 << 0) // 0
#define L4D2_WEPUPGFLAG_INCENDIARY      (1 << 0) // 1
#define L4D2_WEPUPGFLAG_EXPLOSIVE       (1 << 1) // 2
#define L4D2_WEPUPGFLAG_LASER (1 << 2) // 4

/*
static String:Ent_Slot0[] = { "smg_silenced", "smg", "pumpshotgun", "shotgun_chrome", "autoshotgun", "shotgun_spas", "hunting_rifle", "sniper_military", "rifle", "rifle_ak47", "rifle_desert", "grenade_launcher", "rifle_m60", "rifle_sg552", "smg_mp5", "sniper_awp", "sniper_scout" };
static String:Ent_Slot1[] = { "pistol", "pistol_magnum", "baseball_bat", "cricket_bat", "crowbar", "electric_guitar", "fireaxe", "frying_pan", "golfclub", "katana", "hunting_knife", "machete", "riotshield", "tonfa", "chainsaw" };
static String:Ent_Slot2[] = { "molotov", "vomitjar", "pipe_bomb" };
static String:Ent_Slot3[] = { "first_aid_kit", "defibrillator", "upgradepack_explosive", "upgradepack_incendiary" };
static String:Ent_Slot4[] = { "adrenaline", "pain_pills" };
*/

new GameVersion;

new WeaponReload[MAXPLAYERS + 1];
new WeaponReloadCount;

new Handle:SurvivorBotPluginSwitch = INVALID_HANDLE;
new Handle:SurvivorBotHealthMul = INVALID_HANDLE;
new Handle:SurvivorBotInfiniteAmmo = INVALID_HANDLE;
new Handle:SurvivorBotFullHeal = INVALID_HANDLE;
new Handle:SurvivorBotWeaponSpeedMul = INVALID_HANDLE;
new Handle:SurvivorBotMeleeSpeedMul = INVALID_HANDLE;
new Handle:SurvivorBotMoveSpeedMul = INVALID_HANDLE;
new Handle:SurvivorBotGravity = INVALID_HANDLE;
new Handle:SurvivorBotLaserSight = INVALID_HANDLE;
new Handle:SurvivorBotSpecialAmmo = INVALID_HANDLE;
new Handle:SurvivorBotExtraItem = INVALID_HANDLE;
new Handle:SurvivorBotHealItem = INVALID_HANDLE;
new Handle:SurvivorBotGrenade = INVALID_HANDLE;
new Handle:SurvivorBotPrimaryWeapon = INVALID_HANDLE;
new Handle:SurvivorBotSecondaryWeapon = INVALID_HANDLE;
new Handle:SurvivorBotRefelectDamage = INVALID_HANDLE;


public Plugin:myinfo =
{
	name = INFO_NAME,
	author = INFO_AUTHOR,
	description = INFO_DESCRIPTION,
	version = INFO_VERSION,
	url = INFO_URL
};

public OnPluginStart()
{
	GameVersion = getGameVersion();

	AutoExecConfig(true, "l4d2_survivor_cheat_bot");

	SurvivorBotPluginSwitch = CreateConVar("randerion_l4d_survivor_bot_plugin_switch", "1", "Whether the plugin is started.(on:1;off:0)", 0, true, 0.0);

	SurvivorBotHealthMul = CreateConVar("randerion_l4d_survivor_bot_health_mul", "5.0", "Set survivor robot's life multiple.(default:1.0;more:>1.0;less:<1.0)", 0, true, 0.01);
	SurvivorBotInfiniteAmmo = CreateConVar("randerion_l4d_survivor_bot_infinite_ammo", "1", "When the value is 1, make survivor robot have infinite ammo.(on:1;off:0)", 0, true, 0.0);
	SurvivorBotFullHeal = CreateConVar("randerion_l4d_survivor_bot_full_heal", "1", "When the value is 1, the healing of the survivor robot will restore all health.(on:1;off:0)", 0, true, 0.0);
	SurvivorBotWeaponSpeedMul = CreateConVar("randerion_l4d_survivor_bot_weapon_speed_mul", "0.5", "Set survivor robot's weapon shot speed.(default:1.0;faster:<1.0;slower:>1.0)", 0, true, 0.0);
	SurvivorBotMeleeSpeedMul = CreateConVar("randerion_l4d_survivor_bot_melee_speed_mul", "0.5", "Set survivor robot's melee attack speed.(default:1.0;faster:<1.0;slower:>1.0)", 0, true, 0.0);
	SurvivorBotMoveSpeedMul = CreateConVar("randerion_l4d_survivor_bot_move_speed_mul", "1.5", "Set survivor robot's move speed multiple.(default:1.0;faster:>1.0;slower:<1.0)", 0, true, 0.1);
	SurvivorBotGravity = CreateConVar("randerion_l4d_survivor_bot_gravity", "0.5", "Set survivor robot's gravity.(default:1.0;lighter:<1.0;heavier:>1.0)", 0, true, 0.0);
	SurvivorBotRefelectDamage = CreateConVar("randerion_l4d_survivor_bot_refelect_damage", "0.5", "Set survivor robot can refelect damage.(default:0.5;off:=0.0;on:>0.0)", 0, true, 0.0);
	SurvivorBotLaserSight = CreateConVar("randerion_l4d_survivor_bot_laser_sight", "1", "Set survivor robot auto get lazer sight.(default:1;on:1;off:0)", 0, true, 0.0);
	SurvivorBotSpecialAmmo = CreateConVar("randerion_l4d2_survivor_bot_special_ammo", "3", "Set survivor robot auto get special ammo.(default:3;off:0;incendiary:1,explosive:2,random_both_ammo:3)", 0, true, 0.0);
	
	SurvivorBotExtraItem = CreateConVar("randerion_l4d_survivor_bot_extra_heal_item", "3", "Set survivor robot auto get pill or adrenaline.(default:3;off:0;pill:1,adrenaline:2,random_both_item:3)", 0, true, 0.0);
	//SurvivorBotHealItem = CreateConVar("randerion_l4d_survivor_bot_heal_or_upgrade_item", "1", "Set survivor robot auto get first aid kit or defibrillator or explosive upgradepack or incendiary upgradepack.(default:1;off:0;first_aid_kit:1,defibrillator:2,explosive:4,incendiary:8,1+2+4+8=15=Random_All)", 0, true, 0.0);
	SurvivorBotHealItem = CreateConVar("randerion_l4d_survivor_bot_heal_or_upgrade_item", "1", "Set survivor robot auto get first aid kit.(default:1;off:0;first_aid_kit:1)", 0, true, 0.0);
	SurvivorBotPrimaryWeapon = CreateConVar("randerion_l4d_survivor_bot_primary_weapon", "1", "Set survivor robot auto get pumpshotgun.(default:1;off:0;pumpshotgun:1)", 0, true, 0.0);
	SurvivorBotSecondaryWeapon = CreateConVar("randerion_l4d2_survivor_bot_secondary_weapon", "1", "Set survivor robot auto get pistol magnum.(default:1;off:0;pistol_magnum:1)", 0, true, 0.0);
	SurvivorBotGrenade = CreateConVar("randerion_l4d_survivor_bot_grenade_item", "1", "Set survivor robot auto get pipe bomb.(default:1;off:0;pipe_bomb:1)", 0, true, 0.0);


	if (GetConVarInt(SurvivorBotPluginSwitch) == 1) {

		HookEvent("player_spawn", PlayerSpawn);
		HookEvent("weapon_fire", WeaponFire);
		HookEvent("player_first_spawn", PlayerFirstSpawn);
		HookEvent("heal_success", PlayerHealSuccess);
		HookEvent("item_pickup", PlayerPickupItem);
		HookEvent("ammo_pickup", PlayerPickupAmmo);
		//HookEvent("spawner_give_item", SpawnerGiveItem);
		HookEvent("weapon_reload", PlayerReload);
		HookEvent("weapon_fire_on_empty", PlayerFireOnEmpty);
		HookEvent("pills_used", PlayerPillsUsed);
		HookEvent("adrenaline_used", PlayerAdrenalineUsed);
		//HookEvent("defibrillator_used", PlayerDefibrillatorUsed);
		HookEvent("pills_used", PlayerPillsUsed);
		HookEvent("grenade_bounce", PlayerGrenadeBounce);
		HookEvent("hegrenade_detonate", PlayerGrenadeDetonate);
		HookEvent("player_hurt", PlayerHurt);

	}

}

/*
public Action:PlayerDefibrillatorUsed(Handle:event, String:event_name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
}
*/

/*
public Action:SpawnerGiveItem(Handle:event, String:event_name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
}
*/

public Action:PlayerPillsUsed(Handle:event, String:event_name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsFakeClient(client) && GetClientTeam(client) == TEAM_SURVIVORS) {GiveItemsByCvars(client);}
}

public Action:PlayerGrenadeBounce(Handle:event, String:event_name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsFakeClient(client) && GetClientTeam(client) == TEAM_SURVIVORS) {GiveItemsByCvars(client);}
}

public Action:PlayerGrenadeDetonate(Handle:event, String:event_name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsFakeClient(client) && GetClientTeam(client) == TEAM_SURVIVORS) {GiveItemsByCvars(client);}
}

public Action:PlayerAdrenalineUsed(Handle:event, String:event_name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsFakeClient(client) && GetClientTeam(client) == TEAM_SURVIVORS) {GiveItemsByCvars(client);}
}

public Action:PlayerReload(Handle:event, String:event_name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsFakeClient(client) && GetClientTeam(client) == TEAM_SURVIVORS) {GiveItemsByCvars(client);}

}

public Action:PlayerFireOnEmpty(Handle:event, String:event_name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsFakeClient(client) && GetClientTeam(client) == TEAM_SURVIVORS) {GiveItemsByCvars(client);}

}



public Action:PlayerPickupItem(Handle:event, String:event_name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsFakeClient(client) && GetClientTeam(client) == TEAM_SURVIVORS) {GiveItemsByCvars(client);}


}

public Action:PlayerPickupAmmo(Handle:event, String:event_name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsFakeClient(client) && GetClientTeam(client) == TEAM_SURVIVORS) {GiveItemsByCvars(client);}

}

public Action:PlayerHealSuccess(Handle:event, String:event_name[], bool:dontBroadcast) {

	if (GetConVarInt(SurvivorBotFullHeal) == 1) {

		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		new subject = GetClientOfUserId(GetEventInt(event, "subject"));
		/*
		new health_restored = GetClientOfUserId(GetEventInt(event,"health_restored"));
		*/

		if (IsFakeClient(client) && GetClientTeam(client) == TEAM_SURVIVORS) {
		
			GiveItemsByCvars(client);
		
		}

		if (IsFakeClient(subject) && GetClientTeam(subject) == TEAM_SURVIVORS) {

			if (HasEntProp(subject, Prop_Data, "m_iHealth") && HasEntProp(subject, Prop_Data, "m_iMaxHealth")) {

				/*
						new before_health = GetEntProp(subject,Prop_Data,"m_iHealth") - health_restored;
						new health_mul = health_restored * GetConVarFloat(SurvivorBotHealthMul);
				*/

				SetEntProp(subject, Prop_Data, "m_iHealth", GetEntProp(subject, Prop_Data, "m_iMaxHealth"));

			}

			GiveItemsByCvars(subject);

		}
	}
}

public Action:PlayerFirstSpawn(Handle:event, String:event_name[], bool:dontBroadcast) {

	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (!IsFakeClient(client))
	{

		PrintToChat(client, "[CheatBot]%s %s has been enabled.\nCreate by %s.", INFO_NAME, INFO_VERSION, INFO_AUTHOR);
		
		
		switch(GameVersion){
			case 1:
			PrintToChat(client, "This Game is Left 4 Dead 1.");
			case 2:
			PrintToChat(client, "This Game is Left 4 Dead 2.");
			default:
			PrintToChat(client, "This Game is Not Left 4 Dead.");
			
		}			
		
		
		PrintToChat(client, "\nSurvivor Bot Status:\nHealth:%d\nWeapon Speed:%.2f%%\nMelee Speed:%.2f%%\nMove Speed:%.2f%%\nGravity:%.2f\nRefelectDamage:%.2f%%\n", 100 * GetConVarInt(SurvivorBotHealthMul), 1.0 / GetConVarFloat(SurvivorBotWeaponSpeedMul) * 100, 1.0 / GetConVarFloat(SurvivorBotMeleeSpeedMul) * 100, 100 * GetConVarFloat(SurvivorBotMoveSpeedMul), GetConVarFloat(SurvivorBotGravity),100 * GetConVarFloat(SurvivorBotRefelectDamage));
		if (GetConVarInt(SurvivorBotInfiniteAmmo) == 1)
		{
			PrintToChat(client, "Survivor Bot have infinite ammo.");
		}
		else
		{
			PrintToChat(client, "Survivor Bot don't have infinite ammo.");
		}
		if (GetConVarInt(SurvivorBotFullHeal) == 1)
		{
			PrintToChat(client, "Survivor Bot have full heal.");
		}
		else
		{
			PrintToChat(client, "Survivor Bot don't have full heal.");
		}
		if (GetConVarInt(SurvivorBotLaserSight) == 1)
		{
			PrintToChat(client, "Survivor Bot will auto get laser sight.");
		}
		else
		{
			PrintToChat(client, "Survivor Bot will not auto get laser sight.");
		}				
		switch(GetConVarInt(SurvivorBotSpecialAmmo)){
			case 1:
			PrintToChat(client, "Survivor Bot will auto get incendiary ammo.");
			case 2:
			PrintToChat(client, "Survivor Bot will auto get explosive ammo.");
			case 3:
			PrintToChat(client, "Survivor Bot will auto get incendiary or explosive ammo.");
			default:
			PrintToChat(client, "Survivor Bot will not auto get special ammo.");
			
		}
		switch(GetConVarInt(SurvivorBotHealItem)){
			case 1:
			PrintToChat(client, "Survivor Bot will auto get first aid kit.");
			default:
			PrintToChat(client, "Survivor Bot will not auto get any heal or upgrade item.");
			
		}
		switch(GetConVarInt(SurvivorBotExtraItem)){
			case 1:
			PrintToChat(client, "Survivor Bot will auto get pill.");
			case 2:
			PrintToChat(client, "Survivor Bot will auto get adrenaline.");
			case 3:
			PrintToChat(client, "Survivor Bot will auto get pill or adrenaline.");
			default:
			PrintToChat(client, "Survivor Bot will not auto get pill or adrenaline.");
			
		}	
		if (GetConVarInt(SurvivorBotPrimaryWeapon) == 1)
		{
			PrintToChat(client, "Survivor Bot will auto get primary weapon.");
		}
		else
		{
			PrintToChat(client, "Survivor Bot will not auto get primary weapon.");
		}	
		if (GetConVarInt(SurvivorBotSecondaryWeapon) == 1)
		{
			PrintToChat(client, "Survivor Bot will auto get secondary weapon.");
		}
		else
		{
			PrintToChat(client, "Survivor Bot will not auto get secondary weapon.");
		}			
		if (GetConVarInt(SurvivorBotGrenade) == 1)
		{
			PrintToChat(client, "Survivor Bot will auto get grenade.");
		}
		else
		{
			PrintToChat(client, "Survivor Bot will not auto get grenade.");
		}	
		
	}
	PrintToChat(client, "[CheatBot]Have Fun:)");
	return Plugin_Continue;

}

public OnGameFrame()
{

	if (WeaponReloadCount > 0) {

		decl ent;

		for (new i = 0; i < WeaponReloadCount; i++)
		{
			ent = WeaponReload[i];
			if (IsValidEdict(ent))
			{
				decl String:entclass[65];
				GetEdictClassname(ent, entclass, sizeof(entclass));

				if (StrContains(entclass, "weapon") >= 0 || StrContains(entclass, "melee") >= 0)
				{
					new Float:Mul = GetConVarFloat(SurvivorBotWeaponSpeedMul);

					if (StrContains(entclass, "melee") >= 0) {

						Mul = GetConVarFloat(SurvivorBotMeleeSpeedMul);

					}

					new Float:ETime = GetGameTime();
					new Float:LTime;

					if (HasEntProp(ent, Prop_Send, "m_flPlaybackRate")) {
						SetEntPropFloat(ent, Prop_Send, "m_flPlaybackRate", Mul);
					}

					if (HasEntProp(ent, Prop_Send, "m_flNextPrimaryAttack")) {
						LTime = (GetEntPropFloat(ent, Prop_Send, "m_flNextPrimaryAttack") - ETime)*Mul;
						SetEntPropFloat(ent, Prop_Send, "m_flNextPrimaryAttack", LTime + ETime);
					}

					if (HasEntProp(ent, Prop_Send, "m_flNextSecondaryAttack")) {
						LTime = (GetEntPropFloat(ent, Prop_Send, "m_flNextSecondaryAttack") - ETime)*Mul;
						SetEntPropFloat(ent, Prop_Send, "m_flNextSecondaryAttack", LTime + ETime);
					}

					CreateTimer(LTime, NormalWeaponSpeed, ent);
				}
			}
		}

		WeaponReloadCount = 0;

	}
}

public Action:NormalWeaponSpeed(Handle:timer, any:ent)
{
	KillTimer(timer);
	timer = INVALID_HANDLE;

	if (IsValidEdict(ent))
	{
		decl String:entclass[65];
		GetEdictClassname(ent, entclass, sizeof(entclass));
		if (StrContains(entclass, "weapon") >= 0 || StrContains(entclass, "melee") >= 0)
		{
			if (HasEntProp(ent, Prop_Send, "m_flPlaybackRate")) {
				SetEntPropFloat(ent, Prop_Send, "m_flPlaybackRate", 1.0);
			}
		}
	}
	return Plugin_Handled;
}


public Action:PlayerSpawn(Handle:event, String:event_name[], bool:dontBroadcast)
{

	new target = GetClientOfUserId(GetEventInt(event, "userid"));

	if (IsFakeClient(target) && GetClientTeam(target) == TEAM_SURVIVORS) {

		if (HasEntProp(target, Prop_Data, "m_iMaxHealth") && HasEntProp(target, Prop_Data, "m_iHealth")) {
			SetEntProp(target, Prop_Data, "m_iMaxHealth", RoundToNearest(GetEntProp(target, Prop_Data, "m_iMaxHealth")*GetConVarFloat(SurvivorBotHealthMul)));
			SetEntProp(target, Prop_Data, "m_iHealth", RoundToNearest(GetEntProp(target, Prop_Data, "m_iHealth")*GetConVarFloat(SurvivorBotHealthMul)));
		}

		if (HasEntProp(target, Prop_Data, "m_flLaggedMovementValue")) {
			SetEntPropFloat(target, Prop_Data, "m_flLaggedMovementValue", GetEntPropFloat(target, Prop_Data, "m_flLaggedMovementValue")*GetConVarFloat(SurvivorBotMoveSpeedMul));
		}

		SetEntityGravity(target, GetConVarFloat(SurvivorBotGravity));

	}

	return Plugin_Continue;

}

public Action:WeaponFire(Handle:event, String:event_name[], bool:dontBroadcast)
{

	new target = GetClientOfUserId(GetEventInt(event, "userid"));

	if (IsFakeClient(target) && GetClientTeam(target) == TEAM_SURVIVORS) {


		new ent = GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon");
		decl String:entclass[65];
		GetEdictClassname(ent, entclass, sizeof(entclass));

		if (GameVersion > 1 && ent == GetPlayerWeaponSlot(target, 1) && StrContains(entclass, "melee",false) >= 0)
		{

			WeaponReload[WeaponReloadCount] = ent;
			WeaponReloadCount++;
		}
		else if (ent == GetPlayerWeaponSlot(target, 0) || (ent == GetPlayerWeaponSlot(target, 1) && StrContains(entclass, "melee",false) < 0))
		{

			WeaponReload[WeaponReloadCount] = ent;
			WeaponReloadCount++;

			if (GetConVarInt(SurvivorBotInfiniteAmmo) == 1) {

				if (HasEntProp(ent, Prop_Send, "m_iClip1")) {
					SetEntProp(ent, Prop_Send, "m_iClip1", GetEntProp(ent, Prop_Send, "m_iClip1") + 1);
				}

				/*
				if(HasEntProp(ent,Prop_Send,"m_iClip2")){
				SetEntProp(ent, Prop_Send, "m_iClip2", GetEntProp(ent, Prop_Send, "m_iClip2")+1);
				}
				*/
			}



		}

	}

	return Plugin_Continue;

}

stock GetSpecialAmmoTypeOfClient(client)
{
    new gunent = GetPlayerWeaponSlot(client, 0);
    if (IsValidEdict(gunent) && HasEntProp(gunent, Prop_Send, "m_upgradeBitVec"))
        return GetEntProp(gunent, Prop_Send, "m_upgradeBitVec");
    return 0;
}


SetWeaponUpgrades(client)
{
	if(GameVersion <= 1 || GetConVarInt(SurvivorBotLaserSight)<=0){return ;}
	
	new specialammo = GetSpecialAmmoTypeOfClient(client);
	/*
    if (specialammo & L4D2_WEPUPGFLAG_INCENDIARY) //1B 
    {
        
    }
    if (specialammo & L4D2_WEPUPGFLAG_EXPLOSIVE) // 10B
    {
        
    }
	*/
	//if (specialammo != 4)
		// 100B 100 & 100 = 100
    if (specialammo & L4D2_WEPUPGFLAG_LASER) {return ;}
	
	
	CheatCommand(client, "upgrade_add", "LASER_SIGHT");
	
}  

SetWeaponSpeicalAmmo(client)
{
	new specialammo = GetSpecialAmmoTypeOfClient(client);
	
	if(GameVersion <= 1 || ((specialammo & L4D2_WEPUPGFLAG_INCENDIARY)||(specialammo & L4D2_WEPUPGFLAG_EXPLOSIVE)) || GetConVarInt(SurvivorBotSpecialAmmo)<=0 ){return ;}
	
	if(GetURandomInt()%2==0){
	CheatCommand(client, "upgrade_add", "INCENDIARY_AMMO");
	}else{
	CheatCommand(client, "upgrade_add", "EXPLOSIVE_AMMO");
	}
	
}
/* Thanks for AtomicStryker address:http://forums.alliedmods.net/showthread.php?t=114210 */
stock CheatCommand(client, String:command[], String:arguments[]="")
{
	new userflags = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, flags);
	SetUserFlagBits(client, userflags);
}

getGameVersion(){

	decl String:game_name[64];
	GetGameFolderName(game_name, sizeof(game_name));
	if (StrEqual(game_name, "left4dead", false)){return 1;}
	if (StrEqual(game_name, "left4dead2", false)){return 2;}
	SetFailState("This plugin only supports Left 4 Dead Game!(1 or 2)");
	return 0;
	
}	

GiveItemsByCvars(client){

	if(GetPlayerWeaponSlot(client, 0) == -1){
	
	if(GetConVarInt(SurvivorBotPrimaryWeapon)==1){
	CheatCommand(client, "give", "pumpshotgun");	
	}

	}

	if(GameVersion > 1 && GetPlayerWeaponSlot(client, 1) == -1){
	
	if(GetConVarInt(SurvivorBotSecondaryWeapon)==1){
	CheatCommand(client, "give", "pistol_magnum");	
	}
	}
	
	if(GetPlayerWeaponSlot(client, 2) == -1){
	
	if(GetConVarInt(SurvivorBotGrenade)==1){
	CheatCommand(client, "give", "pipe_bomb");	
	}
	}
	
	

	if(GetPlayerWeaponSlot(client, 3) == -1){
	
		if(GetConVarInt(SurvivorBotHealItem)==1){
		
			CheatCommand(client, "give", "first_aid_kit"); //weapon_upgradepack_explosive  weapon_upgradepack_incendiary  first_aid_kit defibrillator 
		
		}
	
	}

	if(GetPlayerWeaponSlot(client, 4) == -1){
	
	switch(GetConVarInt(SurvivorBotExtraItem)){
	case 1:{
		
		CheatCommand(client, "give", "pain_pills");
		
	}
	case 2:{
		
		CheatCommand(client, "give", "adrenaline");
		
	}
	case 3:{
		
		if(GetURandomInt()%2==0){
		CheatCommand(client, "give", "pain_pills");
		}else{
		CheatCommand(client, "give", "adrenaline");
		}
		
	}
	}
	
	

	
	}
	
	
	SetWeaponUpgrades(client);
	SetWeaponSpeicalAmmo(client);
	

}

public Action:PlayerHurt(Handle:event, String:event_name[], bool:dontBroadcast) {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new mul = GetConVarFloat(SurvivorBotRefelectDamage);
	new damage = GetEventInt(event, "dmg_health");
	if (mul>0.0 && IsValidClient(client) && IsValidClient(attacker) && IsFakeClient(client) && GetClientTeam(client) == TEAM_SURVIVORS && GetClientTeam(attacker) != TEAM_SURVIVORS){
	DealDamage(client, attacker, RoundToNearest(mul * damage), 0, "damage_reflect");
	}
	
	
}

stock DealDamage(attacker=0,victim,damage,dmg_type=0,String:weapon[]="")
{
	if(IsValidEdict(victim) && damage>0)
	{
		new String:victimid[64];
		new String:dmg_type_str[32];
		IntToString(dmg_type,dmg_type_str,32);
		new PointHurt = CreateEntityByName("point_hurt");
		if(PointHurt)
		{
			Format(victimid, 64, "victim%d", victim);
			DispatchKeyValue(victim,"targetname",victimid);
			DispatchKeyValue(PointHurt,"DamageTarget",victimid);
			DispatchKeyValueFloat(PointHurt,"Damage",float(damage));
			DispatchKeyValue(PointHurt,"DamageType",dmg_type_str);
			if(!StrEqual(weapon,""))
			{
				DispatchKeyValue(PointHurt,"classname",weapon);
			}
			DispatchSpawn(PointHurt);
			if(IsValidClient(attacker))
				AcceptEntityInput(PointHurt, "Hurt", attacker);
			else 	
				AcceptEntityInput(PointHurt, "Hurt", -1);
				
			RemoveEdict(PointHurt);
		}
	}
}

stock bool IsValidClient(int client)
{
    if(client <= 0 || client > MaxClients)
        return false;
        
    if(!IsClientInGame(client) || !IsClientConnected(client))
        return false;
        
    return true;
}  
