-module(event).
-compile(export_all).

-record(state, {server,
                name="",
                to_go=0}).

start(EventName, Delay) ->
    spawn(?MODULE, init, [self(), EventName, Delay]).


start_link(EventName, Delay) ->
    spawn_link(?MODULE, init, [self(), EventName, Delay]).

cancel(Pid) ->
    Ref = erlang:monitor(process, Pid),
    Pid ! {self(), Ref, cancel},
    receive
        {Ref, ok} ->
            erlang:demonitor(Ref, [flush]),
            io:format("Demonitored ~w~n", [Pid]),
            ok;
        {'DOWN', Ref, process, Pid, _reason} ->
            io:format("Process ~w is already DOWN~n", [Pid])
    end.


%%% Event's innards
init(Server, EventName, Delay) ->
    loop(#state{server=Server, name=EventName, to_go=time_to_go(Delay)}).


loop(S = #state{server=Server, to_go=[T|Next]}) ->
    receive
        {Server, Ref, cancel} ->
            Server ! {Ref, ok}
    after T*1000 ->
        if
            Next =:= [] ->
                Server ! {done, S#state.name};
            Next =/= [] ->
                loop(S#state{to_go=Next})
        end
    end.


normalize(N) ->
    Limit = 49*24*60*60,
    [N rem Limit | lists:duplicate(N div Limit, Limit)].


time_to_go(TimeOut={{_,_,_}, {_,_,_}}) ->
    Now = calendar:local_time(),
    ToGo = calendar:datetime_to_gregorian_seconds(TimeOut) -
            calendar:datetime_to_gregorian_seconds(Now),
    Secs = if ToGo > 0 -> ToGo;
              ToGo =< 0 -> 0
            end,
    normalize(Secs).