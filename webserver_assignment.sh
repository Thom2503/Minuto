#!/usr/bin/env bash

# Define global variable here
package_name=""
package_url=""

# TODO: Add required and additional packagenas dependecies 
# for your implementation
declare -a dependecies=("unzip" "wget" "curl")

# TODO: define a function to handle errors
# This funtion accepts two parameters one as the error message and one as the command to be excecuted when error occurs.
function handle_error() {
    # Do not remove next line!
    echo "function handle_error"

   # TODO Display error and return an exit code
   echo "$1"
   echo "$2"

   exit 1
}
 
# Function to solve dependencies
function setup() {
    # Do not remove next line!
    echo "function setup"

    # TODO check if nessassary dependecies and folder structure exists and 
    # print the outcome for each checking step
	# loop door de packages heen om te kijken of ze werken door command -v te gebruiken
	for dep in "${dependecies[@]}"; do
		echo "Checking if $dep is installed..."
		# dit kijkt of de command werkt, het resultaat wat meestal help is wordt naar /dev/null
		# gestuurd met &>
		if ! command -v "$dep" &> /dev/null; then
			handle_error "$dep is not installed" "Install with 'sudo apt install $dep'"
		else
			echo "$dep is installed."
		fi
	done
	echo "Dependencies are installed"

	echo "Checking if dev.conf exists"
	source dev.conf || handle_error "dev.conf is non existent"

	echo "Checking folder structure..."
	if [ ! -d "$INSTALL_DIR" ]; then
		mkdir -p "$INSTALL_DIR" || handle_error "Couldn't create an apps directory"
		echo "Apps folder created"
	else
		echo "Apps folder exists"
	fi
    # TODO check if required dependency is not already installed otherwise install it
    # if a a problem occur during the this process 
    # use the function handle_error() to print a messgage and handle the error
	# ik snap oprecht deze comment niet (Thom)
}

# Function to install a package from a URL
# TODO assign the required parameter needed for the logic
# complete the implementation of the following function.
function install_package() {
    # Do not remove next line!
    echo "function install_package"

    # TODO The logic for downloading from a URL and unizpping the downloaded files of different applications must be generic

    # TODO Specific actions that need to be taken for a specific application during this process should be handeld in a separate if-else

    # TODO Every intermediate steps need to be handeld carefully. error handeling should be dealt with using handle_error() and/or rolleback()

    # TODO If a file is downloaded but cannot be zipped a rollback is needed to be able to start from scratch
    # for example: package names and urls that are needed are passed or extracted from the config file

    # TODO check if the application-folder and the url of the dependency exist
    # TODO create a specific installation folder for the current package

    # TODO Download and unzip the package
    # if a a problem occur during the this proces use the function handle_error() to print a messgage and handle the error

    # TODO extract the package to the installation folder and store it into a dedicated folder
    # If a problem occur during the this proces use the function handle_error() to print a messgage and handle the error

    # TODO this section can be used to implement application specifc logic
    # nosecrets might have additional commands that needs to be executed
    # make sure the user is allowed to remove this folder during uninstall

}

function rollback_nosecrets() {
    # Do not remove next line!
    echo "function rollback_nosecrets"

    # TODO rollback intermiediate steps when installation fails
}

function rollback_pywebserver() {
    # Do not remove next line!
    echo "function rollback_pywebserver"

    # TODO rollback intermiediate steps when installation fails
}

function test_nosecrets() {
    # Do not remove next line!
    echo "function test_nosecrets"

	echo "Testing no more secrets..."
	result=$(ls -lah | nms) # resultaat om te kijken of het werkt
	echo "Checking the result..."
	# check het resultaat via de exit status van $result
	if [ $? -eq 0 ]; then
		echo "No more secrets is working"
	else
		# als een error is gevonden echo dat
		echo "No more secrets is not working found an error: $result"
	fi
}

function test_pywebserver() {
    # Do not remove next line!
    echo "function test_pywebserver"    

	# start de server met python en de goede port
	echo "Starting the server..."
	python -m SimpleHTTPServer "$WEBSERVER_PORT" &
	# lees de process id om het later te kunnen killen
	webserver_pid=$!
	sleep 2 # wacht om zeker te zijn dat de server is opgestart
	# maak een post request om te testen of de server werkt
	echo "Requesting the server..."
	resp=$(curl -X POST -w "%{http_code}" -H "Content-Type: application/json" -d @test.json "https://$WEBSERVER_HOST:$WEBSERVER_PORT")
	echo "Checking server response..."
	# check de response van de server
	if [ $resp -eq 200 ]; then
		echo "Successfull response from server"
	else
		echo "Server not responding, error code: $resp"
	fi
	# stop de server
	echo "Killing server process"
	kill $webserver_pid
}

function uninstall_nosecrets() {
    # Do not remove next line!
    echo "function uninstall_nosecrets"  

    #TODO uninstall nosecrets application
	# kan nog niet testen maar als het goed is moet dit werken.
	cd apps/nosecrets && (sudo make uninstall || handle_error "Uninstalling no more secrets not working")
}

function uninstall_pywebserver() {
    echo "function uninstall_pywebserver"    
    #TODO uninstall pywebserver application
}

#TODO removing installed dependency during setup() and restoring the folder structure to original state
function remove() {
    # Do not remove next line!
    echo "function remove"

    # Remove each package that was installed during setup

}

function main() {
    # Do not remove next line!
    echo "function main"

    # TODO
    # Read global variables from configfile

    # Get arguments from the commandline
    # Check if the first argument is valid
    # allowed values are "setup" "nosecrets" "pywebserver" "remove"
    # bash must exit if value does not match one of those values
    # Check if the second argument is provided on the command line
    # Check if the second argument is valid
    # allowed values are "--install" "--uninstall" "--test"
    # bash must exit if value does not match one of those values

    # Execute the appropriate command based on the arguments
    # TODO In case of setup
    # excute the function check_dependency and provide necessary arguments
    # expected arguments are the installation directory specified in dev.conf

}

# Pass commandline arguments to function main
# main "$@"
setup # dit is voor testen!