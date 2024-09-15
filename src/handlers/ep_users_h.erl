%%%-------------------------------------------------------------------
%%% @author yevhenii
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Sep 2024 15:50
%%%-------------------------------------------------------------------
-module(ep_users_h).
-author("yevhenii").

%% API
-export([
  init/2,
  handle/2,
  allowed_methods/2,
  content_types_accepted/2,
  content_types_provided/2,
  is_authorized/2,
  trails/0,
  delete_resource/2
]).

init(Req, State) ->
  {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
  {[<<"GET">>, <<"PUT">>, <<"DELETE">>], Req, State}.

content_types_accepted(Req, State) ->
  {[{<<"application/json">>, handle}], Req, State}.

content_types_provided(Req, State) ->
  {[{<<"application/json">>, handle}], Req, State}.

is_authorized(Req, State) ->
  {true, Req, State}.

trails() ->
  trail(["/api/v1/users"], ?MODULE).

trail(Endpoints, Module) when is_list(Endpoints) ->
  Fun = fun(Path) -> trails:trail(Path, Module, #{}, schema(Path)) end,
  lists:map(Fun, Endpoints).

handle(#{method := Method} = Req, State) ->
  Response = handle(Method, Req, State),
  ep_http_utils:response(Response, Req, State).

handle(<<"GET">>, Req, _) ->
  Qs = cowboy_req:parse_qs(Req),
  UserName = proplists:get_value(<<"user_name">>, Qs, undefined),
  ep_users:get(UserName);

handle(<<"PUT">>, Req, _) ->
  {ok, Body, _} = cowboy_req:read_body(Req),
  ParsedBody = jsx:decode(Body),
  Username = maps:get(<<"user_name">>, ParsedBody, undefined),
  ep_users:put(Username).

delete_resource(Req, State) ->
  Qs = cowboy_req:parse_qs(Req),
  UserId = proplists:get_value(<<"id">>, Qs, undefined),
  ep_http_utils:response(ep_users:delete(UserId), Req, State).

schema("/api/v1/users") ->
  #{
    get =>
    #{
      tags => ["users api"],
      description => "Get user",
      produces => ["application/json"],
      consumes => ["application/x-www-form-urlencoded"],
      parameters => [
        #{
          name => <<"user_name">>,
          in => <<"query">>,
          description => <<"user name">>,
          required => true,
          example => <<"alex">>
        }
      ]
    },

    delete =>
    #{
      tags => ["users api"],
      description => "delete user",
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
      tags => ["users api"],
      description => "add user",
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
                name
              ],
              properties =>  #{
                user_name => #{type => binary, example => <<"create test task">>}
              }
            }
          }
        }
      }
    }
  }.
