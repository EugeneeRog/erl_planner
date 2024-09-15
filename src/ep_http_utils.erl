%%%-------------------------------------------------------------------
%%% @author yevhenii
%%% @copyright (C) 2024, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Sep 2024 21:43
%%%-------------------------------------------------------------------
-module(ep_http_utils).
-author("yevhenii").

%% API
-export([
  response/3
]).

response(true, Req, State) ->
  {true, Req, State};
response({true, Msg}, Req, State) ->
  Response = jsx:encode(#{<<"status">> => <<"ok">>, <<"response">> => Msg}),
  Req2 = cowboy_req:set_resp_body(Response, Req),
  {true, Req2, State};
response({false, Msg}, Req, State) ->
  Response = jsx:encode(#{<<"status">> => <<"error">>, <<"response">> => Msg}),
  Req2 = cowboy_req:set_resp_body(Response, Req),
  {false, Req2, State};
response({false, Msg, Code}, Req, State) ->
  Response = jsx:encode(#{<<"status">> => <<"error">>, <<"response">> => Msg}),
  Req1 = cowboy_req:set_resp_body(Response, Req),
  Req2 = cowboy_req:reply(Code, Req1),
  {stop, Req2, State};
response(Res, Req, State) when is_list(Res) ->
  Response = jsx:encode(#{<<"status">> => <<"ok">>, <<"response">> => Res}),
  {Response, Req, State};
response(Res, Req, State) when is_binary(Res) ->
  Response = jsx:encode(#{<<"status">> => <<"ok">>, <<"response">> => Res}),
  {Response, Req, State}.
