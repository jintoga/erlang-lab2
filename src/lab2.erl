%% @author DAT 
-module(lab2). 
-export([start/0, make_request/2, attackBoss/1,  game/1, tanker/0]).

make_request(ServerId, Msg) ->
    ServerId ! Msg.

attackBoss(N) ->  
	io:format("Bosses HP: "), N - 10.

game(Tanker_PID) ->
	io:format("~nGame: waiting", []),
    receive
        game_started ->
            io:format("~nGame: started", []),
			make_request(Tanker_PID, game_started)
    end.

tanker() ->
	io:format("~nTanker: wating", []),
	receive  
		game_started -> io:format("~nTanker: attacking boss", [])
	end.
  

start() ->
	Tanker_PID = spawn(lab2, tanker, []),
	Game_PID = spawn(lab2, game, [Tanker_PID]),
    make_request(Game_PID, game_started).
	
 
