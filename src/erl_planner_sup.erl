-module(erl_planner_sup).

-behaviour(supervisor).

-export([
  start_link/0,
  init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
  SupFlags = #{strategy => one_for_one,
    intensity => 5,
    period => 10},

  {ok, Pools} = application:get_env(erl_planner, pools),
  {ok, {SupFlags, [ pooler:pool_child_spec(PoolConfig) || PoolConfig <- Pools ]}}.
