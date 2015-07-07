#include <sourcemod>
#include <sdktools>
#include <cstrike>

public Plugin:myinfo = {
	name = "[CS]Time Limit Enforcer",
	author = "Roy (Christian Deacon)",
	description = "Time limit enforcer using option two.",
	version = "1.0",
	url = "TheDevelopingCommunity.com"
};

// ConVars
new Handle:g_hEnabled = INVALID_HANDLE;
new Handle:g_hTag = INVALID_HANDLE;

// ConVar values
new bool:bEnabled;
new String:sTag[MAX_NAME_LENGTH];

// Other values
new bool:bDebug = false;

public OnPluginStart() {
	// ConVars
	g_hEnabled = CreateConVar("sm_tle_enabled", "1", "Enable \"Time Limit Enforcer\"?");
	g_hTag = CreateConVar("sm_tle_tag", "TLE", "The tag that displays in every message sent from this plugin! Example: \"[tagname] The map is changing in X seconds!\"");
	
	// Make sure the game is CS:GO or CS:S.
	if(GetEngineVersion() != Engine_CSGO && GetEngineVersion() != Engine_CSS) {
		SetFailState("This plugin only supports CS:GO and CS:S.");
	}
	
	// Commands
	RegAdminCmd("sm_endround", Command_EndRound, ADMFLAG_ROOT);
	
	// Get these values on Plugin Start as well.
	bEnabled = GetConVarBool(g_hEnabled);
	GetConVarString(g_hTag, sTag, sizeof(sTag));
	
	// Config
	AutoExecConfig(true, "sm_tle");
}

// The command first!
public Action:Command_EndRound(client, args) {
	EndGame();
	return Plugin_Handled;
}

// On Map Start
public OnMapStart() {
	// Start the main timer.
	if (bEnabled) {
		if (bDebug) {
			PrintToServer("[%s] Started the timer.", sTag);
			LogMessage("[%s] Started the timer", sTag);
		}
		CreateTimer(1.0, Timer_CheckTimer, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	}
}

// The Check Timer
public Action:Timer_CheckTimer(Handle:timer) {
	// Get the values we need
	new Handle:h_hTmp = FindConVar("mp_timelimit");
	new iTimeLimit = GetConVarInt(h_hTmp);
	
	if (h_hTmp != INVALID_HANDLE) {
		h_hTmp = INVALID_HANDLE;
	}
	
	if (iTimeLimit > 0) {
		new iTimeLeft;
		GetMapTimeLeft(iTimeLeft);
		switch (iTimeLeft) {
			// Now it's time to do the warnings!
			case 1800: 
				PrintToChatAll("[%s] 30 minutes remaining",sTag);
			case 1200: 
				PrintToChatAll("[%s] 20 minutes remaining",sTag);
			case 600: 
				PrintToChatAll("[%s] 10 minutes remaining",sTag);
			case 300: 
				PrintToChatAll("[%s] 5 minutes remaining",sTag);
			case 120: 
				PrintToChatAll("[%s] 2 minutes remaining",sTag);
			case 60: 
				PrintToChatAll("[%s] 60 seconds remaining",sTag); 
			case 30: 
				PrintToChatAll("[%s] 30 seconds remaining",sTag);
			case 15: 
				PrintToChatAll("[%s] 15 seconds remaining",sTag);			
			case -1: 
				PrintToChatAll("[%s] 3..",sTag);
			case -2: 
				PrintToChatAll("[%s] 2..",sTag);
			case -3: 
				PrintToChatAll("[%s] 1..",sTag);		
			case -4:
				EndGame();
		}
	}
}

// The end game function! This is the interesting part.
public EndGame() {
	// For CS:GO/CS:S, this is very simple!
	// Set "mp_ignore_round_win_conditions" to 0.
	ServerCommand("mp_ignore_round_win_conditions 0");
	
	// Now terminate the round!
	CS_TerminateRound(1.0, CSRoundEnd_Draw, true);
	
	// Now print a message!
	decl String:sNextMap[MAX_NAME_LENGTH];
	GetNextMap(sNextMap, sizeof(sNextMap));
	PrintToChatAll("[%s] Map ended! Next map is %s!", sTag, sNextMap);
}
