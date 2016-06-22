-module(gate_conn).
-behaviour(gen_server).

-export([start_link/0,accept_loop/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
    terminate/2, code_change/3]).

-define(TCP_LISTEN_OPTIONS,[binary,{packet,2},{active,false},{reuseaddr,true}]).
-define(TCP_OPTIONS,[binary, {packet,2}, {active, true}, {send_timeout, 30000}, {send_timeout_close, true},{exit_on_close, true},{keepalive, false} ]).
-define(PORT,7000).

-record(state,{}).

start_link()->
    gen_server:start_link({local,?MODULE},?MODULE,[],[]).

accept_loop(LSocket,Pid)->
    case gen_tcp:accept(LSocket) of
        {ok,CSock} ->
            gen_tcp:controlling_process(CSock,Pid),
            gen_server:cast(gate_conn,{conn,CSock});
        {error,Reason}->
            Reason
    end,
    accept_loop(LSocket,Pid).

init([])->
    io:format("start init~n"),
    case gen_tcp:listen(?PORT,?TCP_LISTEN_OPTIONS) of
        {ok,LSocket}->
            io:format("listen success!~n"),
            spawn(gate_conn,accept_loop,[LSocket,self()]),
            {ok,#state{}};
        {error,Reason}->
            io:format("listen error!~n"),
            {stop,{Reason}}
    end.

handle_call(_Request,_From,State)->
    Reply = ok,
    {reply,Reply,State}.

handle_cast({conn,CSock},State)->
    io:format("new conn~n"),
    {ok, Mod} = inet_db:lookup_socket(CSock),
    true = inet_db:register_socket(CSock, Mod),
    prim_inet:setopts(CSock, ?TCP_OPTIONS),
    {noreply,State};

handle_cast(_Msg,State)->
    {noreply,State}.

handle_info({tcp,_Socket,Data},State)->
    io:format("recv tcp data ~p,~n",[Data]),
    {noreply,State};

handle_info(_Reason,State)->
    io:format("handle_info ~p\n",[_Reason]), 
   {noreply,State}.

terminate(_Reason,_State)->
    ok.

code_change(_OldVsn,State,_Extra)->
    {ok,State}.

handle_gate(Packet)->
    case Packet of
        <<>>->
            handle_conn();
        <<>>->
            handle_disconn();
        <<>>->
            handle_lostconn();
        <<>>->
            handle_data();
        _->
            io:format("illege packet")
    end.

handle_conn()->
    pass.

handle_disconn()->
    pass.

handle_lostconn()->
    pass.

handle_data()->
    pass.
