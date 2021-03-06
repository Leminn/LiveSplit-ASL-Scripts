/*I have a very basic knowledge about C# and ASL in general so this splitter is pretty basic and probably shouldn't be taken as an example.*/

state("srb2win", "2.1.25 - 64 bits")
{
	int start : 0x13DFDC8;
	int split : 0x388280;
	int level : 0x1BEBE4;
	int framecounter : 0x13D2850;
	int exitCountdown : 0x13D2830;
	int TBonus : 0x388310;
	int RBonus : 0x388324;
	int LBonus : 0x388330;
	int TA : 0x37B658;
	int reset : 0x13D5DC8;
	int emblem : 0x23E3E4;
	int emerald : 0x13D1C8C;
	string10 mod_id : 0x37B680;
	byte scr_temple : 0x387D9A;
	int sugoiBoss : 0x013D2760, 0x8, 0xF0, 0x0, 0xE0;
	int isWatching : 0x13D26D8;
}

state("srb2win", "2.1.25 - 32 bits")
{
	int start : 0x13914AC;
	int split : 0x340C40;
	int level : 0x194F7C;
	int framecounter : 0x138630C;
	int exitCountdown : 0x13862EC;
	int TBonus : 0x340CD0;
	int RBonus : 0x340CE4;
	int LBonus : 0x340CF0;
	int TA : 0x334A4C;
	int reset : 0x138959C;
	int emblem : 0x1FDE28;
	int emerald : 0x1385CA0;
	string10 mod_id : 0x334A80;
	byte scr_temple : 0x34077A;
	int sugoiBoss : 0x01391420, 0x38, 0x0, 0x7C, 0x0, 0x90;
	int isWatching : 0x13861E4;
}

state("srb2win", "2.2.2 - 64 bits")
{
	int start : 0x450ABC0;
	int split : 0x4586C0;
	int level : 0x44BA28;
	int framecounter : 0x55F668C;
	int exitCountdown : 0x55F6668;
	int TBonus : 0x458770;
	int RBonus : 0x458784;
	int LBonus : 0x458790;
	int TA : 0x44BA18;
	int emerald : 0x55FB470;
	string4 music : 0x45063E2;
	int file : 0x2483A4;
	int isWatching : 0x55FBD84;
}

state("srb2win", "2.2.2 - 32 bits")
{
	int start : 0x444E208;
	int split : 0x3E5120;
	int level : 0x3D8EDC;
	int framecounter : 0x5535F44;
	int exitCountdown : 0x5535F20;
	int TBonus : 0x3E51B0;
	int RBonus : 0x3E51C4;
	int LBonus : 0x3E51D0;
	int TA : 0x3D8ECC;
	int emerald : 0x5535380;
	string4 music : 0x44490F4;
	int file : 0x22D1C4;
	int isWatching : 0x5535940;
}

init
{
	if (modules.First().ModuleMemorySize == 22024192) version = "2.1.25 - 64 bits";
	if (modules.First().ModuleMemorySize == 21602304) version = "2.1.25 - 32 bits";
	if (modules.First().ModuleMemorySize == 98971648) version = "2.2.2 - 32 bits";
	if (modules.First().ModuleMemorySize == 99946496) version = "2.2.2 - 64 bits";

	if(version == "2.2.2 - 64 bits" || version == "2.2.2 - 32 bits")
	{
		vars.branch = 2;
	}
	if(version == "2.1.25 - 64 bits" || version == "2.1.25 - 32 bits")
	{
		vars.branch = 1;
	}
	if(version == "")
	{
		vars.branch = 0;
	}

	if(vars.branch == 0)
	{
		var result = MessageBox.Show(timer.Form,
		"Your game version is not supported by this script version\n"
		+ "You have to use the good version of the game\n"
		+ "This script version works with SRB2 V2.1.25 and V2.2.2\n"
		+ "\nClick Yes to open the game update page.",
		"SRB2 Livesplit Script",
		MessageBoxButtons.YesNo,
		MessageBoxIcon.Information);
		if (result == DialogResult.Yes)
		{
			Process.Start("https://www.srb2.org/download");
		}
	}
	refreshRate = 35;
	vars.OSplit = 0;
	vars.sugoUndo = 0;
}

startup
{
  vars.timerModel = new TimerModel { CurrentState = timer };
	vars.dummy = 0;
	vars.splitDelay = 0;
	vars.totalTime = 0;
	vars.line = "";
	vars.prevLine = "";
	vars.ESplit = 0;
	settings.Add("TA_S", true, "Start on Record Attack");
	settings.Add("split", true, "Split time");
	settings.Add("finnish", false, "Finish sign", "split");
	settings.Add("a_clear", false, "Act clear appears", "split");
	settings.Add("s_b_clear", false, "Bonuses clear", "split");
	settings.Add("loading", false, "Next level Loading", "split");
	settings.Add("CEZR", false, "(2.2 only) Split at the bridge falling section of CEZ1");
	settings.Add("emerald", false, "Split on emerald tokens");
	settings.Add("resetS", false, "(2.2 only) Reset even if playing on a file");
	settings.Add("emblem", false, "(2.1 only) Split on emblems (hover here please)");
	settings.Add("emblem2", false, "(2.2 only) Split on emblems using an external program (hover here please)");
	settings.Add("temple", false, "(2.1 only) (Mystic Realm) Temple split");
	settings.Add("sugo_WSplit", false, "(2.1 only) (SUGOI 1/2/3) Teleport Station split");
	settings.SetToolTip("split","You shouldn't choose more than 1 split timiing");
	settings.SetToolTip("finnish","Splits when you cross the finish sign");
	settings.SetToolTip("a_clear","Splits when the act clear screen appears");
	settings.SetToolTip("s_b_clear", "Splits when your bonuses got added to the total");
	settings.SetToolTip("loading","Splits when the transition to the next level begins");
	settings.SetToolTip("resetS","Disabled by default to avoid accidental timer resets");
	settings.SetToolTip("emblem","Splits on hidden emblems, not on the record attack ones. At every restart of the game, you'll need to take one first emblem then it'll start to split");
	settings.SetToolTip("emblem2","Splits on hidden emblems, not on the record attack ones. You need to use Ors emblem display program in order to work");
	settings.SetToolTip("temple","Splits when activating a temple");
	settings.SetToolTip("sugo_WSplit","Splits when you warp into a level from the Teleport Station");
}

start
{
	vars.dummy = 0;
	vars.OSplit = 0;
	vars.ESplit = 0;
	vars.splitDelay = 0;
	vars.sugoUndo = 0;
	vars.totalTime = 0;
	if(current.isWatching == 0)
	{
		if(settings["TA_S"])
		{
			return (current.start == 1 && current.start != old.start);
		}
		else
		{
			return (current.start == 1 && current.start != old.start && current.TA == 0);
		}
	}
}

update
{
	//print("Executable size is : " + modules.First().ModuleMemorySize);
	//print("vars.branch = " + vars.branch);
	int timeToAdd = Math.Max(0, current.framecounter-old.framecounter);
	if(current.framecounter-old.framecounter < 15)
	{
		vars.totalTime += timeToAdd;
	}

	if(current.split == 0 && vars.OSplit == 1)
	{
		vars.OSplit = 0;
	}

	if(vars.branch == 1)
	{
		if (current.mod_id == "SUBARASHII" && current.level == 101)
		{
			if (settings["finnish"] && current.exitCountdown < 99 && current.exitCountdown != old.exitCountdown && vars.sugoUndo == 0)
			{
				vars.timerModel.UndoSplit();
				vars.sugoUndo = 1;
			}
			if (settings["a_clear"] && current.exitCountdown == 1 && old.exitCountdown == 1 && vars.sugoUndo == 0)
			{
				vars.timerModel.UndoSplit();
				vars.sugoUndo = 1;
			}
		}

		if (current.mod_id == "SUBARASHII" && current.level == 100)
		{
			vars.sugoUndo = 0;
		}


		if (current.mod_id == "KIMOKAWAII" && current.level == 1035)
		{
			if (settings["finnish"] && current.exitCountdown < 99 && current.exitCountdown != old.exitCountdown && vars.sugoUndo == 0)
			{
				vars.timerModel.UndoSplit();
				vars.sugoUndo = 1;
			}
			if (settings["a_clear"] && current.exitCountdown == 1 && old.exitCountdown == 1 && vars.sugoUndo == 0)
			{
				vars.timerModel.UndoSplit();
				vars.sugoUndo = 1;
			}
		}
		if (current.mod_id == "KIMOKAWAII" && current.level == 100)
		{
			vars.sugoUndo = 0;
		}

	}
	if (vars.branch == 2 && settings["emblem2"])
	{
		vars.splitDelay = Math.Max(0, vars.splitDelay-1);
		if(File.Exists("Components\\SRB2 Emblems.txt"))
		{
			string[] lines = File.ReadAllLines("Components\\SRB2 Emblems.txt");
			vars.line = lines[0];
			if (vars.line != vars.prevLine)
			{
				vars.ESplit = 1;
				vars.splitDelay = 10;
			}
			vars.prevLine = vars.line;
			if (vars.splitDelay == 0)
			{
				vars.ESplit = 0;
			}
		}
	}
}

split
{
	if (vars.branch == 1)
	{
		if(settings["sugo_WSplit"])
		{
			if((current.mod_id == "SUGOI V1.2" || current.mod_id == "SUBARASHII" || current.mod_id == "KIMOKAWAII") && old.level == 100 && current.level != old.level)
			{
				return true;
			}
		}
		if(current.mod_id == "SUGOI V1.2" && current.level == 28 && current.sugoiBoss == 0 && old.sugoiBoss == 1)
		{
			return true;
		}

		if(settings["temple"] && current.mod_id == "4.6" && current.scr_temple != old.scr_temple && current.scr_temple > 1)
		{
			return true;
		}

		if(settings["loading"] && current.level != old.level && old.level >= 50 && old.level <= 57)
		{
			return true;
		}
		if(settings["emblem"] && current.emblem == -1 && old.emblem == -2)
		{
			return true;
		}

		if ((current.mod_id == "" && current.level == 25) || (current.mod_id == "4.6" && current.level == 122 || current.level == 134))
		{
			if(old.exitCountdown == 0 && current.exitCountdown != 0)
			{
				return true;
			}
		}
		else
		{
			if(settings["finnish"] && old.exitCountdown == 0 && current.exitCountdown != 0)
			{
				return true;
			}
			if(settings["a_clear"] && old.exitCountdown != 1 && current.exitCountdown == 1)
			{
				return true;
			}
			if(settings["s_b_clear"] && current.split == 1 && current.TBonus == 0 && current.RBonus == 0 && vars.OSplit == 0)
			{
				vars.OSplit = 1;
				return true;
			}
			if(settings["loading"] && current.split == 0 && old.split == 1)
			{
				return true;
			}
		}
	}

	if (vars.branch == 2)
	{
		if(settings["CEZR"] && current.music == "CEZR" && current.music != old.music)
		{
			return true;
		}
		if(settings["loading"] && current.exitCountdown == 0 && old.exitCountdown > 0 && old.level >= 50 && old.level <= 73)
		{
			return true;
		}
		if(current.level == 25 || current.level == 26 || current.level == 27)
		{
			if(old.exitCountdown > 1 && current.exitCountdown <= 1)
			{
				return true;
			}
		}
		else
		{
			if(settings["finnish"] && old.exitCountdown == 0 && current.exitCountdown != 0)
			{
				return true;
			}
			if(settings["a_clear"] && old.exitCountdown != 1 && current.exitCountdown == 1)
			{
				return true;
			}
			if(settings["s_b_clear"] && current.split == 1 && current.TBonus == 0 && current.RBonus == 0 && vars.OSplit == 0)
			{
				vars.OSplit = 1;
				return true;
			}
			if(settings["loading"] && current.split == 0 && old.split == 1)
			{
				return true;
			}
		}
		if(settings["emblem2"])
		{
			if (vars.ESplit == 1 && current.framecounter != old.framecounter)
			{
				vars.ESplit = 0;
				return true;
			}
		}
	}

	if(settings["s_b_clear"] && current.LBonus == 0 && old.LBonus != 0)
	{
		return true;
	}
	if(settings["emerald"] && current.emerald > old.emerald)
	{
		return true;
	}
}

reset
{
	if(vars.branch == 1 && current.reset == 0 && current.reset != old.reset)
	{
		return true;
	}
	if(vars.branch == 2 && current.level == 99 && current.level != old.level)
	{
		if (settings["resetS"])
		{
			return true;
		}
		else if (current.file == 0)
		{
			return true;
		}
	}
}

gameTime
{
	return TimeSpan.FromMilliseconds(vars.totalTime*28.5714285714);
}

isLoading
{
	return true;
}
