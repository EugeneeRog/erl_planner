%%%-------------------------------------------------------------------
%%% @author yevhenii
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Sep 2024 21:45
%%%-------------------------------------------------------------------
-module(ep_users).
-author("yevhenii").

%% API
-export([
  get/1,
  put/1,
  delete/1
]).

get(UserName) ->
  Query =
    "SELECT id, user_name
      FROM public.users
      WHERE user_name = $1",
  ep_db:select(Query, [UserName]).

put(UserName) ->
  Query =
    "INSERT INTO public.users (user_name) VALUES($1)
    ON CONFLICT DO NOTHING
    RETURNING id,user_name",
  case ep_db:insert_with_returning(Query, [UserName]) of
    {error, <<"alredy exists">>} -> {false, <<"alredy exists">>, 409};
    {ok, Res} -> {true, Res}
  end.

delete(Id) ->
  IntId = binary_to_integer(Id),
  Query = "DELETE FROM public.users WHERE id = $1",
  case ep_db:delete(Query, [IntId]) of
    {ok, 1} -> true;
    {ok, 0} -> {false, <<"user undefined">>, 404}
  end.
