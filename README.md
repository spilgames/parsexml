ParseXML or "XML to proplist"
========

This is a dead-simple Erlang XML parser for super simple XML.
(Think: generated from JSON or similar -- no attributes, no namespaces, etc).

This is an even more simplified fork of https://github.com/maxlapshin/parsexml



Rationale
---------

Lots of projects/APIs now prefer JSON as their primary data format,
which implies that in lots of cases the XML variant does not use XML
attributes/namespacing/etc at all, hence most parsers are trying too
hard when parsing XML and thus are less performant. This parser solves
the problem by assuming the most simple possible XML form.

Simplifications from the original version
-----
* drop all attributes completely
* parse tags as atoms (because if you have an unbounded number of tag names,
  then you are in trouble anyway).
* don't wrap text values into lists
* use empty binaries for empty node values (TODO: review this idea)

Usage
-----

```
{Tag, Content} = parsexml:parse(Bin).
```

Example
-----

    > XML = <<"
        <?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <envelope>
            <envelope2>
                <authenticate>
                    <hash>hash</hash>
                    <password>password</password>
                </authenticate>
                <modify>
                    <gender>m</gender>
                    <dob>1988-03-14</dob>
                    <empty></empty>
                </modify>
                <alsoEmpty/>
            </envelope2>
        </envelope>
    ">>
    > parsexml:parse(XML).
        {envelope, [
            {envelope2, [
                {authenticate, [
                    {hash, <<"hash">>},
                    {password, <<"password">>}
                ]},
                {modify, [
                    {gender, <<"m">>},
                    {dob, <<"1988-03-14">>},
                    {empty, <<>>}
                ]},
                {alsoEmpty, <<>>}
            ]}
        ]}
