%% @author DAT 
-module(lab2). 
-export([start/0, make_request/2, getAttackedBy/3, game/0, tanker/1, boss/1 ]).
 

make_request(Id, Msg) -> Id ! Msg.

getAttackedBy(0, Host, Attacker) -> io:format("~n~s: I'm dead @_o. Got attacked by: ~s", [Host, Attacker]);

getAttackedBy(HP, Host, Attacker) -> io:format("~n~s(~w): Get attacked by ~s", [Host, HP, Attacker]).
  

game() ->
	io:format("~nGame: waiting", []),
    receive
        game_started ->
			make_request(tanker_pid, game_started),
            io:format("~nGame: started", [])
    end.

tanker(0) -> getAttackedBy(0, "Tanker", "Boss"), 
			 make_request(boss_pid, tanker_dead);

tanker(TANKER_HP) ->
	io:format("~nTanker(~w): wating", [TANKER_HP]), 
	make_request(boss_pid, get_attacked_by_tanker),
	receive  
		game_started -> io:format("~nTanker: Game started! Attacking Boss", []),
						make_request(boss_pid, get_attacked_by_tanker);
		get_attacked_by_boss -> getAttackedBy(TANKER_HP, "Tanker", "Boss")
	end,
	tanker(TANKER_HP - 10).		
  
boss(0) -> io:format("~nBoss: I'm dead. Game Over!", []);
	
boss(BOSS_HP) -> 
	receive  
		tanker_dead ->  io:format("~nGame Over! Boss Won", []);
		get_attacked_by_tanker ->  getAttackedBy(BOSS_HP, "Boss", "Tanker"),
								   make_request(tanker_pid, get_attacked_by_boss),
								   boss(BOSS_HP - 10)
	end,
	io:format("~nBoss(~w): wating", [BOSS_HP]).

start() ->  
	register(game_pid, spawn(lab2, game, [])), 
	register(boss_pid, spawn(lab2, boss, [50])), 
	register(tanker_pid, spawn(lab2, tanker, [30])),
    make_request(game_pid, game_started).
	
 
