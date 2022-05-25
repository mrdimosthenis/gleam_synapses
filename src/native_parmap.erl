-module(native_parmap).
-export([parmap/2]).

parmap(L, F) ->
  Parent = self(),
  [receive {Pid, Result} -> Result end || Pid <- [spawn(fun() -> Parent ! {self(), F(X)} end) || X <- L]].
