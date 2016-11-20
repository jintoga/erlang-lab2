%% @author DAT 
-module(lab2). 
-export([start/0, make_request/2, getAttackedBy/3, game/0, tanker/1, boss/1, archer/1, healer/1]).
 

make_request(ServerId, Msg) ->
    ServerId ! Msg.

getAttackedBy(0, Host, Attacker) -> io:format("~n~s: I'm dead @_o. Got attacked by: ~s", [Host, Attacker]);

getAttackedBy(HP, Host, Character) -> io:format("~n~s(~w): Got attacked by ~s", [Host, HP - 10, Character]).
  

game() ->
	io:format("~nGame: waiting", []),
    receive
        game_started ->
            io:format("~nGame: started", []),
			make_request(tanker_pid, game_started)
    end.

tanker(TANKER_HP) ->
	io:format("~nTanker(~w): wating", [TANKER_HP]),
	receive  
		game_started -> io:format("~nTanker: Game started! Attacking Boss", []),
						make_request(boss_pid, get_attacked_by_tanker);
		get_attacked_by_boss -> getAttackedBy(TANKER_HP, "Tanker", "Boss")				
	end.
  
boss(BOSS_HP) ->
	io:format("~nBoss(~w): wating", [BOSS_HP]),
	receive  
		get_attacked_by_tanker -> getAttackedBy(BOSS_HP, "boss", "Tanker"),
								  make_request(tanker_pid, get_attacked_by_boss)
						
	end.

archer(ARCHER_HP) ->
	io:format("~nArcher(~w): wating", [ARCHER_HP]),
	receive  
		game_started -> getAttackedBy(20, "Boss", "Tanker")
						
	end.

healer(HEALER_HP) -> 
	io:format("~nHealer(~w): wating", [HEALER_HP]),
	receive  
		game_started -> getAttackedBy(20, "Boss", "Tanker")
						
	end.

start() ->
	BOSS_HP = 120,
	TANKER_HP = 70,
	ARCHER_HP = 10,
	HEALER_HP = 10,
	register(game_pid, spawn(lab2, game, [])), 
	register(tanker_pid, spawn(lab2, tanker, [TANKER_HP])),
	register(boss_pid, spawn(lab2, boss, [BOSS_HP])),
	register(archer_pid, spawn(lab2, archer, [ARCHER_HP])),  
	register(healer_pid, spawn(lab2, healer, [HEALER_HP])), 
    make_request(game_pid, game_started).
	
 
