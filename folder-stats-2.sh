#!/bin/bash
# set some global variables initially to 0
filesCount=0
hiddenfilesCount=0
dirsCount=0
hiddendirsCount=0

# a function that will display and change permissions depending on arguments
function run_permissions {

    # if we are just listing permissions, "l" paramater is given
    if [[ "$2" = "l" ]]
    then
        # output the file/directory name with a total character length of
        # 65 - the rest of the characters will be padded spaces
        printf '%-65s' "   $1: "

        # output the permissions (first 10 characters of detailed listing)
        # the 'd' aspect applies only to current file/directory as a file
        echo "$(ls -ld "$1" | head -c 10)"
    fi

    # if to change, "c" parameter is given
    if [[ "$2" = "c" ]]
    then
        # if the format is a file, and permissions are incorrect
        if [[ -f "$1" ]] && [[ "$(ls -ld "$1" | head -c 10)" != "-rw-r--r--" ]]
        then
            # inform user that it's wrong
            echo "File "$1" has the wrong permission: $(ls -ld "$1" | head -c 10)"

            # change it using octal chmod function
            chmod 644 "$1"

            # inform user of the change
            echo "This has been changed to: -rw-r--r--"
        fi


        # if the format is a directory, and permissions are incorrect
        if [[ -d "$1" ]] && [[ "$(ls -ld "$1" | head -c 10)" != "drwxr-xr-x" ]]
        then
            # inform user that it's wrong
            echo "Directory "$1" has the wrong permission: $(ls -ld "$1" | head -c 10)"

            # change it using octal chmod function
            chmod 755 "$1"

            # inform user of the change
            echo "This has been changed to: drwxr-xr-x"
        fi
    fi
}

# a function that will traverse a directory
function check_dir {
    # for each regular file/directory in this directory (argument passed)
    for i in "$1"/*
    do
        # if this particular file/directory is a file
        if [[ -f "$i" ]]
        then
            # pass the file to run_permissions - this will carry out the
            # required action if the parameter corresponds
            run_permissions "$i" $2

            # keep track of the regular file count, adding 1
            filesCount=$(expr $filesCount + 1)
        fi

        # if this particular file/directory is a directory
        if [[ -d "$i" && "$i" != "$1/." && "$i" != "$1/.." ]]
        then
            # pass the directory to run_permissions - this will carry out the
            # required action if the parameter corresponds
            run_permissions "$i" $2

            # keep track of the regular directory count, adding 1
            dirsCount=$(expr $dirsCount + 1)

            # now traverse this directory (this is a recursive function)
            check_dir "$i" $2
        fi
    done

    # for each hidden file/directory in this directory (argument passed)
    for j in "$1"/.*
    do
        # if this particular file/directory is a file
        if [[ -f "$j" ]]
        then
            # pass the file to run_permissions - this will carry out the
            # required action if the parameter corresponds
            run_permissions "$j" $2

            # keep track of the hidden file count, adding 1
            hiddenfilesCount=$(expr $hiddenfilesCount + 1)
        fi

        # if this particular file/directory is a directory
        if [[ -d "$j" && "$j" != "$1/." && "$j" != "$1/.." ]]
        then
            # pass the directory to run_permissions - this will carry out the
            # required action if the parameter corresponds
            run_permissions $j $2

            # keep track of the hidden directory count, adding 1
            hiddendirsCount=$(expr $hiddendirsCount + 1)

            # now traverse this directory (this is a recursive function)
            check_dir "$j" $2
        fi
    done
}

# the main function to be run
function main {
    # if a slash appended, remove this and assign to mainDir
    # otherwise, proceed with the file as i is
    mainDir=$1
    if [[ "${1: -1}" = "/" ]]
    then
        # this command below strips the final character of the string given
        mainDir=${1::-1}
    fi

    # second argument does not correspond to any of the conditional statements
    # in the function, so it will be ignored
    check_dir $mainDir "n"

    # display each of the counts after they have been added to (global variables)
    echo "Files found: $filesCount (plus $hiddenfilesCount hidden)"
    echo "Directories found: $dirsCount (plus $hiddendirsCount hidden)"

    # add the counts together using the expr command
    echo "Total files and directories: $(expr $filesCount + $hiddenfilesCount + $dirsCount + $hiddendirsCount)"

    # display permissions for the entered directory, with the same padding
    # needed as the output format is different, and mainDir wouldn't be checked
    printf '%-65s' "Permissions for $mainDir: "
    echo "$(ls -ld $mainDir | head -c 10)"

    # check the rest of the directory, passing the relevant parameter
    check_dir $mainDir "l"

    # check entered directory if the permissions are incorrect
    run_permissions $mainDir "c"

    # check the rest of the directory, passing the relevant parameter
    check_dir $mainDir "c"
}

# run the main function, passing the global parameter
main $1

# finish and return with a successful exit code
exit 0
