#!/bin/zsh

cp environment.yml environment.yml.bak

perl -i -lne '
    /^name:(.*)$/ and do {
        $cenv = $1;
        %cmap = split /[=<>]+|[[:space:]]/, `conda list -n $cenv --export | grep -Eo "^[^=]+=[^=]+"`;
        %pmap = split /[=<>]+|[[:space:]]/, `conda run -n $cenv pip freeze | grep -v "@" | grep -Eo "^[^=]*==[^=]*"`;
    };
    /:$/ and do { $conda = 0; };
    /^dependencies:$/ and do { $conda = 1; print; next };
    /^ *- *pip:$/ and do { $pip = 1; print; next };
    $conda and s#^ *- *([\w\d-_]+)([><=]+)?([\d\.]+)?(.*)$#(exists($cmap{$1}) ? 
        do {
            my $first = "  - ".$1."=";
            my $old = "  - ".$1.$2.$3.$4;
            $cmap{$1}=~m/^([01]\.\d+\.\d+|[2-9]+\.\d+)/ and
            $first.$1 or $old;
        }: "  - ".$1.$2.$3.$4)#e;
    $pip and s|^ *- *([\w\d-_]*)([^:+]*)$|"    - ".$1.(exists($pmap{$1}) ? "==".$pmap{$1} : $2)|e;
    /^prefix: / and last;
    print;
' ${1-environment.yml}

vimdiff environment.yml.bak environment.yml
rm environment.yml.bak
