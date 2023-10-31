#!/usr/bin/env bash

# Define global variable here
package_name=""
package_url=""

# alle benodigde dependencies ook van alle packages
declare -a dependecies=("unzip" "wget" "curl" "git" "gcc" "make")

function handle_error() {
    # Do not remove next line!
    echo "function handle_error"

   echo "$1"
   echo "$2"

   exit 1
}
 
# Function to solve dependencies
function setup() {
    # Do not remove next line!
    echo "function setup"

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

	# check of nosecrets uberhaupt is geinstalleerd
	if [[ ! -d apps/nosecrets ]]; then
		handle_error "nosecrets is not installed" "Command to install: ./webserver_assignment.sh nosecrets --install"
	fi

	echo "Testing no more secrets..."
	ls -lah | nms & # resultaat om te kijken of het werkt
	result=$!
	echo "Checking the result..."
	# check het resultaat via de exit status van $result
	if [ $result -gt 0 ]; then
		echo "No more secrets is working"
		kill $result &
	else
		# als een error is gevonden echo dat
		echo "No more secrets is not working found an error: $result"
	fi
}

function test_pywebserver() {
    # Do not remove next line!
    echo "function test_pywebserver"    

	# check of pywebserver uberhaupt is geinstalleerd
	if [[ ! -d apps/pywebserver ]]; then
		handle_error "Pywebserver is not installed" "Command to install: ./webserver_assignment.sh pywebserver --install"
	fi

	# start de server met python en de goede port
	echo "Starting the server..."
	echo "Starting on host: $WEBSERVER_IP:$WEBSERVER_PORT"
	apps/pywebserver/webserver-master/webserver "$WEBSERVER_IP":"$WEBSERVER_PORT" &
	# lees de process id om het later te kunnen killen
	webserver_pid=$!
	echo "Waiting for server to start..."
	sleep 2 # wacht om zeker te zijn dat de server is opgestart
	# maak een post request om te testen of de server werkt
	echo "Requesting the server..."
	resp=$(curl -X POST -o /dev/null -w "%{http_code}" -H "Content-Type: application/json" --data @test.json "http://$WEBSERVER_IP:$WEBSERVER_PORT")
	echo "Checking server response..."
	# check de response van de server
	if [ "$resp" -eq 200 ]; then
		echo "Successfull response from server"
	else
		echo "Server not responding, error code: $resp"
	fi
	# stop de server
	echo "Killing server process"
	kill $webserver_pid
}

function uninstall_package() {
	local package=$1
	if [[ $package == "nosecrets" ]]; then
		uninstall_nosecrets
	else
		uninstall_pywebserver
	fi
}

function uninstall_nosecrets() {
    # Do not remove next line!
    echo "function uninstall_nosecrets"  

	# ga naar nosecrets
	cd apps/nosecrets/no-more-secrets-master || handle_error "nosecrets is not installed therefore can't be uninstalled"
	# voer de uninstall uit
	echo "uninstalling nosecrets..."
	sudo make uninstall || handle_error "Uninstalling no more secrets not working"
	# ga terug naar de root directory
	# dit is echt super lelijk maar ja boeie
	cd ../../../
	# verwijder de nosecrets map
	echo "removing nosecrets app package..."
	rm -rf apps/nosecrets
}

function uninstall_pywebserver() {
    echo "function uninstall_pywebserver"    
	# alleen de package hoeft verwijderd te worden van pywebserver
	echo "uninstalling pywebserver..."
	rm -rf apps/pywebserver
}

#TODO removing installed dependency during setup() and restoring the folder structure to original state
function remove() {
    # Do not remove next line!
    echo "function remove"

    # Remove each package that was installed during setup
	if [ -d apps/nosecrets ]; then
		echo "uninstalling nosecrets..."
		uninstall_nosecrets || handle_error "Could not uninstall nosecrets"
	fi
	if [ -d apps/pywebserver ]; then
		echo "uninstalling pywebserver..."
		uninstall_pywebserver || handle_error "Could not uninstall pywebserver"
	fi
	echo "removing apps/..."
	rm -rf apps
}

function main() {
    # Do not remove next line!
    echo "function main"

	# haal de argv
	command_to_do=$1
	what_to_do=$2

	# check of de eerste is ingevuld en of daar de goede commands in zijn gezet
	case $command_to_do in
		"setup" | "nosecrets" | "pywebserver" | "remove");;
		*) handle_error "Invalid command for the first argument!" ;;
	esac

	# check of wat je doet ook meegegeven word als dat zo is check of het iets is wat kan
	if [[ ! $what_to_do -eq "" ]]; then
		case $what_to_do in
			"--install" | "--uninstall" | "--test");;
			*) handle_error "Invalid command for the second argument!" ;;
		esac
	fi

	# de logica om te bepalen wat je gaat doen met welke functie
	case $command_to_do in
		"setup") setup ;;
		"remove") remove ;;
		"nosecrets")
			setup # run setup altijd want je hebt het nodig voor de rest
			if [[ $what_to_do == "--install" ]]; then
				install_package "$command_to_do" "$what_to_do"
			elif [[ $what_to_do == "--uninstall" ]]; then
				uninstall_package "$command_to_do"
			else
				test_nosecrets
			fi
		;;
		"pywebserver")
			setup # run setup altijd want je hebt het nodig voor de rest
			if [[ $what_to_do == "--install" ]]; then
				install_package "$command_to_do" "$what_to_do"
			elif [[ $what_to_do == "--uninstall" ]]; then
				uninstall_package "$command_to_do"
			else
				test_pywebserver
			fi
		;;
	esac
}


main "$@"

