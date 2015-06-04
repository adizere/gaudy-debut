-module(bertie_sup).

% -behaviour(supervisor).

-export([start/0]).


%% ===================================================================
%% API functions
%% ===================================================================

start() ->
    io:format("rebar boilerplate, meh~n").