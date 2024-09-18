-module(erl_planner_app).

-behaviour(application).

-export([
  start/2,
  stop/1,
  start_phase/3
]).

start(_StartType, _StartArgs) ->
  erl_planner_sup:start_link().

stop(_State) ->
  ok.

start_phase(start_http, _, []) ->
  Port = 8080,
  ListenerCount = 10,
  Handlers =
    [
      ep_todolist_h,
      ep_users_h,
      cowboy_swagger_handler
    ],

  Trails = trails:trails(Handlers),
  trails:store(Trails),

  CowboyOptions =
    #{env => #{
      dispatch => trails:single_host_compile(Trails)},
      request_timeout => 12000,
      middlewares => [
        cowboy_router,
        cowboy_handler
      ]
    },

  {ok, _} = cowboy:start_clear(start_http, #{socket_opts => [{port, Port}], num_acceptors => ListenerCount}, CowboyOptions),
  ok.