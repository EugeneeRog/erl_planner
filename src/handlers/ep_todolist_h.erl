%%%-------------------------------------------------------------------
%%% @author yevhenii
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Sep 2024 15:49
%%%-------------------------------------------------------------------
-module(ep_todolist_h).
-author("yevhenii").

%% API
-export([
  init/2,
  handle/2,
  allowed_methods/2,
  content_types_accepted/2,
  content_types_provided/2,
  is_authorized/2,
  delete_resource/2,
  trails/0
]).

init(Req, State) ->
  {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
  {[<<"GET">>, <<"PUT">>,  <<"PATCH">>, <<"DELETE">>], Req, State}.

content_types_accepted(Req, State) ->
  {[{<<"application/json">>, handle}], Req, State}.

content_types_provided(Req, State) ->
  {[{<<"application/json">>, handle}], Req, State}.

is_authorized(Req, State) ->
  {true, Req, State}.

trails() ->
  trail(["/api/v1/plans"], ?MODULE).

trail(Endpoints, Module) when is_list(Endpoints) ->
  Fun = fun(Path) -> trails:trail(Path, Module, #{path => Path}, schema(Path)) end,
  lists:map(Fun, Endpoints).

handle(#{method := Method} = Req, State) ->
  Response = handle(Method, Req, State),
  erlang:display(Response),
  ep_http_utils:response(Response, Req, State).

handle(<<"GET">>, Req, _State) ->
  Qs = cowboy_req:parse_qs(Req),
  case proplists:get_value(<<"user_id">>, Qs, undefined) of
    undefined -> {false, 400, <<"missed user id">>};
    UserInd -> ep_todolist:get(binary_to_integer(UserInd))
  end;

handle(<<"PUT">>, Req, State) ->
  {ok, Body, Req1} = cowboy_req:read_body(Req),
  ParsedBody = jsx:decode(Body),
  Keys = [<<"user_id">>, <<"text">>, <<"name">>],
  case lists:all(fun(Key) -> maps:is_key(Key, ParsedBody) end, Keys) of
    false -> {false, <<"bad_request">>};
    true -> ep_todolist:put(ParsedBody)
  end;

handle(<<"PATCH">>, Req, _State) ->
  {ok, Body, _} = cowboy_req:read_body(Req),
  ParsedBody = jsx:decode(Body),
  Keys = [<<"id">>, <<"status">>],
  case lists:all(fun(Key) -> maps:is_key(Key, ParsedBody) end, Keys) of
    false -> {false, <<"bad_request">>};
    true -> ep_todolist:change_status(ParsedBody)
  end.

delete_resource(Req, State) ->
  Qs = cowboy_req:parse_qs(Req),
  case proplists:get_value(<<"id">>, Qs, undefined) of
    undefined -> {false, <<"bad_request">>};
    Id -> ep_http_utils:response(ep_todolist:delete(binary_to_integer(Id)), Req, State)
  end.

schema("/api/v1/plans") ->
  #{
    get =>
    #{
      tags => ["plans api"],
      description => "Get plans",
      produces => ["application/json"],
      consumes => ["application/x-www-form-urlencoded"],
      parameters => [
        #{
          name => <<"user_id">>,
          in => <<"query">>,
          description => <<"user name">>,
          required => true,
          example => 1
        }
      ]
    },

    delete =>
    #{
      tags => ["plans api"],
      description => "delete plan",
      produces => ["application/json"],
      consumes => ["application/x-www-form-urlencoded"],
      parameters => [
        #{
          name => <<"id">>,
          in => <<"query">>,
          description => <<"user id">>,
          required => true,
          example => 1
        }
      ]
    },

    put =>
    #{
      tags => ["plans api"],
      description => "add plan",
      produces => ["application/json"],
      consumes => ["application/json"],
      parameters => [],
      requestBody => #{
        required => true,
        content => #{
          <<"application/json">> => #{
            schema => #{
              type => object,
              required => [
                user_id,
                name,
                text
              ],
              properties =>  #{
                user_id => #{type => integer, example => 1},
                name => #{type => binary, example => <<"create test task">>},
                text => #{type => binary, example => <<"i want to create test task">>}
              }
            }
          }
        }
      }
    },

    patch =>
    #{
      tags => ["plans api"],
      description => "change plan status",
      produces => ["application/json"],
      consumes => ["application/json"],
      parameters => [],
      requestBody => #{
        required => true,
        content => #{
          <<"application/json">> => #{
            schema => #{
              type => object,
              required => [
                nickname
              ],
              properties =>  #{
                id => #{type => integer, example => 16},
                status => #{type => string, example => <<"complete">>}}
            }
          }
        }
      }
    }
  }.
