-module(kit_gen_server).
-behavior(gen_server).

-export([start_link/0, order_kit/4, return_kit/2, close_shop/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-record(kit, {name, color=green, description}).


%%% API
start_link() ->
    gen_server:start_link(?MODULE, [], []).


%%% Synchronous calls
order_kit(Pid, Name, Color, Desc) ->
    gen_server:call(Pid, {order, Name, Color, Desc}).


close_shop(Pid) ->
    gen_server:call(Pid, terminate).


%% Async call
return_kit(Pid, Kit = #kit{}) ->
    gen_server:cast(Pid, {return, Kit}).


%%% Server functions
%%% mostly callback required by gen_server
init([]) -> {ok, []}.


handle_call({order, Name, Color, Desc}, _From, Kits) ->
    if  Kits =:= [] ->
            {reply, make_kit(Name, Color, Desc), Kits};
        Kits =/= [] ->
            {reply, hd(Kits), tl(Kits)}
    end;
handle_call(terminate, _From, Kits) ->
    {stop, normal, ok, Kits}.


handle_cast({return, Kit = #kit{}}, Kits) ->
    {noreply, [Kit|Kits]}.


handle_info(Msg, Kits) ->
    io:format("Unexpected message: ~p~n", [Msg]),
    {noreply, Kits}.


terminate(normal, Kits) ->
    [io:format("~p was set free.~n", [C#kit.name]) || C <- Kits],
    ok.


code_change(_Oldv, State, _Extra) ->
    {ok, State}.


make_kit(Name, Col, Desc) ->
    #kit{name=Name, color=Col, description=Desc}.