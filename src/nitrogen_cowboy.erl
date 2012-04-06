%% vim: ts=4 sw=4 et

-module(nitrogen_cowboy).


-export([init/3, handle/2, terminate/2]).

-record(state, {headers, body}).

init({_Transport, http}, Req, Opts) ->
    Headers = proplists:get_value(headers, Opts, []),
    Body = proplists:get_value(body, Opts, "http_handler"),
    {ok, Req, #state{headers=Headers, body=Body}}.


handle(Req,_Opts) ->

    DocRoot = "./docroot",
    RequestBridge = simple_bridge:make_request(cowboy_request_bridge,
                                               {Req, DocRoot}),

    %% Becaue Cowboy usese the same "Req" record, we can pass the 
    %% previously made RequestBridge to make_response, and it'll
    %% parse out the relevant bits to keep both parts (request and
    %% response) using the same "Req"
    ResponseBridge = simple_bridge:make_response(cowboy_response_bridge,
                                                 RequestBridge),

    Response1 = ResponseBridge:status_code(200),

    Response2 = Response1:header("Content-Type", "text/html"),


	Response3 = Response2:data("HELLO WORLD"),

    
    {ok, NewReq} = Response3:build_response(),

    %% This will be returned back to cowboy
    {ok, NewReq, _Opts}.

terminate(_Req, _State) ->
    ok.

