%% #!/usr/bin/swipl -q
%% -*- mode: prolog; coding: utf-8; -*-
%%
%% $Id$
%%

:- use_module(helloworld).

%% http client
:- use_module(library(http/http_open)).
:- use_module(library(http/http_client)).
:- use_module(library(http/http_ssl_plugin)).
:- use_module(library(http/http_sgml_plugin)).
:- use_module(library(xpath)).

%% http server
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/json_convert)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_error)).
:- use_module(library(http/http_log)).

%% start
%% :- initialization(main).

%%
%% main
%%
%% to stop the server:
%% ?- http_stop_server(8080,[]).
%%
main :-
    server(8080).

server(Port) :-
    http_server(http_dispatch, [port(Port)]),
    thread_get_message(stop).

%% signal handler
:- on_signal(hup, _, hup).

hup(_Signal) :-
    thread_send_message(main, stop),
    halt(0).

:- http_handler('/', handler, [methods([get])]).


handler(_Request) :-
    format('Content-type: text/plain~n~n'),
    /* format('~w~n~n', [Request]),
    member(method(Method), Request),
    format('Method = ~w~n', [Method]), */
    ( getenv('TARGET', TARGET)
      -> format('Hello World: ~w!~n', [TARGET])
      ;  format('Hello World: NOT SPECIFIED!~n', [])
    ),
    http_get('https://www.google.com/', DOM, [cert_verify_hook(cert_accept_any)]),
    %http_get('http://www.google.com/', DOM, []),
    xpath(DOM, //(title(normalize_space)), Title),
    format('Title: ~w~n', [Title]).

