#!/usr/bin/env bash

# Define global variable here
package_name=""
package_url=""

# TODO: Add required and additional packagenas dependecies 
# for your implementation
declare -a dependecies=("unzip" "wget" "curl" "git" "gcc" "make")

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

# functions to maken install easier
# maak de map aan voor de package
function create_installation_directory() {
    pwd
    if [ ! -d "$locatie" ]; then
        mkdir -p "$locatie"
    fi
    # ga dan gelijk naar de map waar het geinstalleerd moet worden
    cd "$locatie" || { handle_error "kan niet switchen naar $locatie";}
}

# Hier download je de package van git, indien dit niet kan push je handle_error
function download_package() {
    pwd
    if ! wget "$package_url" ; then
        handle_error "kan $package niet downloaden vanuit: $package_url"
    fi
}

# hier unzip je de package, indien dit niet lukt gooi je een error
function unzip_package() {
    pwd
    local package_file="$(basename "$package_url")"
    if ! unzip -q "$package_file" ; then
        rm "$package_file"
        handle_error "kan $package niet unzippen"
    fi
}
# voor conf
# hier instaleer je het ook echt
function install_nosecrets() {
    # ga naar de juiste map
    cd ./no-more-secrets-master
    pwd
    make nms
    if [ $? -eq 0 ]; then
        echo "'make nms' gelukt."
    else
        handle_error "'make nms' gevaald."
    fi
    sudo make install
    if [ $? -eq 0 ]; then
        echo "'make install' gelukt."
    else
        handle_error "'make install' gevaald."
    fi
}

function install_pywebserver() {
    pwd
    sudo chmod +x "webserver-master/webserver"
    if [ $? -eq 0 ]; then
        echo "pywebserver geconfigureerd"
    else
        handle_error "kan de server niet configureren"
    fi
}

function install_package() {
    # Do not remove next line!
    echo "function install_package"

    # TODO The logic for downloading from a URL and unizpping the downloaded files of different applications must be generic (done)

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
    local package="$1"
    local functie="$2"

    if [ "$functie" == "--install" ]; then
        case "$package" in
            "nosecrets")
                package_url="$APP1_URL"
                locatie="$INSTALL_DIR/$package"
                create_installation_directory
                download_package
                unzip_package
                install_nosecrets
                ;;
            "pywebserver")
                package_url="$APP2_URL"
                locatie="$INSTALL_DIR/$package"
                create_installation_directory
                download_package
                unzip_package
                install_pywebserver
                ;;
            *)
                handle_error "package niet bekend: $package"
                exit 1
                ;;
        esac

        echo "$package is installed at: $locatie"
    else
        handle_error "--install is verplicht!"
    fi
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
    ./apps/pywebserver/webserver-master/webserver $WEBSERVER_IP:$WEBSERVER_PORT &
	# lees de process id om het later te kunnen killen
	webserver_pid=$!
	sleep 2 # wacht om zeker te zijn dat de server is opgestart
	# maak een post request om te testen of de server werkt
	echo "Requesting the server..."
	resp=$(curl -X POST -o /dev/null -w "%{http_code}" -H "Content-Type: application/json" --data @test.json "http://$WEBSERVER_IP:$WEBSERVER_PORT")
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
    if [ "$1" != "setup" ] && [ "$1" != "nosecrets" ] && [ "$1" != "pywebserver" ] && [ "$1" != "remove" ]; then
        handle_error "The first argument should be on of these 4: 'setup'/'nosecrets'/'pywebserver'/'remove'"
        # should exit if not one of the give arguments on first place (word gedaan door handle error)
    fi
    # Check if the second argument is provided on the command line
    # Check if the second argument is valid
    # allowed values are "--install" "--uninstall" "--test"
    # bash must exit if value does not match one of those values
    if [ "$2" != "--install" ] && [ "$2" != "--uninstall" ] && [ "$2" != "--test" ]; then
        handle_error "The second argument should be on of these 3: '--install'/'--uninstall'/'--test'"
        # should exit if not one of the give arguments on first place
        exit 1
    fi
    # echo "gj"
    # Execute the appropriate command based on the arguments
    # TODO In case of setup
    # excute the function check_dependency and provide necessary arguments
    # expected arguments are the installation directory specified in dev.conf

}

# Pass commandline arguments to function main
# main "$@"
setup # dit is voor testen!
# Check the command line arguments
if [ "$#" -ne 2 ]; then
    handle_error "Usage: $0 <package> --install"
fi

package="$1"
functie="$2"

test_pywebserver "$package" "$functie" 