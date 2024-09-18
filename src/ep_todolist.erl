%%%-------------------------------------------------------------------
%%% @author yevhenii
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Sep 2024 20:07
%%%-------------------------------------------------------------------
-module(ep_todolist).
-author("yevhenii").

%% API
-export([
  put/1,
  change_status/1,
  get/1,
  delete/1
]).

put(#{<<"user_id">> := UserId, <<"text">> := ItemText, <<"name">> := ItemName}) ->
      Query =
        "INSERT INTO public.plans (user_id, name, text) VALUES($1, $2, $3) ON CONFLICT DO NOTHING",

      case ep_db:default_query(Query, [UserId, ItemName, ItemText]) of
        {error, {error,error,_,foreign_key_violation,_,Details}} ->
          {false, proplists:get_value(detail, Details)};
        {ok, 0} -> {false,<<"alredy exists">>};
        {ok, 1} -> {true, <<"created">>}
      end.

change_status(#{<<"id">> := ItemId, <<"status">> := NewStatus}) ->
  Query = "UPDATE public.plans
            SET status = $2
            WHERE id = $1",
  case ep_db:default_query(Query, [ItemId, NewStatus]) of
    {error, {error,error,_,check_violation,_,_}} ->
      {false, <<"bad parametr, please check status param, should be todo, progress or complete">>};
    {ok, 0} -> {false,<<"not updated, check is valid obj">>};
    {ok, 1} -> {true, <<"updated">>}
  end.

get(UserId) ->
  Query =
    "SELECT user_id, status, name, text, id
      FROM public.plans
      WHERE user_id = $1",
  ep_db:select(Query, [UserId]).

delete(ItemId) ->
  Query = "DELETE FROM public.plans WHERE id = $1",
  case ep_db:delete(Query, [ItemId]) of
    {ok, 1} -> true;
    {ok, 0} -> {false, <<"plan undefined">>, 404}
  end.

