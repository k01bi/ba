fileA="fileA.txt"
fileB="fileB.txt"

function test1 {
  printf "Lines different in $fileA:"
  grep -vxF -f $fileB $fileA
  printf "\nLines different in $fileB:"
  grep -vxF -f $fileA $fileB
}

function test2 {
  var=$(sed -n '10p' < $fileA)
  printf "$var\n"
}

function compareToOtherFile () {
  firstLine=$1
  lines=$2
  lastLine=$3

  compFile=$4
  compLines=''

  n=$(cat "$compFile" | wc -l)

  for (( i=1; i<=$n; i++ ))
  do

    line=$(sed "${i}q;d" "$compFile")

    if [[ $line==$firstLine ]]
    then

      compLines="$line"

      for (( j=$i; j<=$n; j++ ))
      do

        compLine=$(sed "${i}q;d" "$compFile")

        if [[ $compLine != $lastLine || $compLine != '#'* ]]
        then

          compLines="$compLines"+"\n"+"$compline"

        else if [[ $compLine == '#'* || $i == $n ]]
        then

          if [[ $compLines != $lines ]]
          then

            printf "The following lines differ in these two files:\n\n"
            printf "$lines"+"\n\n"
            printf "$compLines"+"\n"

          fi

          $j=$n+1

        else if [[ $compLine == $lastLine ]]
        then

          compLines="$compLines"+"\n"+"$compline"

          if [[ $compLines != $lines ]]
          then

            printf "The following lines differ in these two files:\n\n"
            printf "$lines"+"\n\n"
            printf "$compLines"+"\n"

          fi
          $j=$n+1

	fi

      done

    else

      compLines=''

    fi

  done

}

function compareFiles () {
  firstFile=$1
  compareFile=$2

  firstLine=''
  lines=''

  n=$(cat "$firstFile" | wc -l)
  for  (( i=1; i<=$n; i++ ))
  do
    line=$(sed "${i}q;d" "$firstFile")

    if [[ $line == "#"* || $i == $n ]]
    then
      firstLine=''
      lines=''
      lastLine=$line
      compareToOtherFile $firstLine $lines $lastLine $compareFile
    else
      if [[ $firstLine == '' ]]
      then
        firstLine="$line"
      fi
      lines="$lines"+"\n"+"$line"
    fi
  done
}

compareFiles $fileA $fileB


