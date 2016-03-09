#!/bin/bash

usage() {
    echo "runt-tests		-e --env    : specify the environment"
    echo "			-h --host   : specify the hosts to test e.g. du-qa"
    echo "			-i --header : specify the host header to test e.g. du.qa.nytimes.com"
    echo "			-s --suite  : specify the suite to run e.g. integration"
    echo "			-t --test   : specify the test to run e.g. someCept.php **optional"
    exit 1
}

# deal with getopt on mac osx
if [ -f /usr/local/opt/gnu-getopt/bin/getopt ]; then
    getopt=/usr/local/opt/gnu-getopt/bin/getopt
else
    getopt=getopt
fi

TEMP=$($getopt -o e:h:i:s:t: --long env:,host:,header:,suite:,test: -n 'run-tests' -- "$@")
if [ $? -ne 0 ]; then
    echo "parser problem"
    usage
fi
eval set -- "$TEMP"
# extract options and their arguments into variables.
while true ; do
    case "$1" in
        -e|--env)
            env=$2
            shift 2
            ;;
        -h|--host) 
            host=$2
            shift 2
            ;;
        -i|--header) 
            header=$2
            shift 2
            ;;
        -s|--suite) 
            suite=$2
            shift 2
            ;;
        -t|--test) 
            test=$2
            shift 2
            ;;
        --) shift ; break ;;
        *) echo "Internal error! $1 $2" ; exit 1 ;;
    esac
done

if [[ "${suite}" == "" || "${env}" == "" || "${host}" == "" ]]; then
    echo "missing required param(s)  env: $env suite: $suite host: $host"
    usage
fi

#echo "http://cloudhosts.prd.use1.nytimes.com/svc/cloudhosts/v1/ec2/${env}/tags/server/${host}.txt"


for e in $(curl "http://cloudhosts.prd.use1.nytimes.com/svc/cloudhosts/v1/ec2/${env}/tags/server/${host}.txt" 2>/dev/null |awk -F, '{print $5}'); do

    if [ "${header}" == "" ]; then
        header=$e
    fi

    echo TEST_HOST=$e TEST_HEADER=$header vendor/bin/codecept run $suite $test $@
    TEST_HOST=$e TEST_HEADER=$header vendor/bin/codecept run $suite $test $@


done
