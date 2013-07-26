-module(parsexml).
-export([parse/1]).

-define(IS_WHITESPACE(Char),
    Char == $ orelse
    Char == $\n orelse
    Char == $\r orelse
    Char == $\t
).

-type sxml() :: {atom(), binary() | [sxml()]}.

-spec parse(binary()) -> sxml().
parse(Bin) when is_binary(Bin) ->
    Bin1 = skip_declaration(Bin),
    {Tag, Rest} = tag(Bin1),
    <<>> = trim(Rest),
    Tag.

skip_declaration(<<"<?xml", Bin/binary>>) ->
    [_,Rest] = binary:split(Bin, <<"?>">>),
    trim(Rest),
    skip_declaration(Rest);

skip_declaration(<<"<!", Bin/binary>>) ->
    [_,Rest] = binary:split(Bin, <<">">>),
    trim(Rest);

skip_declaration(<<"<",_/binary>> = Bin) -> Bin;
skip_declaration(<<_,Bin/binary>>) -> skip_declaration(Bin).

trim(<<Blank,Bin/binary>>) when ?IS_WHITESPACE(Blank) ->
    trim(Bin);
trim(Bin) ->
    Bin.

tag(<<"<", Bin/binary>>) ->
    [TagHeader1,Rest1] = binary:split(Bin, <<">">>),
    Len = size(TagHeader1)-1,

    case TagHeader1 of
        <<TagHeader:Len/binary, "/">> ->
            Tag = tag_header(TagHeader),
            {{to_atom(Tag), []}, Rest1};
        TagHeader ->
            Tag = tag_header(TagHeader),
            {Content, Rest2} = tag_content(Rest1, Tag),
            {{to_atom(Tag), Content}, Rest2}
    end.

tag_header(TagHeader) ->
    hd(binary:split(TagHeader, [<<" ">>])).

tag_content(<<Blank,Bin/binary>>, Parent) when ?IS_WHITESPACE(Blank) ->
    tag_content(Bin, Parent);
tag_content(<<"</", Bin1/binary>>, Parent) ->
    Len = size(Parent),
    <<Parent:Len/binary, ">", Bin/binary>> = Bin1,
    {[], Bin};
tag_content(<<"<",_/binary>> = Bin, Parent) ->
    {Tag, Rest1} = tag(Bin),
    {Content, Rest2} = tag_content(Rest1, Parent),
    {[Tag|Content], Rest2};
tag_content(Bin, Parent) ->
    [Text, Rest] = binary:split(Bin, <<"</",Parent/binary,">">>),
    {Text,Rest}.

to_atom(Tag) ->
    binary_to_atom(Tag, latin1).
