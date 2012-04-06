Example of a Hello World web app with simple_bridge and Cowboy

	./rebar get-deps
	./rebar compile

	erl -pa ebin -pa /debps/*/ebin -boot start_sasl
	application:start(crypto).
	application:start(sb).
	
