-module(dies).
-export([on_exit/2, loop/0]).


on_exit(Pid, Fun) ->
    spawn(fun() ->
        Ref = monitor(process, Pid),
        receive
            {'DOWN', Ref, process, Pid, Why} ->
            Fun(Why)
        end
    end).

start(Fs) ->
    spawn(fun() ->
        [spawn_link(F) || F <- Fs],
        receive
        after
            infinity -> true
        end
    end).


loop() ->
    receive X ->
        io:format("received ~s~n", [X])
    end,
    loop().