#!/bin/bash
# set some global variables initially to 0
filesCount=0
hiddenfilesCount=0
dirsCount=0
hiddendirsCount=0

# a function that will traverse a directory
function check_dir {
    # for each regular file/directory in this directory (argument passed)
    for i in "$1"/*
    do
        # if this particular file/directory is a file
        if [[ -f "$i" ]]
        then
            # keep track of the regular file count, adding 1
            filesCount=$(expr $filesCount + 1)
        fi
        if [[ -d "$i" && "$i" != "$1/." && "$i" != "$1/.." ]]
        then
            # keep track of the regular directory count, adding 1
            dirsCount=$(expr $dirsCount + 1)

            # now traverse this directory (this is a recursive function)
            check_dir $i
        fi
    done

    # if this particular file/directory is a directory
    for j in "$1"/.*
    do
        # if this particular file/directory is a file
        if [[ -f "$j" ]]
        then
            # keep track of the hidden file count, adding 1
            hiddenfilesCount=$(expr $hiddenfilesCount + 1)
        fi

        # if this particular file/directory is a directory
        if [[ -d "$j" && "$j" != "$1/." && "$j" != "$1/.." ]]
        then
            # keep track of the hidden directory count, adding 1
            hiddendirsCount=$(expr $hiddendirsCount + 1)

            # now traverse this directory (this is a recursive function)
            check_dir $j
        fi
    done
}

# the main function to be run
function main {
    # run the check_dir function
    check_dir $1

    # display each of the counts after they have been added to (global variables)
    echo "Files found: $filesCount (plus $hiddenfilesCount hidden)"
    echo "Directories found: $dirsCount (plus $hiddendirsCount hidden)"

    # add the counts together using the expr command
    echo "Total files and directories: $(expr $filesCount + $hiddenfilesCount + $dirsCount + $hiddendirsCount)"
}

# run the main function, passing the global parameter
main $1

# finish and return with a successful exit code
exit 0
