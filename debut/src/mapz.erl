-module(mapz).
-export([countc/1]).

countc(S) ->
    countcc(S, #{}).


countcc([H|T], X) ->
    H;
countcc([], X) ->
    X.
%     countcc(T, X#{ H := N+1 });
% countcc([H|T], X) ->
%     countcc(T, X#{ H => 1 });
% countcc([], X) ->
%     X.