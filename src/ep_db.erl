%%%-------------------------------------------------------------------
%%% @author yevhenii
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Sep 2024 17:22
%%%-------------------------------------------------------------------
-module(ep_db).
-author("yevhenii").

-include_lib("epgsql/include/epgsql.hrl").

%% API
-export([
  delete/2,
  select/2,
  default_query/2,
  insert_with_returning/2
]).

db_conn(Pool) ->
  case pooler:take_member(Pool, {30, sec}) of
    error_no_members ->
      {error, no_connection};
    Conn -> Conn
  end.

parse_db_res(Cols, Rows) ->
  lists:map(fun(Row) -> maps:from_list(lists:zipwith(fun combine/2, Cols, erlang:tuple_to_list(Row))) end, Rows).

combine(#column{name = Name}, Value) -> {Name, Value}.

select(Query, QueryParams) ->
  Conn = db_conn(ep_db),
  case epgsql:equery(Conn, Query, QueryParams) of
    {ok, Cols, Rows} -> parse_db_res(Cols, Rows);
    {error, _Reason} -> error
end.

insert_with_returning(Query, QueryParams) ->
  case epgsql:equery(db_conn(ep_db), Query, QueryParams) of
    {ok, 1, Col, Rows} -> {ok, parse_db_res(Col, Rows)};
    {ok, 0, _, _} -> {error, <<"alredy exists">>}
  end.

default_query(Query, QueryParams) -> epgsql:equery(db_conn(ep_db), Query, QueryParams).

delete(Query, QueryParams) ->
  epgsql:equery(db_conn(ep_db), Query, QueryParams).