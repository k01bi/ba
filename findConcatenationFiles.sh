#!/bin/bash

pathCopy=/home/ba/Desktop/Bachelorarbeit/findError2/err2/copyErrorProneFiles
pathMain=/home/ba/Desktop/Bachelorarbeit/findError2/err2/linux-master

function printInterest {
	#go through all the things in a directory
	for thing in ./*
	do
		# if the thing is a folder go in and call this function
		if [ -d $thing ]; then
			# printf $thing
			cd $thing
			printInterest
			# after going through this directory, go back up
			cd ..
		# if its a file:
		elif [ -f $thing ]; then
			# go through each line
			while IFS='' read -r line || [[ -n "$line" ]]; do
				# if the line does have a #define statement and a ## in the same line
				if [[ $line == *"##"* && $line == "#define"* ]]; then
					# print the file name
					printf "## - $line $thing\n\n"
					# if the last two letters in the filename are either .c or .h, only then set the bool to true
					if [[ $thing == *".c" || $thing == *".h" ]]; then
						if [[ !(-f $pathCopy/$thing) ]]; then
							cp $thing $pathCopy/$thing
						fi
					fi
				fi
			done < $thing
		fi
	done
	#cd ..
}

cd $pathMain
if [ -d $pathCopy ]; then
printf "yes"
fi
printInterest
printf "done"
