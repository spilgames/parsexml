ParseXML -- without attributes!
===============================

This is an even more simplified version of https://github.com/maxlapshin/parsexml

Simplifications from the original version
-----
* drop all attributes completely (because some people use XML in a weird way)
* parse tags as atoms (because if you have an unbounded number of tag names,
  then you are in trouble anyway).
* don't wrap text values into lists
* use empty binaries for empty node values

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
