#!/bin/bash

# testing function for recursively giving each folder and file name
function testing {
  # go through all things inside this directory
  for f in ./*
  do
    # if current thing is folder
    if [ -d $f ]; then
      # write that its a folder
      printf "dir: $f\n"
      # go into that folder
      cd $f
      # call this function again
      testing
    elif [ -f $f ]; then
      # if its a file, just say the files name
      printf "file: $f\n"
    fi
  done
  cd ..
}


#main coan test method
function coanBasic {
	#changes atleast one ifdef on line 35 inside drivers/hid/usbhid/usbmouse.c
	#coan source -DCONFIG_USB_HID_MODULE --gag error --replace *.c *.h

	# check if files in this folder are actuall c or h files
	# as to not use coan on an empty or unusable folder
	areThereFiles=false
	for files in ./*
	do
		if [[ -f $files && ( $files == *.c || $files == *.h ) ]]; then
			areThereFiles=true
		fi
	done
	# if there are usable files, use coan on them
	if [ $areThereFiles == true ]; then
		coan source -DCONFIG_USB_HID_MODULE -DCONFIG_KVM_VFIO --gag warning --replace *.c ./
		coan source -DCONFIG_USB_HID_MODULE -DCONFIG_KVM_VFIO --gag warning --replace *.h ./
	fi
	# if there is an directory in this folder, go in and use this method again
	for f in ./*
	do
		if [ -d $f ]; then
			printf "dir: $f\n"
			cd $f
			coanBasic
		fi
	done
	cd ..
}

cd linux-master
# call testing first time on current folder
#testing
coanBasic
#printInterest
printf "done\n"


