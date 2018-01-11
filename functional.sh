string.print() {
  printf '%s' "$1"
}

string.println() {
  printf '%s\n' "$1"
}

string.trim() {
  sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

string.split() {
  local _sep="$1"

  local _newline=$'\n'
  while read -r
  do
    string.println "${REPLY//$_sep/$_newline}"
  done
}

Chars() {
  local _string="$1"

  string.print "$_string" | sed -e 's/\(.\)/\1\n/g'
}

List() {
  for _elem in "$@"
  do
    string.println "$_elem"
  done
}

Option() {
  local _elem="$@"

  if ! [ -z "$_elem" ]
  then
    string.println "$_elem"
  fi
}

File() {
  local _path="$1"

  cat "$_path"
}

Variable() {
  local _variable="$1"

  if ! [ -z ${!_variable+x} ]
  then
    string.println "${!_variable}"
  fi
}

Array() {
  local _arr="$1"
  local _off=$(Option "$2" | stream.getOrElse 0)
  local _len=$(Option "$3" | (λ(){ eval string.println $\{#$_arr[@]\}; }; stream.orElse λ))

  for _i in $(seq $_off $(( $_off + $_len - 1 )))
  do
    local _elem=$_arr[$_i]
    string.println "${!_elem}"
  done
}

stream.isEmpty() {
  local _empty=true

  while read -r
  do
    string.println "$REPLY"
    _empty=false
  done

  $_empty
}

stream.getOrElse() {
  local _elem="$1"

  if stream.isEmpty
  then
    string.println "$_elem"
  fi
}

stream.orElse() {
  local _func="$1"

  if stream.isEmpty
  then
    (eval "$_func")
  fi
}

stream.ignore() {
  while read -r
  do
    :
  done
}

stream.map() {
  local _func="$1"

  while read -r
  do
    (eval "$_func \"$REPLY\"")
  done
}

stream.filter() {
  local _func="$1"

  while read -r
  do
    if $(eval "$_func \"$REPLY\"")
    then
      string.println "$REPLY"
    fi
  done
}

stream.filterNot() {
  local _func="$1"

  stream.filter "! $_func"
}

stream.nonEmpty() {
  while read -r
  do
    if ! [ -z "$REPLY" ]
    then
      string.println "$REPLY"
    fi
  done
}

stream.length() {
  local _length=0

  while read -r
  do
    _length=$(( $_length + 1 ))
  done

  string.println $_length
}

stream.get() {
  local _index="$1"

  local _i=0
  while read -r
  do
    if (( $_i == $_index ))
    then
      string.println "$REPLY"
      break
    fi
    _i=$(( $_i + 1 ))
  done
}

stream.indexOf() {
  local _elem="$1"

  local _i=0
  while read -r
  do
    if [ "$REPLY" == "$_elem" ]
    then
      string.println $_i
      break
    fi
    _i=$(( $_i + 1 ))
  done
}

stream.find() {
  local _func="$1"

  while read -r
  do
    if $(eval "$_func \"$REPLY\"")
    then
      string.println "$REPLY"
      break
    fi
  done
}

stream.zipWithIndex() {
  local _i=0
  while read -r
  do
    string.println "$REPLY $_i"
    _i=$(( $_i + 1 ))
  done
}

stream.zipWith() {
  local _func="$1"

  while read -r
  do
    local _elem=$REPLY
    eval "$_func \"$_elem\"" |
      (λ(){ string.println "$_elem $1"; }; stream.map λ)
  done
}

stream.grouped() {
  local _size=$(Option "$1" | stream.getOrElse 2)

  local _buffer[0]=""
  local _length=0
  while read -r
  do
    _buffer[$_length]="$REPLY"
    _length=$(( $_length + 1 ))
    if (( $_length >= $_size ))
    then
      Array _buffer 0 _length | stream.mkString " "
      _length=0
    fi
  done

  if (( $_length > 0 ))
  then
    Array _buffer 0 _length | stream.mkString " "
  fi
}

stream.sorted() {
  sort "$@"
}

stream.sortBy() {
  local _func2=$(List "$@" | stream.last)
  local _options=$(List "$@" | stream.dropRight 1 | stream.toList)

  local _buffer[0]=""
  local _length=0
  while read -r
  do
    _buffer[$_length]="$REPLY"
    _length=$(( $_length + 1 ))
  done

  Array _buffer 0 $_length |
    stream.zipWithIndex |
    (_lambda(){
      local _i=$(List $1 | stream.last)
      local _e=$(Chars "$1" | stream.dropRight $(( $(Chars "$_i" | stream.length) + 1 )) | stream.mkString)
      local _by=$(eval "$_func2 \"$_e\"")
      string.println "$_by $_i"
    }; stream.map _lambda) |
    stream.sorted -k1,1 $_options |
    (λ(){
      local _i=$(List $1 | stream.last)
      string.println "${_buffer[$_i]}"
    }; stream.map λ)
}

stream.first() {
  stream.take 1
}

stream.head() {
  stream.take 1
}

stream.last() {
  stream.takeRight 1
}

stream.tail() {
  stream.drop 1
}

stream.take() {
  local _take=$(Option "$1" | stream.getOrElse 1)

  while read -r
  do
    if (( $_take > 0 ))
    then
      string.println "$REPLY"
    else
      break
    fi
    _take=$(( $_take - 1 ))
  done
}

stream.drop() {
  local _drop=$(Option "$1" | stream.getOrElse 1)

  while read -r
  do
    if (( $_drop > 0 ))
    then
      _drop=$(( $_drop - 1 ))
    else
      string.println "$REPLY"
    fi
  done
}

stream.takeRight() {
  local _take=$(Option "$1" | stream.getOrElse 1)

  if (( $_take > 0 ))
  then
    local _buffer[0]=""
    local _pointer=-1
    local _length=0
    while read -r
    do
      _pointer=$(( ($_pointer + 1) % $_take ))
      _buffer[$_pointer]="$REPLY"
      if (( $_length < $_take )); then _length=$(( $_length + 1 )); fi
    done

    for i in $(seq 1 $_length)
    do
      _pointer=$(( ($_pointer + 1) % $_length ))
      string.println "${_buffer[$_pointer]}"
    done
  fi
}

stream.dropRight() {
  local _drop=$(Option "$1" | stream.getOrElse 1)

  if (( $_drop <= 0 ))
  then
    cat
  else
    local _buffer[0]=""
    local _pointer=-1
    local _length=0
    while read -r
    do
      _pointer=$(( ($_pointer + 1) % $_drop ))
      if (( $_pointer < $_length ))
      then
        string.println "${_buffer[$_pointer]}"
      fi
      _buffer[$_pointer]="$REPLY"
      if (( $_length < $_drop )); then _length=$(( $_length + 1 )); fi
    done
  fi
}

stream.takeWhile() {
  local _func="$1"

  while read -r
  do
    if $(eval "$_func \"$REPLY\"")
    then
      string.println "$REPLY"
    else
      break
    fi
  done
}

stream.dropWhile() {
  local _func="$1"

  local _take=false
  while read -r
  do
    if $_take || ! $(eval "$_func \"$REPLY\"")
    then
      _take=true
      string.println "$REPLY"
    fi
  done
}

stream.reverse() {
  local _buffer[0]=""
  local _length=0
  while read -r
  do
    _buffer[$_length]="$REPLY"
    _length=$(( $_length + 1 ))
  done

  while (( _length > 0 ))
  do
    _length=$(( $_length - 1 ))
    string.println "${_buffer[$_length]}"
  done
}

stream.repeat() {
  local times="$1"

  local _buffer[0]=""
  local _length=0
  while read -r
  do
    _buffer[$_length]="$REPLY"
    _length=$(( $_length + 1 ))
  done

  for _i in $(seq 1 $times)
  do
    local _index=0
    while (( _index < _length ))
    do
      string.println "${_buffer[$_index]}"
      _index=$(( $_index + 1 ))
    done
  done
}

stream.foldLeft() {
  local _acc="$1"
  local _func="$2"

  while read -r
  do
    _acc=$(eval "$_func \"$_acc\" \"$REPLY\"")
  done

  string.println "$_acc"
}

stream.intersperse() {
  local _elem="$1"

  local _first=true
  while read -r
  do
    if $_first
    then
      _first=false
    else
      string.println "$_elem"
    fi
    string.println "$REPLY"
  done
}

stream.prepend() {
  local _func="$1"

  eval "$_func" | while read -r
  do
    string.println "$REPLY"
  done

  while read -r
  do
    string.println "$REPLY"
  done
}

stream.append() {
  local _func="$1"

  while read -r
  do
    string.println "$REPLY"
  done

  eval "$_func" | while read -r
  do
    string.println "$REPLY"
  done
}

stream.mkString() {
  local _sep="$1"
  local _start="$2"
  local _end="$3"

  local _string="$_start"
  local _first=true
  while read -r
  do
    if $_first
    then
      _first=false
      _string="$_string$REPLY"
    else
      _string="$_string$_sep$REPLY"
    fi
  done

  string.println "$_string$_end"
}

stream.toString() {
  stream.mkString "" "" ""
}

stream.toList() {
  stream.mkString " " "" ""
}

stream.lines() {
  stream.mkString $'\n' "" ""
}