stock ExecuteNOPAction(playerid)
{
	new string[128];
	new newcar = GetPlayerVehicleID(playerid);
	if(NOPTrigger[playerid] >= MAX_NOP_WARNINGS) { return 1; }
	NOPTrigger[playerid]++;
	RemovePlayerFromVehicle(playerid);
	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);
	SetPlayerPos(playerid, X, Y, Z+2);
	defer NOPCheck(playerid);
	if(NOPTrigger[playerid] > 1)
	{
		new sec = (NOPTrigger[playerid] * 5000)/1000-1;
		format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) may be NOP hacking - restricted vehicle (model %d) for %d seconds.", GetPlayerNameEx(playerid), playerid, GetVehicleModel(newcar),sec);
		ABroadCast(COLOR_YELLOW, string, 2);
	}
	return 1;
}

stock ExecuteHackerAction( playerid, weaponid )
{
	if(!gPlayerLogged{playerid}) { return 1; }
	if(PlayerInfo[playerid][pTut] == 0) { return 1; }
	if(playerTabbed[playerid] >= 1) { return 1; }
	if(GetPVarInt(playerid, "IsInArena") >= 0) { return 1; }

	new String[ 128 ], WeaponName[ 128 ];
	GetWeaponName( weaponid, WeaponName, sizeof( WeaponName ) );

	format( String, sizeof( String ), "{AA3333}AdmWarning{FFFF00}: %s (ID %d) may possibly be weapon hacking (%s).", GetPlayerNameEx(playerid), playerid, WeaponName );
	ABroadCast( COLOR_YELLOW, String, 2 );
	format(String, sizeof(String), "%s(%d) (ID %d) may possibly be weapon hacking (%s)", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), playerid, WeaponName);
	Log("logs/hack.log", String);

	return 1;
}

forward sobeitCheck(playerid);
public sobeitCheck(playerid)
{
	if(GetPVarInt(playerid, "JailDelay") == 0)
	{
	    if(PlayerInfo[playerid][pJailTime] > 0)
		{
	        SetTimerEx("sobeitCheck", 1000, 0, "i", playerid);
	        SetPVarInt(playerid, "JailDelay", 1);
	        return 1;
	    }
	}

	DeletePVar(playerid, "JailDelay");
    if(IsPlayerFrozen[playerid] == 1)
	{
        new Float:hX, Float:hY, Float:hZ, Float:pX, Float:pY, Float:pZ, Float:cX, Float:cY, Float:cZ, Float:cX1, Float:cY1, Float:cZ1;
        GetPlayerCameraFrontVector(playerid, cX1, cY1, cZ1);
		GetPlayerPos(playerid, cX, cY, cZ);
        hX = GetPVarFloat(playerid, "FrontVectorX");
        hY = GetPVarFloat(playerid, "FrontVectorY");
        hZ = GetPVarFloat(playerid, "FrontVectorZ");
        pX = GetPVarFloat(playerid, "PlayerPositionX");
        pY = GetPVarFloat(playerid, "PlayerPositionY");
        pZ = GetPVarFloat(playerid, "PlayerPositionZ");

        if(pX != cX && pY != cY && pZ != cZ && hX != cX1 && hY != cY1 && hZ != cZ1)
        {
            SendClientMessageEx(playerid, COLOR_RED, "You have failed the player account check, please relog and try again!");
            IsPlayerFrozen[playerid] = 0;
            DeletePVar(playerid,"FrontVectorX");
            DeletePVar(playerid,"FrontVectorY");
            DeletePVar(playerid,"FrontVectorZ");
            DeletePVar(playerid,"PlayerPositionX");
            DeletePVar(playerid,"PlayerPositionY");
            DeletePVar(playerid,"PlayerPositionZ");
            SetTimerEx("KickEx", 1000, 0, "i", playerid);
            return 1;
        }
	}

	new Float:aX, Float:aY, Float:aZ, szString[128];
	GetPlayerCameraFrontVector(playerid, aX, aY, aZ);
	#pragma unused aX
	#pragma unused aY

	if(aZ < -0.7)
	{
		new IP[32];
		GetPlayerIp(playerid, IP, sizeof(IP));
		TogglePlayerControllable(playerid, true);

	 	if(PlayerInfo[playerid][pSMod] == 1 || PlayerInfo[playerid][pAdmin] == 1)
 		{
 		    format(szString, sizeof(szString), "SELECT `Username` FROM `accounts` WHERE `AdminLevel` > 1 AND `Disabled` = 0 AND `IP` = '%s'", GetPlayerIpEx(playerid));
 		    mysql_function_query(MainPipeline, szString, true, "CheckAccounts", "i", playerid);
       	}
		else {
		    format(szString, sizeof(szString), "INSERT INTO `sobeitkicks` (sqlID, Kicks) VALUES (%d, 1) ON DUPLICATE KEY UPDATE Kicks = Kicks + 1", GetPlayerSQLId(playerid));
			mysql_function_query(MainPipeline, szString, false, "OnQueryFinish", "ii", SENDDATA_THREAD, playerid);

			SendClientMessageEx(playerid, COLOR_RED, "The hacking tool 's0beit' is not allowed on this server, please uninstall it.");
   			format(szString, sizeof(szString), "%s(%d) (IP: %s) has logged into the server with s0beit installed.", GetPlayerNameEx(playerid), GetPlayerSQLId(playerid), IP);
   			Log("logs/sobeit.log", szString);
   			IsPlayerFrozen[playerid] = 0;
    		SetTimerEx("KickEx", 1000, 0, "i", playerid);
     	}

	}
	
	if(playerTabbed[playerid] > 2) { SendClientMessageEx(playerid, COLOR_RED, "You have failed the account check, please relog."), SetTimerEx("KickEx", 1000, 0, "i", playerid); }

	if(PlayerInfo[playerid][pVW] > 0 || PlayerInfo[playerid][pInt] > 0) HideNoticeGUIFrame(playerid);
	sobeitCheckvar[playerid] = 1;
	sobeitCheckIsDone[playerid] = 1;
	IsPlayerFrozen[playerid] = 0;
	TogglePlayerControllable(playerid, true);
 	return 1;
}

//Dom
forward Anti_Rapidfire();
public Anti_Rapidfire()
{
	new string[128];
	foreach(new i: Player) 
	{
		new weaponid = GetPlayerWeapon(i);
		if(((weaponid == 24 || weaponid == 25 || weaponid == 26) && PlayerShots[i] > 10)/* || (weaponid == 31 && PlayerShots[i] > 20)*/)
		{
			format(string, sizeof(string), "%s(%d) (%d): %d shots in 1 second -- Weapon ID: %d", GetPlayerNameEx(i), i, GetPVarInt(i, "pSQLID"), PlayerShots[i], weaponid);
			Log("logs/rapid.log", string);

			SetPVarInt(i, "MaxRFWarn", GetPVarInt(i, "MaxRFWarn")+1);
			format(string, sizeof(string), "{AA3333}AdmWarning{FFFF00}: %s (ID: %d) may be rapidfire hacking. %d/%d warnings", GetPlayerNameEx(i), i, GetPVarInt(i, "MaxRFWarn"), MAX_RF_WARNS);
			ABroadCast(COLOR_YELLOW, string, 2);
			if(GetPVarInt(i, "MaxRFWarn") >= MAX_RF_WARNS)
			{
				format(string, sizeof(string), "AdmCmd: %s has been banned, reason: Rapidfire Hacking. %d/%d warnings", GetPlayerNameEx(i), GetPVarInt(i, "MaxRFWarn"), MAX_RF_WARNS);
				ABroadCast(COLOR_LIGHTRED, string, 2);
				DeletePVar(i, "MaxRFWarn");
				format(string, sizeof(string), "AdmCmd: %s(%d) (IP:%s) was banned, reason: Rapidfire Hacking.", GetPlayerNameEx(i), GetPlayerSQLId(i), GetPlayerIpEx(i));
				PlayerInfo[i][pBanned] = 3;
				Log("logs/ban.log", string);
				SystemBan(i, "[System] (Rapidfire Hacking)");
				MySQLBan(GetPlayerSQLId(i), GetPlayerIpEx(i), "Rapidfire Hacking", 1, "System");
				Kick(i);
				TotalAutoBan++;
			}
		}
		PlayerShots[i] = 0;
	}
	return 1;
}

forward LoginCheckEx(i);
public LoginCheckEx(i)
{
	new ok = 0, count = 0, Float: pos[3], string[128];
	if(gPlayerLogged{i} == 0 && IsPlayerConnected(i))
	{
		GetPlayerPos(i, pos[0], pos[1], pos[2]);
		for(new x; x < sizeof(JoinCameraPosition); x++)
		{
			if(pos[0] != JoinCameraPosition[x][0] && pos[1] != JoinCameraPosition[x][1] && pos[2] != JoinCameraPosition[x][2] && (count == 8))
			{
				format(string, sizeof(string), "%s(%d) [%s] has moved from the login screen position.", GetPlayerNameEx(i), GetPlayerSQLId(i), GetPlayerIpEx(i));
				Log("logs/security.log", string);
				SendClientMessage(i, COLOR_WHITE, "SERVER: You have moved while being in the login screen!");
				ShowPlayerDialog(i, -1, DIALOG_STYLE_MSGBOX, "", "", "", "");
				SetTimerEx("KickEx", 1000, 0, "i", i);
				ok = 1;
			}
			count++;
		}
		
		if(ok == 0)
		{
			SetTimerEx("LoginCheckEx", 5000, 0, "i", i);
		}
	}
	return true;
}

stock CheckServerAd(szInput[]) {

	new
		iCount,
		iPeriod,
		iPos,
		iChar,
		iColon;

	while((iChar = szInput[iPos++])) {
		if('0' <= iChar <= '9') iCount++;
		else if(iChar == '.') iPeriod++;
		else if(iChar == ':') iColon++;
	}
	if(iCount >= 7 && iPeriod >= 3 && iColon >= 1) {
		return 1;
	}

	return 0;
}

CMD:hackwarnings(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2) return 1;
	new Float: health,
		Float: rhealth,
		Float: armor,
		Float: rarmor;
	
	szMiscArray[0] = 0;

	foreach(Player, i)
	{
		if(playerTabbed[i] != 0) continue;
		GetPlayerHealth(i, health);
		GetHealth(i, rhealth);
		GetPlayerArmour(i, armor);
		GetArmour(i, rarmor);
		if(health > rhealth)
		{
			format(szMiscArray, sizeof(szMiscArray), "%s (ID: %i, Level: %d) - Health - Recorded: %f - Current: %f", GetPlayerNameEx(i), i, PlayerInfo[i][pLevel], rhealth, health);
			SendClientMessage(playerid, COLOR_WHITE, szMiscArray);
		}
		if(armor > rarmor)
		{
			format(szMiscArray, sizeof(szMiscArray), "%s (ID: %i, Level: %d) - Armor - Recorded: %f - Current: %f", GetPlayerNameEx(i), i, PlayerInfo[i][pLevel], rarmor, armor);
			SendClientMessage(playerid, COLOR_WHITE, szMiscArray);
		}
	}
	return 1;
}
