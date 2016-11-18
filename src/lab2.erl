%% @author DAT 
-module(lab2). 
-export([start/0, make_request/2, getAttacked/2,  game/0, tanker/0]).

make_request(ServerId, Msg) ->
    ServerId ! Msg.

getAttacked(0, Character) -> io:format("~n ~s: I'm dead @_o", [Character]);

getAttacked(HP, Character) -> io:format("~n ~s's HP: ~w", [Character, HP - 10]).
 
game() ->
	io:format("~nGame: waiting", []),
    receive
        game_started ->
            io:format("~nGame: started", []),
			make_request(tanker_pid, game_started)
    end.

tanker() ->
	io:format("~nTanker: wating", []),
	receive  
		game_started -> getAttacked(20, "Tanker")
						
	end.
  

start() ->
	register(tanker_pid, spawn(lab2, tanker, [])),
	register(game_pid, spawn(lab2, game, [])), 
    make_request(game_pid, game_started).
	
 
