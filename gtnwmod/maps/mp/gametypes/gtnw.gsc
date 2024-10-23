#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\killstreaks\_airdrop;
/*
	Global Thermonuclear War (HIWMTB) by @qhnxs
	Credit me if you modify or use this code in your own projects!
*/

/*QUAKED mp_ctf_spawn_axis (0.75 0.0 0.5) (-16 -16 0) (16 16 72)
Axis players spawn away from enemies and near their team at one of these positions.*/

/*QUAKED mp_ctf_spawn_allies (0.0 0.75 0.5) (-16 -16 0) (16 16 72)
Allied players spawn away from enemies and near their team at one of these positions.*/

/*QUAKED mp_ctf_spawn_axis_start (1.0 0.0 0.5) (-16 -16 0) (16 16 72)
Axis players spawn away from enemies and near their team at one of these positions at the start of a round.*/

/*QUAKED mp_ctf_spawn_allies_start (0.0 1.0 0.5) (-16 -16 0) (16 16 72)
Allied players spawn away from enemies and near their team at one of these positions at the start of a round.*/

main()
{
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	registerTimeLimitDvar( level.gameType, 3, 0, 1440 );
	registerScoreLimitDvar( level.gameType, 1, 0, 10000 );
	registerRoundLimitDvar( level.gameType, 1, 0, 30 );
	registerWinLimitDvar( level.gameType, 1, 0, 10 );
	registerRoundSwitchDvar( level.gameType, 0, 0, 30 );
	registerNumLivesDvar( level.gameType, 1, 0, 10 );
	registerHalfTimeDvar( level.gameType, 0, 0, 1 );
	
	level.teamBased = true;
	level.onPrecacheGameType = ::onPrecacheGameType;
	level.onStartGameType = ::onStartGameType;
	level.getSpawnPoint = ::getSpawnPoint;
	level.onDeadEvent = ::onDeadEvent;
	level.initGametypeAwards = ::initGametypeAwards;
	level.onTimeLimit = ::onTimeLimit;
	level.onNormalDeath = ::onNormalDeath;
	level.gtnw = true;
	
	game["dialog"]["gametype"] = "gtw";
	
	if ( getDvarInt( "g_hardcore" ) )
		game["dialog"]["gametype"] = "hc_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "camera_thirdPerson" ) )
		game["dialog"]["gametype"] = "thirdp_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "scr_diehard" ) )
		game["dialog"]["gametype"] = "dh_" + game["dialog"]["gametype"];
	else if (getDvarInt( "scr_" + level.gameType + "_promode" ) )
		game["dialog"]["gametype"] = game["dialog"]["gametype"] + "_pro";
	
	game["dialog"]["offense_obj"] = "obj_destroy";
	game["dialog"]["defense_obj"] = "obj_defend";
}

nukeLocation()
{
	currentMap = getDvar("mapname");
	
	if (currentMap == "mp_afghan") // Afghan
	{
		return (1222, 1346, 78);
	}
	else if (currentMap == "mp_complex") // Bailout
	{
		return (286, -3025, 646);
	}
	else if (currentMap == "mp_abandon") // Carnival
	{
		return (1376, 123, -60);
	}
	else if (currentMap == "mp_crash") // Crash
	{
		return (610, 505, 130);
	}
	else if (currentMap == "mp_derail") // Derail
	{
		return (1320, -284, 128.8);
	}
	else if (currentMap == "mp_estate") // Estate
	{
		return (-609, 2321, -107);
	}
	else if (currentMap == "mp_favela") // Favela
	{
		return (64, -32, -6);
	}
	else if (currentMap == "mp_fuel2") // Fuel
	{
		return (720, -325, -7);
	}
	else if (currentMap == "mp_highrise") // Highrise
	{
		return (-1173, 6468, 2774);
	}
	else if (currentMap == "mp_invasion") // Invasion
	{
		return (-1208, -2310, 264);
	}
	else if (currentMap == "mp_checkpoint") // Karachi
	{
		return (114, 74, 33);
	}
	else if (currentMap == "mp_overgrown") // Overgrown
	{
		return (201, -2166, -367);
	}
	else if (currentMap == "mp_quarry") // Quarry
	{
		return (-3913, 623, -322);
	}
	else if (currentMap == "mp_rundown") // Rundown
	{
		return (441.5, -81, 16);
	}
	else if (currentMap == "mp_rust") // Rust
	{
		return (391.5, 1262.6, -239.7);
	}
	else if (currentMap == "mp_compact") // Salvage
	{
		return (1160, 1120, 10);
	}
	else if (currentMap == "mp_boneyard") // Scrapyard
	{
		return (684.1, 394.3, -124.5);
	}
	else if (currentMap == "mp_nightshift") // Skidrow
	{
		return (-347, 113, 175);
	}
	else if (currentMap == "mp_storm") // Storm
	{
		return (-2, -48, -7);
	}
	else if (currentMap == "mp_strike") // Strike
	{
		return (-640, 480, 24);
	}
	else if (currentMap == "mp_subbase") // Sub Base
	{
		return (464, -591, 87);
	}
	else if (currentMap == "mp_terminal") // Terminal
	{
		return (1071, 4910, 190);
	}
	else if (currentMap == "mp_trailerpark") // Trailer Park
	{
		return (-110, 389, 5);
	}
	else if (currentMap == "mp_underpass") // Underpass
	{
		return (1492, 740, 403);
	}
	else if (currentMap == "mp_vacant") // Vacant
	{
		return (-77, -186, -50);
	}
	else if (currentMap == "mp_brecourt") // Wasteland
	{
		return (606, -840, -30);
	}
	else
	{
		return (0, 0, 0);
	}
}

gtnw_endGame( winningTeam, endReasonText )
{
	thread maps\mp\gametypes\_gamelogic::endGame( winningTeam, endReasonText );
}

onStartGameType()
{
	if ( !isdefined( game["switchedsides"] ) )
		game["switchedsides"] = false;

	if ( !isdefined( game["original_defenders"] ) )
		game["original_defenders"] = game["defenders"];

	if ( game["switchedsides"] )
	{
		oldAttackers = game["attackers"];
		oldDefenders = game["defenders"];
		game["attackers"] = oldDefenders;
		game["defenders"] = oldAttackers;
	}

	setClientNameMode("auto_change");
	
	
	if ( level.splitscreen )
	{
		setObjectiveScoreText( game["attackers"], &"OBJECTIVES_GTNW" );
		setObjectiveScoreText( game["defenders"], &"OBJECTIVES_GTNW" );
	}
	else
	{
		setObjectiveScoreText( game["attackers"], &"OBJECTIVES_GTNW_SCORE" );
		setObjectiveScoreText( game["defenders"], &"OBJECTIVES_GTNW_SCORE" );
	}
	
	setObjectiveText( game["attackers"], &"OBJECTIVES_GTNW" );
	setObjectiveText( game["defenders"], &"OBJECTIVES_GTNW" );
	
	setObjectiveHintText( game["attackers"], &"OBJECTIVES_GTNW_HINT" );
	setObjectiveHintText( game["defenders"], &"OBJECTIVES_GTNW_HINT" );
	
	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_ctf_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_ctf_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_ctf_spawn_allies" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_ctf_spawn_axis" );
	
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );
	
	thread maps\mp\gametypes\_dev::init();
	
	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 100 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", 20 );
	maps\mp\gametypes\_rank::registerScoreInfo( "capture", 500 );

	allowed[0] = "airdrop_pallet";
	maps\mp\gametypes\_gameobjects::main(allowed);

	thread nuke();
}

printNukeZoneOrigin()
{
    nukeZone = getEnt("gtnw_zone", "targetname");

    if (isDefined(nukeZone))
    {
        origin = nukeZone.origin;

        iPrintlnBold("Nuke Zone Origin: " + origin[0] + ", " + origin[1] + ", " + origin[2]);
    }
    else
    {
        iPrintln("Nuke Zone entity not found.");
    }
}

nuke()
{
	level waittill("prematch_over");

	//iPrintln("Prematch is over! Waiting 1 seconds...");
	wait 1;

	//printNukeZoneOrigin();
	
	if (isDefined(level.players) && level.players.size > 0 )
	{
		level.lastStatus["allies"] = 0;
		level.lastStatus["axis"] = 0;

		player = level.players[randomInt(level.players.size)];
		dropSite = nukeLocation();
		
		dropNuke( dropSite, player, "nuke_drop" );
		//iPrintlnBold( "Taylor Swift is on her way..." );

		while ( !isDefined( level.nukeCrate ) )
			wait( 1 );
			
		nukeTargetTrigger = spawn( "trigger_radius", level.nukeCrate.origin, 0, 128, 128 );

		visuals = [];
		visuals[0] = level.nukeCrate;
		
		nukeProxTrig = maps\mp\gametypes\_gameobjects::createUseObject( "neutral", nukeTargetTrigger, visuals, (0,0,32) );
		nukeProxTrig maps\mp\gametypes\_gameobjects::allowUse( "any" );
		nukeProxTrig maps\mp\gametypes\_gameobjects::setUseTime( 45.0 );
		nukeProxTrig maps\mp\gametypes\_gameobjects::setUseText( &"MP_CAPTURING_NUKE" ); //temp
		nukeProxTrig maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
		nukeProxTrig.onUse = ::onUse;
		nukeProxTrig.onBeginUse = ::onBeginUse;
	}
	else
	{
		//iPrintln("No players available to drop the nuke.");
	}
}


getSpawnPoint()
{
	if ( self.team == "axis" )
	{
		spawnTeam = game["attackers"];
	}
	else
	{
		spawnTeam = game["defenders"];
	}

	if ( level.inGracePeriod )
	{
		spawnPoints = getentarray("mp_ctf_spawn_" + spawnteam + "_start", "classname");		
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
	}
	else
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnteam );
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
	}
	
	return spawnPoint;
}


spawnFxDelay( fxid, pos, forward, right, delay )
{
	wait delay;
	effect = spawnFx( fxid, pos, forward, right );
	triggerFx( effect );
}

onNormalDeath( victim, attacker, lifeId )
{
	team = victim.team;
	
	if ( game["state"] == "postgame" )
		attacker.finalKill = true;
}

onDeadEvent( team )
{
	if ( ( isDefined( level.nukeIncoming ) && level.nukeIncoming ) || ( isDefined( level.nukeDetonated ) && level.nukeDetonated ) )
		return;
	
	if ( team == game["attackers"] )
	{
		maps\mp\gametypes\_gamescore::giveTeamScoreForObjective( team, 1 );	
		level thread gtnw_endGame( game["defenders"], game["strings"][game["attackers"]+"_eliminated"] );
	}
	else if ( team == game["defenders"] )
	{
		maps\mp\gametypes\_gamescore::giveTeamScoreForObjective( team, 1 );	
		level thread gtnw_endGame( game["attackers"], game["strings"][game["defenders"]+"_eliminated"] );
	}
}

initGametypeAwards()
{
	return;
}

onTimeLimit()
{
	if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
	{
		thread maps\mp\gametypes\_gamelogic::endGame( "tie", game["strings"]["time_limit_reached"] );
	}
	else if( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
	{
		thread maps\mp\gametypes\_gamelogic::endGame( "axis", game["strings"]["time_limit_reached"] );
	}
	else if( game["teamScores"]["axis"] < game["teamScores"]["allies"] )
	{
		thread maps\mp\gametypes\_gamelogic::endGame( "allies", game["strings"]["time_limit_reached"] );
	}
}

onPrecacheGameType()
{
	return;
}

onBeginUse( player )
{
	self.didStatusNotify = false;
	
	otherTeam = getOtherTeam( player.pers["team"] );
	
	return;
}


onUse( player )
{
	team = player.pers["team"];
	oldTeam = self maps\mp\gametypes\_gameobjects::getOwnerTeam();
	label = self maps\mp\gametypes\_gameobjects::getLabel();
	
	self.captureTime = getTime();
	
	otherTeam = getOtherTeam( team );
	
	level.nukeCrate notify( "captured", player );
	player notify( "objective", "captured" );
	self giveFlagCaptureXP( self.touchList[team] );
	self maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
	self maps\mp\gametypes\_gameobjects::allowUse( "none" );
}

giveFlagCaptureXP( touchList )
{
	level endon ( "game_ended" );
	wait .05;
	WaitTillSlowProcessAllowed();
	
	players = getArrayKeys( touchList );
	for ( index = 0; index < players.size; index++ )
	{
		player = touchList[players[index]].player;
		player thread maps\mp\gametypes\_hud_message::SplashNotify( "captured_nuke", maps\mp\gametypes\_rank::getScoreInfoValue( "capture" ) );
		player thread [[level.onXPEvent]]( "capture" );
		maps\mp\gametypes\_gamescore::givePlayerScore( "capture", player );
	}
}
