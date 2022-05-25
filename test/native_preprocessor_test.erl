-module(native_preprocessor_test).

-export([]).

-include_lib("eunit/include/eunit.hrl").

% this module will be redundant when the gleam stdlib will introduce test timeout parameter  

always_pass_test_() ->
    {timeout, 3000, ?_assertEqual(1, 1)}.

just_created_preprocessor_json_test_() ->
    {timeout, 3000, 
        ?_assertEqual(
            preprocessor_test:my_preprocessor_json(), 
            preprocessor_test:just_created_preprocessor_json()
        )
    }.

just_created_preprocessor_of_to_json_test_() ->
    {timeout, 3000, 
        ?_assertEqual(
            preprocessor_test:just_created_preprocessor_json(), 
            preprocessor_test:just_recreated_preprocessor_json()
        )
    }.

% heavy_load_experiment_test_() ->
%     {timeout, 3000, 
%         ?_assertEqual(
%             [],
%             heavy_load_experiment:run()
%         )
%     }.

% heavy_load_experiment_par_test_() ->
%     {timeout, 3000, 
%         ?_assertEqual(
%             [],
%             heavy_load_experiment:par_run()
%         )
%     }.
