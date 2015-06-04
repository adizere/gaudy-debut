-module(bertie_app).

% -behaviour(application).

%% Application callbacks
-export([start/0]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start() ->
    Handle = bitcask:open("bertiedb", [read_write]),
    N = fetch(Handle),
    store(Handle, N+1),
    io:format("Bertie has been run ~p times~n", [N]),
    bitcask:close(Handle),
    init:stop().

store(Handle, N) ->
    bitcask:put(Handle, <<"bertie_executions">>, term_to_binary(N)).

fetch(Handle) ->
    case bitcask:get(Handle, <<"bertie_executions">>) of
        not_found  -> 1;
        {ok, Bin} -> binary_to_term(Bin)
    end.


% stop(_State) ->
%     ok.


%% rebar compile
%% erl -noshell -s bertie_app -s init stop