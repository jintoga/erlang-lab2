%% @author DAT 
-module(lab2). 
-export([start/0, make_request/2, getAttackedBy/3, game/0, tanker/1, boss/1, archer/1, healer/1]).
 

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

tanker(0) -> make_request(boss_pid, tanker_dead),
			 io:format("~nTanker: I'm dead @_o Boss Won. Game Over!", []);
			 

tanker(TANKER_HP) ->
	io:format("~nTanker(~w): wating", [TANKER_HP]),  
	receive  
		boss_dead -> io:format("~nGame Over! Tanker Won", []);
		game_started -> io:format("~nTanker: Game started! Attacking Boss", []),
						make_request(boss_pid, get_attacked_by_tanker),
						tanker(TANKER_HP); 
		get_attacked_by_boss -> TANKER_HP_NEW = TANKER_HP - 10,
								getAttackedBy(TANKER_HP_NEW, "Tanker", "Boss"), 
								io:format("~nTanker(~w): Calling Archer!", [TANKER_HP_NEW]),
								make_request(archer_pid, tanker_called),
								io:format("~nTanker(~w): Calling Healer to save my a$$!", [TANKER_HP_NEW]),
								make_request(healer_pid, tanker_called),
								tanker(TANKER_HP_NEW);
		get_healed -> TANKER_HP_NEW = TANKER_HP + 10,
					  io:format("~nTanker(~w): Get healed by Healer!", [TANKER_HP_NEW]),  
					  make_request(boss_pid, duel),  
					  tanker(TANKER_HP_NEW);
		duel -> TANKER_HP_NEW = TANKER_HP - 10, 
				io:format("~nTanker(~w): Attacking Boss again in a Duel!", [TANKER_HP_NEW]), 
				make_request(boss_pid, duel),   
				tanker(TANKER_HP_NEW) 
	end.		
  
boss(0) -> make_request(tanker_pid, boss_dead),
		   io:format("~nBoss: I'm dead. Game Over!", []);
	
boss(BOSS_HP) -> 
	io:format("~nBoss(~w): wating", [BOSS_HP]),
	receive  
		tanker_dead ->  io:format("~nGame Over! Boss Won", []);
		get_attacked_by_tanker -> BOSS_HP_NEW = BOSS_HP - 10,
								  getAttackedBy(BOSS_HP_NEW, "Boss", "Tanker"), 
								  io:format("~nBoss(~w): Attacking back Tanker!", [BOSS_HP_NEW]),   
								  make_request(tanker_pid, get_attacked_by_boss),
								  boss(BOSS_HP_NEW);
		get_attacked_by_archer -> BOSS_HP_NEW = BOSS_HP - 10,
								  getAttackedBy(BOSS_HP_NEW, "Boss", "Archer"),
								  io:format("~nBoss(~w): Attacking back Archer!", [BOSS_HP_NEW]), 
								  make_request(archer_pid, get_attacked_by_boss),
								  boss(BOSS_HP_NEW);
		archer_dead -> io:format("~nBoss(~w): Archer is dead LMAO attacking Healer", [BOSS_HP]),
					   make_request(healer_pid, get_attacked_by_boss),
					   boss(BOSS_HP);
		duel ->  BOSS_HP_NEW = BOSS_HP - 10, 
				 getAttackedBy(BOSS_HP_NEW, "Boss", "Tanker"),  
				 io:format("~nBoss(~w): Attacking back Tanker in a Duel!", [BOSS_HP_NEW]),   
				 make_request(tanker_pid, duel), 
				 boss(BOSS_HP_NEW)
	end.
   
archer(0) -> make_request(boss_pid, archer_dead);

archer(ARCHER_HP) ->  
	io:format("~nArcher(~w): wating", [ARCHER_HP]), 
	receive  
		tanker_called -> io:format("~nArcher(~w): Tanker called! Attacking Boss", [ARCHER_HP]),
						 make_request(boss_pid, get_attacked_by_archer),
						 archer(ARCHER_HP);
		get_attacked_by_boss -> ARCHER_HP_NEW = ARCHER_HP - 10,
								getAttackedBy(ARCHER_HP_NEW, "Archer", "Boss"),
								archer(ARCHER_HP_NEW)
	end.

healer(0) -> getAttackedBy(0, "Healer", "Boss"),
			 make_request(tanker_pid, healer_dead);

healer(HEALER_HP) ->
	io:format("~nHealer(~w): wating", [HEALER_HP]),
	receive
		tanker_called -> io:format("~nHealer(~w): Tanker called! Healing Tanker", [HEALER_HP]),
						 make_request(tanker_pid, get_healed),
						 healer(HEALER_HP);
		get_attacked_by_boss -> HEALER_HP_NEW = HEALER_HP - 10,
								getAttackedBy(HEALER_HP_NEW, "Healer", "Boss")  
	end.

start() ->  
	register(game_pid, spawn(lab2, game, [])), 
	register(boss_pid, spawn(lab2, boss, [60])), 
	register(tanker_pid, spawn(lab2, tanker, [50])), 
	register(archer_pid, spawn(lab2, archer, [10])),
	register(healer_pid, spawn(lab2, healer, [10])),
    make_request(game_pid, game_started).
	
 
