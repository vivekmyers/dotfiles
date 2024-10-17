#!/bin/zsh

{
    conda env export --from-history | grep -v prefix
    conda env export | perl -lne '/pip:$/ and do { $pip = 1; }; $pip and print'
} | perl -lne '
    BEGIN {
        %cmap = split /[=<>]+|[[:space:]]/, `conda list --export | grep -o "^[^=]*=[^=]*"`;
        %pmap = split /[=<>]+|[[:space:]]/, `pip freeze | grep -v "@" | grep -o "^[^=]*==[^=]*"`;
    }
    /:$/ and do { $conda = 0; };
    /^dependencies:$/ and do { $conda = 1; print; next };
    /^ *- *pip:$/ and do { $pip = 1; print; next };
    $conda and s/^ *- *([\w\d-_]*)[^:+]*$/"  - ".$1."=".$cmap{$1}/e;
    $pip and do {
        s/^ *- *([\w\d-_]*)[^:+]*$/"    - ".$1."==".$pmap{$1}/e or next;
        exists $pmap{$1} or next;
    };
    /^prefix: / and do { last; };
    print;
'
