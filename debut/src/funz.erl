-module(funz).
-export([total/1, cost/1, pythag/1, perms/1, odev/1]).
-import(lists, [map/2, sum/1]).


total(L) ->
    sum(map(fun({What,N}) -> cost(What) * N end, L)).


cost(orange) -> 2;
cost(apple) -> 3.


qsort([]) -> [];
qsort([Pivot|T]) ->
    qsort([X || X <- T, X < Pivot])
    ++ [Pivot] ++
    qsort([X || X <- T, X > Pivot]).


pythag(N) ->
    [ {A,B,C} ||
        A <- lists:seq(1,N),
        B <- lists:seq(1,N),
        C <- lists:seq(1,N),
        A+B+C =< N,
        A*A+B*B =:= C*C
    ].


perms([]) -> [[]];
perms(L) -> [[H|T] || H <- L, T <- perms(L--[H])].


odev(L) ->
    odev_acc(L, [], []).

odev_acc([H|T], O, E) ->
    case (H rem 2) of
         1 -> odev_acc(T, [H|O], E);
         0 -> odev_acc(T, O, [H|E])
    end;
odev_acc([], O, E) ->
    {lists:reverse(O), lists:reverse(E)}.