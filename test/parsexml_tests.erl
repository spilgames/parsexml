-module(parsexml_tests).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).


parse_test_() ->
  [
  ?_assertEqual({html, []},
    parsexml:parse(<<"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<html></html>\n">>))
  ,?_assertEqual({html, []},
    parsexml:parse(<<"\n\n\n<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<html></html>\n">>))
  ,?_assertEqual({html, []},
    parsexml:parse(<<"\n<html></html>\n">>))
  ,?_assertEqual({html, []},
    parsexml:parse(<<"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<html ></html>\n">>))
  ,?_assertEqual({html, []},
    parsexml:parse(<<"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<html xmlns=\"w3c\"></html>\n">>))
  ,?_assertEqual({html, []},
    parsexml:parse(<<"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<html xmlns=\"w3c\" ></html>\n">>))
  ,?_assertEqual({html, []},
    parsexml:parse(<<"<html xmlns='w3c' />\n">>))
  ,?_assertEqual({html, []},
    parsexml:parse(<<"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<html/>\n">>))
  ,?_assertEqual({html, []},
    parsexml:parse(<<"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<html />\n">>))
  ,?_assertEqual({html, []},
    parsexml:parse(<<"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<html k=\"v\"/>\n">>))
  ,?_assertEqual({html, []},
    parsexml:parse(<<"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<html k=\"v\" />\n">>))
  ,?_assertEqual({html, []},
    parsexml:parse(<<"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<!DOCTYPE some_dtd SYSTEM \"example.dtd\">\n<html k=\"v\" />\n">>))
  ].

parse2_test() ->
  {ok, Bin} = file:read_file("../test/test1.xml"),
  ?assertEqual(
    {'p:program', [
      {'p:day', [
        {'p:item', []},
        {'p:item', <<"Morning &lt;chan&gt;,…">>}
      ]}
    ]},
  parsexml:parse(Bin)
  ).

parse3_test() ->
  {ok, Bin} = file:read_file("../test/test2.xml"),
  ?assertEqual(
    {envelope, [
        {envelope2, [
            {authenticate, [
                {hash, <<"hash">>},
                {password, <<"password">>}
            ]},
            {modify, [
                {gender, <<"m">>},
                {dob, <<"1988-03-14">>},
                {empty, []}
            ]},
            {alsoEmpty, []}
        ]}
    ]},
    parsexml:parse(Bin)
  ).
