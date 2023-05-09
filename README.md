# [L4D2] Entity Lock Until Tank Is Dead
This is a VScript that locks doors and buttons in Versus when the Tank has spawned and unlocks them after the Tank has been killed (or removed from the game). It was intended for scripted Director events so that survivors couldn't bypass them before the Tank was gone.

# Installation
- Drag and drop the `scripts` folder in your `left4dead2` folder

# Hammer Editor Example
![Screenshot_1](https://user-images.githubusercontent.com/26851418/236985804-09b6a61d-7d56-4fd8-87eb-cae58bfdd479.jpg)

# Stripper: Source Example
If you're running a SourceMod server, you'll need to download [Stripper: Source](https://www.bailopan.net/stripper/).

The following code will prevent survivors from using the generator to start the finale on Crash Course `(c9m2_lots.cfg)` when the Tank spawns:
```
modify:
{
	match:
	{
		"targetname" "finaleswitch_initial"
	}

	insert:
	{
		"vscripts" "entity_lock_until_tank_is_dead"
	}
}
```

# Docs
- [L4D2 Vscripts](https://developer.valvesoftware.com/wiki/L4D2_Vscripts)
