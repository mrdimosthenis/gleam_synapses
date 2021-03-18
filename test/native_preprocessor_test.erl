-module(native_preprocessor_test).

-export([]).

-include_lib("eunit/include/eunit.hrl").

always_pass_test_() ->
    {timeout, 300, ?_assertEqual(1, 1)}.

just_created_preprocessor_json_test_() ->
    {timeout, 300, 
        ?_assertEqual(
            preprocessor_test:my_preprocessor_json(), 
            preprocessor_test:just_created_preprocessor_json()
        )
    }.

just_created_preprocessor_of_to_json_test_() ->
    {timeout, 300, 
        ?_assertEqual(
            preprocessor_test:just_created_preprocessor_json(), 
            preprocessor_test:just_recreated_preprocessor_json()
        )
    }.

