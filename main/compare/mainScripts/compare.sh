#!/bin/bash

# Them Big Boy Strats:
# go line=line first, since it takes less runtime
# if these are equal all the way through
# -> finish and say we are done
# -> if they are not equal line per line
# ---> that means that certain lines do not match ::

# :: enter fragment search
# get first fragment of code from first file
# then look for it in the other file. 
# -> if all fragment lines match in other script, 
# --->the code is the same.
# -> if they do not match anywhere in other file, 
# ---> printf the sucker because it is a different fragment in the code.
# do this for all fragments, then repeat fragment search with the files vice versa

## VARIABLES:
# file names so we know what to compare
fileA="fileA.txt"
fileB="fileB.txt"

# amount of lines both files have
fileAMaxLines=$(cat "$fileA" | wc -l)
fileBMaxLines=$(cat "$fileB" | wc -l)

# these vars are shared by functions:
# if files match line by line
matchLL=true


## FUNCTIONS:

# compares both files, FileA and B if they equal each other line by line.
# it changes the variable matchLL depending on if it matches or not.
function compareLineByLine {
	# if both line amounts are different, then there will certainly be no Line-by-Line match
	# printf "$fileAMaxLines $fileBMaxLines\n"
	if [[ $fileAMaxLines==$fileBMaxLines ]]; then
		# if they do match, check line by line, if even one is false, stop the checks.
		for (( i=1; ( i <= $fileAMaxLines && $matchLL == true ); i++)); do
			# get lines from both files at line number i
			lineA=$(sed "${i}q;d" "$fileA")
			lineB=$(sed "${i}q;d" "$fileB")
			# printf "$lineA $lineB\n"
			if [[ $lineA != $lineB ]]; then
				# if even one line doesn't match, set the variable to false
				matchLL=false
			fi
		done
	else
		# if both files have different amounts of lines, then they arent the same, duh
		matchLL=false
	fi
}

function searchFragment {
	# the fragment to test
	fragment=$1
	lineNumberOfFragment=$2
	# the file to look in for fragment
	fileToSearch=$3


	#change grep to own function
	# you get array, get line from 0, check in other file for line,
	# then similiarly to getFragments, search the next lines for the next lines from array
	# only if all match its in there, if not, its different

	# if there is a fragment, grep will give 1, else 0
	if grep -q $fragment "$fileToSearch"; then
		# if it finds the fragment
		printf ""
	else	
		# if it doesn't find the fragment
		# print the fragment
		printf "In Line: $lineNumberOfFragment\n$fragment\n\n"
	fi
}

# this function goes through a file and gets each fragment
# a fragment is code that is surrounded 
function getFragments {
	sourceFile=$1
	sourceMaxLines=$2
	otherFile=$3
	printf "Lines differing in $sourceFile:\n"

	# local variable to keep the current Fragement that is made
	currentFragment=""
	fragArray=()

	# go through the given source file line by line
	for (( i=1; i <= $sourceMaxLines; i++ )); do

		# get each line and put it into th lineS each iteration of the loop
		lineS=$(sed "${i}q;d" "$sourceFile")

		# if the current line is not a comment from the preprocessor
		if [[ $lineS != "#"* ]]; then

			# then go through the lines from here as j
			for (( j=$i; j <= $sourceMaxLines; j++ )); do
				# get the line again
				line=$(sed "${j}q;d" "$sourceFile")

				# if the next lines aswell as the start are not comments we put them in our fragment
				if [[ $line != "#"* ]]; then
					# printf "\n$line\n\n"
					# if the fragment isnt empty, add this line at the end
					if [[ $currentFragment != "" ]]; then
						currentFragment="$currentFragment\n$line"
						fragArray+=("$line")
					else # if it is empty, start with this line
						currentFragment="$line"
						fragArray+=("$line")
					fi
				fi
				printf "\n"
				for arg in ${fragArray[@]}; do
					printf "$arg"				
				done
				printf "\n"

				# if this is the last line of the file, stop search with the current fragment
				if [[ $j == $sourceMaxLines && currentFragment != "" ]]; then
					# call of search function
					
					searchFragment $currentFragment $j $otherFile
					currentFragment=""
					fragArray=()

				# if it is another comment, then the fragment is done
				elif [[ $line == "#"* ]]; then

					# start the search for this fragment in the other file
					searchFragment $currentFragment $j $otherFile

					# after that, set the fragment to an empty string
					# evaluation of the fragment happens in the searchFragment function
					currentFragment=""
					fragArray=()

					# and put the counter of the line to the current line
					# since we move additional lines with j, but stay on i, 
					# we dont want to create subfragments from our initial fragment
					i=$j
				fi
			done
		fi
		return 1
	done
}

function start () {
	compareLineByLine
	if [[ $matchLL != true ]]; then
		# call this function with both sourcefiles
		# with this we get different fragments from both sides
		getFragments $fileA $fileAMaxLines $fileB
		getFragments $fileB $fileBMaxLines $fileA
	else
		printf "Both files contain the same code\n"
	fi
}

# START OF MAIN SCRIPT CALL:

start



