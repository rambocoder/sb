-module(hello).
-export([start/0, loop/1]).


start() ->

    Options = [{ip, "127.0.0.1"}, {port, 8000}],

    Loop = fun loop/1,

    mochiweb_http:start([{name, mochiweb_example_app}, {loop, Loop} | Options]).



response(Req, Root) ->

    simple_bridge:make_response(mochiweb_response_bridge, {Req, Root}).



response_ok(Req, Root, ContentType, Data) ->

    Response = response(Req, Root),

    Response1 = Response:status_code(200),

    Response2 = Response1:header("Content-Type", ContentType),

    Response3 = Response2:data(Data),

    Response3:build_response().



loop(Req) ->

    HTML = ["<h1>Hello, World!</h1>"],

    response_ok(Req, "./wwwroot", "text/html", HTML).
