%% @author DAT 
-module(lab2). 
-export([start/0, make_request/2, getAttackedBy/3, game/0, tanker/1, boss/1, archer/1]).
 

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
	receive  
		game_started -> io:format("~nTanker: Game started! Attacking Boss", []),
						make_request(boss_pid, get_attacked_by_tanker),
						tanker(TANKER_HP); 
		get_attacked_by_boss -> TANKER_HP_NEW = TANKER_HP - 10,
								getAttackedBy(TANKER_HP_NEW, "Tanker", "Boss"), 
								io:format("~nTanker(~w): Calling archer!", [TANKER_HP_NEW]),
								make_request(archer_pid, tanker_called)  
	end.		
  
boss(0) -> io:format("~nBoss: I'm dead. Game Over!", []);
	
boss(BOSS_HP) -> 
	io:format("~nBoss(~w): wating", [BOSS_HP]),
	receive  
		tanker_dead ->  io:format("~nGame Over! Boss Won", []);
		get_attacked_by_tanker -> BOSS_HP_NEW = BOSS_HP - 10,
								  getAttackedBy(BOSS_HP_NEW, "Boss", "Tanker"), 
								  io:format("~nBoss(~w): Attacking back tanker!", [BOSS_HP_NEW]),   
								  make_request(tanker_pid, get_attacked_by_boss) 
	end.
   
archer(0) -> getAttackedBy(0, "Archer", "Boss");

archer(ARCHER_HP) ->  
	io:format("~nArcher(~w): wating", [ARCHER_HP]), 
	receive  
		tanker_called -> io:format("~nArcher(~w): Tanker called! Attacking Boss", [ARCHER_HP]),
						 make_request(boss_pid, get_attacked_by_archer);
		get_attacked_by_boss -> getAttackedBy(ARCHER_HP, "Archer", "Boss") 
	end.

start() ->  
	register(game_pid, spawn(lab2, game, [])), 
	register(boss_pid, spawn(lab2, boss, [80])), 
	register(tanker_pid, spawn(lab2, tanker, [50])), 
	register(archer_pid, spawn(lab2, archer, [10])),
    make_request(game_pid, game_started).
	
 
