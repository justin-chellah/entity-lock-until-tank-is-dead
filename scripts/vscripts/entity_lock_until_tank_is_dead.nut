Msg("Running entity_lock_until_tank_is_dead.nut script\n");

const ZOMBIE_TANK = 8;
const SF_BUTTON_LOCKED = 2048;	// Whether the button is initially locked.

local isLockedByDefault = false;
local debug = true;

function DebugPrint(string)
{
	if (debug)
	{
		printl(string);
	}
}

function OnPostSpawn()
{
	if (IsVersusMode())
	{
		if (NetProps.GetPropInt(self, "m_spawnflags") & SF_BUTTON_LOCKED)
		{
			isLockedByDefault = true;
		}

		self.ConnectOutput("OnOpen", "OnUsed");
		self.ConnectOutput("OnClose", "OnUsed");
		self.ConnectOutput("OnPressed", "OnUsed");
	}
}

function OnUsed()
{
	self.DisconnectOutput("OnOpen", "OnUsed");
	self.DisconnectOutput("OnClose", "OnUsed");
	self.DisconnectOutput("OnPressed", "OnUsed");

	delete this["InputLock"];
	delete this["InputUnlock"];
}

function CheckLock()
{
	if (NetProps.GetPropInt(self, "m_bLocked"))
	{
		return false;
	}

	if (isLockedByDefault)
	{
		return false;
	}

	DebugPrint("Attempting to lock entity");

	DoEntFire("!self", "Lock", "", 0, self, self);

	local classname = self.GetClassname();

	if (classname == "func_button_timed")
	{
		local activator = NetProps.GetPropEntity(self, "m_hActivator");

		if (activator)
		{
			// Stop player's use action
			// DoEntFire("!self", "Disable", "", 0, self, self);
			// DoEntFire("!self", "Enable", "", 0.1, self, self);

			NetProps.SetPropInt(activator, "m_iCurrentUseAction", 0);
			NetProps.SetPropEntity(activator, "m_useActionTarget", null);
		}
	}

	return true;
}

function CheckUnlock()
{
	if (!NetProps.GetPropInt(self, "m_bLocked"))
	{
		return false;
	}

	if (isLockedByDefault)
	{
		return false;
	}

	DebugPrint("Attempting to unlock entity");

	DoEntFire("!self", "Unlock", "", 0, self, self);

	return true;
}

function IsTankInPlay(playerToIgnore = null)
{
	local player = null;

	while (player = Entities.FindByClassname(player, "player"))
	{
		if (player == playerToIgnore)
		{
			continue;
		}

		if (player.GetZombieType() == ZOMBIE_TANK && !player.IsIncapacitated() && !player.IsDead() && !player.IsDying())
		{
			return true;
		}
	}

	return false;
}

function InputUnlock()
{
	isLockedByDefault = false;

	if (IsTankInPlay())
	{
		DebugPrint("Won't unlock entity because Tank is in play!");

		return false;
	}

	DebugPrint("InputUnlock fired");

	return true;
}

function InputLock()
{
	if (!IsTankInPlay())
	{
		DebugPrint("Won't lock entity because there is no Tank in play!");

		return false;
	}

	DebugPrint("InputLock fired");

	return true;
}

function IsVersusMode()
{
	return Director.GetGameMode() == "versus";
}

function OnGameEvent_tank_spawn(params)
{
	if (IsVersusMode())
	{
		local player = GetPlayerFromUserID(params.userid);

		CheckLock();
	}
}

function OnGameEvent_player_death(params)
{
	if (IsVersusMode() && "userid" in params)
	{
		local player = GetPlayerFromUserID(params.userid);

		if (!IsTankInPlay(player))
		{
			CheckUnlock();
		}
	}
}

function OnGameEvent_player_disconnect(params)
{
	if (IsVersusMode() && "userid" in params)
	{
		local player = GetPlayerFromUserID(params.userid);

		if (player && player.GetZombieType() == ZOMBIE_TANK && !IsTankInPlay(player))
		{
			CheckUnlock();
		}
	}
}