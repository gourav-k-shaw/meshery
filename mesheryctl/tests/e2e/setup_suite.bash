#!/usr/bin/env bash


install_mesheryctl() {
    echo "start: Install mesheryctl"
    curl -L https://meshery.io/install -s | PLATFORM=$1 bash -
    echo "done: Install mesheryctl"
}


create_auth_file() {
    echo "start: authentication configuration"
    if [ ! -d "$HOME/.meshery" ]
    then
        mkdir "$HOME/.meshery"
    fi

    # Generate auth file to comunicate with meshery server
    echo '{ "meshery-provider": "Meshery", "token": null }' | jq -c '.token = "'$MESHERY_PROVIDER_TOKEN'"' > "${HOME}/.meshery/auth.json"
    echo "done: authentication configuration"
}

port_forwarding() {
    echo "start: Port forwarding"

    nohup kubectl -n meshery port-forward svc/meshery 9081:$(kubectl -n meshery get svc/meshery -o jsonpath='{.spec.ports[0].port}') &
    export MESHERY_SERVER_PORT_FORWARD_PID="$!"
    
    echo "done: Port forwarding"
}

main() {
    echo -e "### start: Test environment setup ###\n"

    install_mesheryctl "$MESHERY_PLATFORM"
    create_auth_file 
    port_forwarding
    
    export MESHERYCTL_BIN="mesheryctl"
    export MESHERY_CONFIG_FILE_PATH="${HOME}/.meshery/config.yaml"
	export MESHERY_AUTH_FILE="${HOME}/.meshery/auth.json"
    export E2E_HELPERS_PATH="${E2E_HELPERS_PATH}"
    export BATS_LIB_PATH="${BATS_LIB_PATH}"


    echo -e "\nCreate temp directory for test data"
    TEMP_DATA_DIR=`mktemp -d`
    # Expose the temp directory to the following tests
    export TEMP_DATA_DIR=$TEMP_DATA_DIR


    echo -e "### done: Test environment setup ###\n"
}


main
