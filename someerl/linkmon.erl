-module(linkmon).
-compile([export_all]).

myproc() ->
    timer:sleep(5000),
    exit(reason).


chain(0) ->
    receive
        _ -> ok
    after 2000 ->
        exit("chain dies here")
    end;
chain(N) ->
    % alternative call: spawn(?MODULE, chain, [N-1]),
    Pid = spawn(fun() -> chain(N-1) end),
    link(Pid),
    receive
        _ -> ok
    end.


trapz() ->
    process_flag(trap_exit, true),
    spawn_link(?MODULE, chain, [3]),
    receive
        X -> X
    end.

%% Supervision
%%
start_critic() ->
    spawn(?MODULE, critic, []).

judge(Band, Album) ->
    critic ! {self(), {Band, Album}},
    Pid = whereis(critic),
    receive
        {Pid, Critique} -> Critique
    after 2000 ->
        timeout
    end.

critic() ->
    receive
        {From, {"Rage Against the Turing Machine", "Unit Testify"}} ->
            From ! {self(), "They are great!"};
        {From, {"System of a Downtime", "Memoize"}} ->
            From ! {self(), "They're not Johnny Crash but they're good."};
        {From, {"Johnny Crash", "The Token Ring of Fire"}} ->
            From ! {self(), "Simply incredible."};
        {From, {_Band, _Album}} ->
            From ! {self(), "They are terrible!"}
    end,
    critic().

start_critic2() ->
    spawn(?MODULE, zupervizor, []).

zupervizor() ->
    process_flag(trap_exit, true),
    Pid = spawn_link(?MODULE, critic2, []),
    register(critic, Pid),
    receive
        {'EXIT', Pid, normal}   -> ok;
        {'EXIT', Pid, shutdown} -> ok;
        {'EXIT', Pid, _}        -> zupervizor()
    end.

judge2(Band, Album) ->
    Ref = make_ref(),
    critic ! {self(), Ref, {Band, Album}},
    receive
        {Ref, Critique} -> Critique
    after 2000 ->
        timeout
    end.

critic2() ->
    receive
        {From, Ref, {"Rage Against the Turing Machine", "Unit Testify"}} ->
            From ! {Ref, "They are great!"};
        {From, Ref, {"System of a Downtime", "Memoize"}} ->
            From ! {Ref, "They're not Johnny Crash but they're good."};
        {From, Ref, {"Johnny Crash", "The Token Ring of Fire"}} ->
            From ! {Ref, "Simply incredible."};
        {From, Ref, {_Band, _Album}} ->
            From ! {Ref, "They are terrible!"}
    end,
    critic2().