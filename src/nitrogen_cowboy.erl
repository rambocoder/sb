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

    % http://rustyklophaus.com/articles/20090916-GProcErlangGlobalProcessRegistry.html     
    % http://pastebin.com/TgbD4ij5
    % http://stackoverflow.com/questions/9814173/spawn-many-processes-erlang                                          
    case RequestBridge:path() of
        "/subscribe" -> 
            subscribe(comet),
            receive
                %% {<0.170.0>,{nitrogen_cowboy,comet},"hello from publish"}
                {_Ignore, _Ignore2, Data} -> io:format("Received: ~p~n", [Data])
            after 90000 ->
                Data = "Timedout"
            end;
        "/publish" -> 
            notify(comet, "hello from publish"),
            Data = "Published"
    end,
            


    %% Becaue Cowboy usese the same "Req" record, we can pass the 
    %% previously made RequestBridge to make_response, and it'll
    %% parse out the relevant bits to keep both parts (request and
    %% response) using the same "Req"
    ResponseBridge = simple_bridge:make_response(cowboy_response_bridge,
                                                 RequestBridge),

    Response1 = ResponseBridge:status_code(200),

    Response2 = Response1:header("Content-Type", "text/html"),


	Response3 = Response2:data(Data),


    {ok, NewReq} = Response3:build_response(),

    %% This will be returned back to cowboy
    {ok, NewReq, _Opts}.

terminate(_Req, _State) ->
    ok.
    
subscribe(EventType) ->
    %% Gproc notation: {p, l, Name} means {(p)roperty, (l)ocal, Name}
    gproc:reg({p, l, {?MODULE, EventType}}).

notify(EventType, Msg) ->
    Key = {?MODULE, EventType},
    gproc:send({p, l, Key}, {self(), Key, Msg}).

