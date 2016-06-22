-module(fight_server_app).

-behaviour(application).

%% Application callbacks
-export([start/0, start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start()->
    application:start(fight_server).

start(_StartType, _StartArgs) ->
    fight_server_sup:start_link().

stop(_State) ->
    ok.
