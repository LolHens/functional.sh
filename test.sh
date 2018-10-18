#!/usr/bin/env bash

source ./functional.sh

assert() {
  if [ ! "$2" == "$3" ]
  then
    println "Assertion \"$1\" failed! $2 is not $3"
    exit 1
  fi
}

assert "println" "$(println "test")" "test"
assert "trim" "$(string.trim "  test ")" "test"
assert "split" "$(string.split "a+b+c+d" "+" | stream.mkString , [ ])" "[a,b,c,d]"
assert "replace" "$(string.replace "aaa" "a" "b")" "baa"
assert "replaceAll" "$(string.replaceAll "aaa" "a" "b")" "bbb"
assert "regexReplace" "$(string.regexReplace "asdfasdf" "s.f" "b")" "abasdf"
assert "regexReplaceAll" "$(string.regexReplaceAll "asdfasdf" "s.f" "b")" "abab"
assert "Range" "$(Range 0 5 | stream.mkString , [ ])" "[0,1,2,3,4]"
assert "Range2" "$(Range -i 0 5 | stream.mkString , [ ])" "[0,1,2,3,4,5]"
assert "Chars" "$(Chars "test " | stream.mkString , [ ])" "[t,e,s,t, ]"
assert "List" "$(List "t" e s "t " | stream.mkString , [ ])" "[t,e,s,t ]"
assert "Option" "$(Option asdf | stream.getOrElse test)" "asdf"
array1[0]=t
array1[1]=e
array1[2]=s
array1[3]=t
array1[4]=" "
assert "Array" "$(Array array1 | stream.mkString , [ ])" "[t,e,s,t, ]"
assert "getOrElse" "$(Option | stream.getOrElse test)" "test"
assert "orElse" "$(Option asdf | (stream.orElse <(println "test")))" "asdf"
assert "orElse" "$(Option | (stream.orElse <(println "test")))" "test"
assert "if" "$(Option "test" | stream.if ! true | stream.mkString , [ ])" "[]"
assert "if2" "$(Option "test" | stream.if true | stream.mkString , [ ])" "[test]"
assert "identity" "$(Option "test" | stream.identity | stream.mkString , [ ])" "[test]"
assert "ignore" "$(Option "test" | stream.ignore | stream.mkString , [ ])" "[]"
assert "map" "$(List foo "bar " test longword | (F(){ Chars "$1" | stream.length; }; stream.map F) | stream.mkString , [ ])" "[3,4,4,8]"
assert "foreach" "$(List foo "bar " test longword | (F(){ Chars "$1" | stream.length; }; stream.foreach F) | stream.mkString , [ ])" "[]"
assert "filter" "$(List asdf abcde defg acorn | (F(){ [[ "$1" == a* ]]; }; stream.filter F) | stream.mkString , [ ])" "[asdf,abcde,acorn]"
assert "filterNot" "$(List asdf abcde defg acorn | (F(){ [[ "$1" == a* ]]; }; stream.filterNot F) | stream.mkString , [ ])" "[defg]"
assert "nonEmpty" "$(List asdf "" abcde " " defg acorn | stream.nonEmpty | stream.mkString , [ ])" "[asdf,abcde, ,defg,acorn]"
assert "length" "$(List asdf "" abcde " " defg acorn | stream.length)" "6"
assert "get" "$(List asdf "" abcde " " defg acorn | stream.get 4)" "defg"
assert "indexOf" "$(List asdf "" " abcde" " " defg acorn | stream.indexOf " abcde")" "2"
assert "indexOf" "$(List asdf "" " abcde" " " defg acorn | stream.indexOf " abcdefg")" "-1"
assert "startsWith" "$(List a bcd e | stream.startsWith a; println $?)" "0"
assert "startsWith" "$(List a bcd e | stream.startsWith e; println $?)" "1"
assert "endsWith" "$(List a bcd e | stream.endsWith e; println $?)" "0"
assert "endsWith" "$(List a bcd e | stream.endsWith a; println $?)" "1"
assert "contains" "$(List a bcd e | stream.contains a; println $?)" "0"
assert "contains" "$(List a bcd e | stream.contains bcd; println $?)" "0"
assert "contains" "$(List a bcd e | stream.contains e; println $?)" "0"
assert "contains" "$(List a bcd e | stream.contains b; println $?)" "1"
assert "find" "$(List asdf abcde defg acorn desk | (F(){ [[ "$1" == d* ]]; }; stream.find F) | stream.mkString , [ ])" "[defg]"
assert "zipWithIndex" "$(List asdf abcde defg acorn desk | stream.zipWithIndex | stream.mkString , [ ])" "[asdf 0,abcde 1,defg 2,acorn 3,desk 4]"
assert "zipWith" "$(List foo "bar " test longword | (F(){ Chars "$1" | stream.length; }; stream.zipWith F) | stream.mkString , [ ])" "[foo 3,bar  4,test 4,longword 8]"
assert "grouped" "$(List asdf abcde defg acorn desk | stream.grouped 3 | stream.mkString , [ ])" "[asdf abcde defg,acorn desk]"
assert "grouped" "$(List asdf abcde defg acorn desk test | stream.grouped 3 | stream.mkString , [ ])" "[asdf abcde defg,acorn desk test]"
assert "sorted" "$(List mnop asdf ijkl bcde fgh | stream.sorted | stream.mkString , [ ])" "[asdf,bcde,fgh,ijkl,mnop]"
assert "sortBy" "$(List test longword foo "bar " | (F(){ Chars "$1" | stream.length; }; stream.sortBy F) | stream.mkString , [ ])" "[foo,test,bar ,longword]"
assert "first" "$(Chars hello | stream.first | stream.mkString , [ ])" "[h]"
assert "head" "$(Chars hello | stream.head | stream.mkString , [ ])" "[h]"
assert "last" "$(Chars hello | stream.last | stream.mkString , [ ])" "[o]"
assert "init" "$(Chars hello | stream.init | stream.mkString , [ ])" "[h,e,l,l]"
assert "tail" "$(Chars hello | stream.tail | stream.mkString , [ ])" "[e,l,l,o]"
assert "take" "$(Chars hello | stream.take 3 | stream.mkString , [ ])" "[h,e,l]"
assert "drop" "$(Chars hello | stream.drop 2 | stream.mkString , [ ])" "[l,l,o]"
assert "takeRight" "$(Chars hello | stream.takeRight 4 | stream.mkString , [ ])" "[e,l,l,o]"
assert "dropRight" "$(Chars hello | stream.dropRight 2 | stream.mkString , [ ])" "[h,e,l]"
assert "takeWhile" "$(Chars hello | (F(){ [[ "$1" != "o" ]]; }; stream.takeWhile F) | stream.mkString , [ ])" "[h,e,l,l]"
assert "dropWhile" "$(Chars hello | (F(){ [[ "$1" != "l" ]]; }; stream.dropWhile F) | stream.mkString , [ ])" "[l,l,o]"
assert "reverse" "$(Chars hello | stream.reverse | stream.mkString , [ ])" "[o,l,l,e,h]"
assert "repeat" "$(Chars hello | stream.repeat 2 | stream.mkString , [ ])" "[h,e,l,l,o,h,e,l,l,o]"
assert "repeat" "$(Chars hello | stream.repeat 0 | stream.mkString , [ ])" "[]"
assert "foldLeft" "$(Chars hello | (F(){ println "$1$2"; }; stream.foldLeft "start" F))" "starthello"
assert "intersperse" "$(Chars hello | stream.intersperse "-" | stream.mkString , [ ])" "[h,-,e,-,l,-,l,-,o]"
assert "prepend" "$(Chars hello | stream.prepend 123 456 789 | stream.mkString , [ ])" "[123,456,789,h,e,l,l,o]"
assert "append" "$(Chars hello | stream.append 123 456 789 | stream.mkString , [ ])" "[h,e,l,l,o,123,456,789]"
assert "prependAll" "$(List hello | (stream.prependAll <(println "start")) | stream.mkString , [ ])" "[start,hello]"
assert "appendAll" "$(List hello | (stream.appendAll <(println "end")) | stream.mkString , [ ])" "[hello,end]"
assert "concat" "$(List hello | (stream.concat <(println "end")) | stream.mkString , [ ])" "[hello,end]"
assert "mkString" "$(Chars hello | stream.mkString , [ ])" "[h,e,l,l,o]"
assert "toString" "$(Chars hello | stream.toString)" "hello"
assert "toList" "$(Chars hello | stream.toList)" "h e l l o"
assert "lines" "$(Chars hello | stream.lines)" "h"$'\n'"e"$'\n'"l"$'\n'"l"$'\n'"o"
