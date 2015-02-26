-module(logical_ch_tests).

-compile(export_all).

-include_lib("eunit/include/eunit.hrl").
-include_lib("eunit_fsm/include/eunit_fsm.hrl").

logical_ch_test_() ->
    {timeout, 30,
     {setup,
      fun setup/0,
      fun teardown/1,
      [
       %% {"LTE attach sequence", fun logic/0},
       {"SRB allocation", fun srb_connect/0}
      ]}}.    


logic() ->
     ok.

srb_connect() ->
    ?assertEqual(ok, ok), 
    EnbRrcEmu = spawn(logical_ch_tests,enb_srb_ch,[undefined]),
    ?debugFmt(">> EnbRrcEmu ~p",[EnbRrcEmu]),
    {ok, Pid} = enb_srb:start_link(0, EnbRrcEmu),
    EnbRrcEmu ! {enb_srb, Pid},
   
    UeId=1,
    {ok, Srb0} = ue_srb:start_link(0, UeId, self()),
    ue_srb:send(Srb0, 0,  <<"hello">> ),
    ok. 


enb_srb_ch(Srb0) ->
    receive 
        {enb_srb, Pid} -> 
            io:format(user, ">> srb_ch set owner ~p~n", [Pid]),
            enb_srb_ch(Pid);
        {ccch, RB, UeId, Data} ->
            io:format(user, ">> srb_ch on: SRB ~p from: UE: ~p data: ~p~n", [RB, UeId, Data]),
            enb_srb:send(Srb0, UeId, RB, Data)  
    end, 
    enb_srb_ch(Srb0). 
 

setup() ->
%    error_logger:tty(false),
    application:ensure_all_started(lager),
    catch exit(whereis(ue_srb_0), ok),
    catch exit(whereis(enb_srb_0), ok),
    ok.
    %% ok = application:start(asn1).

 
teardown(_) ->
    catch exit(whereis(ue_srb_0), ok),
    catch exit(whereis(enb_srb_0), ok),
    ok.
%% = application:stop(asn1).

