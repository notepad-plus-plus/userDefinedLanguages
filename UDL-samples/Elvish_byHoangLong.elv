# UDL sample for Notepad++ Elvish syntax highlighting and Function List.
# Open this file after installing the UDL and Function List parser.

use str

var greeting = "Xin chao"
var names = [Ada Grace Linus]
var settings = [&punctuation=! &enabled=$true]

fn greet {|name|
    echo $greeting", "$name$settings[punctuation]
}

fn describe {|value|
    if (str:has-suffix $value .elv) {
        echo $value" is an Elvish file"
    } else {
        echo "value: "$value
    }
}

for name $names {
    greet $name
}

put $names | each {|name|
    echo "Hello, "$name
}

try {
    fail "sample error"
} catch err {
    echo $err[reason]
} finally {
    echo "finished"
}