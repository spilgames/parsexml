-module(parsexml).
-export([parse/1]).

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

trim(<<" ",Bin/binary>>) -> trim(Bin);
trim(<<"\n",Bin/binary>>) -> trim(Bin);
trim(<<"\t",Bin/binary>>) -> trim(Bin);
trim(<<"\r",Bin/binary>>) -> trim(Bin);
trim(Bin) -> Bin.

tag(<<"<", Bin/binary>>) ->
  [TagHeader1,Rest1] = binary:split(Bin, <<">">>),
  Len = size(TagHeader1)-1,

  case TagHeader1 of
    <<TagHeader:Len/binary, "/">> ->
      Tag = tag_header(TagHeader),
      {{to_atom(Tag), <<>>}, Rest1};
    TagHeader ->
      Tag = tag_header(TagHeader),
      case tag_content(Rest1, Tag) of
        {[], Rest2} ->
            {{to_atom(Tag), <<>>}, Rest2};
        {Content, Rest2} ->
            {{to_atom(Tag), Content}, Rest2}
      end
  end.

to_atom(Tag) ->
    binary_to_atom(Tag, latin1).

tag_header(TagHeader) ->
    hd(binary:split(TagHeader, [<<" ">>])).

tag_content(<<Blank,Bin/binary>>, Parent) when Blank == $  orelse Blank == $\n orelse Blank == $\r orelse Blank == $\t ->
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
