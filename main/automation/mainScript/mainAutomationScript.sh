#!/bin/bash

# ----------------------------------------------------------------- #

# set the config file directory, that should be used for coan here
FILENAME=config.txt

# please use this command if you're using bash to run this script
CONFIG_FILE=$(<$FILENAME)

# and use this command instead if you're using sh for this script
#CONFIG_FILE="$(cat $FILENAME)"
#printf "%s" "$CONFIG_FILE"

# and set the folder of your project, that coan will be used on here
PROJECT_FOLDER="linux-master"

# ----------------------------------------------------------------- #

# this function calls itself recursively over a folder directory
function recursiveCoan {
	# first we check if coan has to be used on this directory
	# we check by looking for .h and .c files
	
	# hFiles is a boolean to check, if there are header files that can be processed by coan
	hFiles=false;
	# cFiles is also a boolean for a check, if there a c files
	cFiles=false;

	# now we go through the current directory, and check for both of those file types
	for file in ./*
	do
		# we check if there are any kind of files in this directory
		# -f checks if there is a file with the name of $file in this test
		if [[ -f $file ]]; then
			# so we check if this file has a filename that ends with .h
			# _	filenames will be in the format of ./filename.h , ./filename.c
			# _	etc... so we can check for filename endings
			if [[ $file == *.h ]]; then
				# if there are header files, we set the flag to true
				hFiles=true
			# if it instead has the filename ending with .c
			elif [[ $file == *.c ]]; then
				#if there are c files, we set the corresponding flag to true
				cFiles=true
			fi
		fi
	done

	# now we know which kind of coan commands we have to use
	# we have to look for c and h files each, because using a coan command, 
	# _	working with h and c files together, will give us errors if there are not
	# _	both kind of file types in this directory

	# so now we check our bool flags if we need to use the corresponding commands
	if [ $hFiles == true ]; then
		# for our header files and c files we use the same command but on 
		# _	different kinds of files as to stop errors
		coan source $CONFIG_FILE --keepgoing --gag warning --replace *.h
	fi
	if [ $cFiles == true ]; then
		coan source $CONFIG_FILE --keepgoing --gag warning --replace *.c
	fi

	# as a note to the commands of coan:
	# 1: the usage of our CONFIG_FILE variable allows us to use the text inside the file as our 		# _	define and undefine statements for coan. The reason for this instead of the
	# _	--file option is, that multiple instances of coan will want to read the same file,
	# _	which the std::in from c++, which coan uses forbids it due to buffers and locks
	# 2: the --gag warning option stops coan from printing each single assumption of
	# _	any define statement. These are always printed for any kind of define
	# _	that is not a part of our coan config
	# 3: --keepgoing will let the command continue, even if files have had errors in them.
	# _	Errors will still be displayed on console. Though errors appearing on the 
	# _	linux kernel have already been discussed in my bachelorspaper
	# 4: the --replace option will write the changes directly to the files.
	# _	So make sure you use this script on a backed up version of your project

	# finally, we use this function recursively on any directory inside the current.
	# _	So we go into each and call this function again for it.
	for dir in ./*
	do
		# read as: is there a directory with the name of $dir. $dir is just the name of a
		# _	thing inside this dir, which this for is iterating over
		if [ -d $dir ]; then
			# if it is a valid dir, we go in there
			cd $dir
			# and call this function again, thus working recursively
			recursiveCoan
		fi
	done
	
	# finally, since we don't need to stay inside this directory, we go back to the last dir
	cd ..
}



# ----------------------------------------------------------------- #

# here is supposedly our "main method"
# first we enter the user-given directory path:
cd $PROJECT_FOLDER

# then we call our recursive function for the first time:
recursiveCoan

# as to make it known, that we are finished, we print to console
printf "done\n"

# ----------------------------------------------------------------- #
