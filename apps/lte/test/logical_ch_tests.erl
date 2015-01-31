-module(logical_ch_tests).

-include_lib("eunit/include/eunit.hrl").
-include_lib("eunit_fsm/include/eunit_fsm.hrl").

logical_ch_test_() -> 
    {timeout, 30,
     {setup, 
      fun setup/0,
      fun teardown/1,
      [{"LTE attach sequence", fun logic/0},
       {"SRB allocation", fun srb_connect/0}
      ]}}.


srb_connect() ->
    ok.

logic() ->
    ?assertEqual(ok, ok),
    catch exit(whereis(ue_srb_0), ok), 
    catch exit(whereis(enb_srb_0), ok), 
    {ok, _} = ue_srb:start_link(0),
    {ok, _} = enb_srb:start_link(0), 
    ue_srb:send(ue_srb_0, <<"hello">> ),
    ok.

setup() ->
    error_logger:tty(false),
    application:ensure_all_started(lager).
    %% ok = application:start(asn1).


teardown(_) ->
    ok. 
%% = application:stop(asn1).               

