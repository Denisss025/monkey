#!/bin/bash
# Tests starting with x are expected to fail

export LANG=C

GREEN="$(echo -e '\033[1;32m')"
YELLOW="$(echo -e '\033[0;33m')"
RED="$(echo -e '\033[1;31m')"
NORMAL="$(echo -e '\033[0;39m')"

CFLAGS="$CFLAGS -I ../../include/monkey"
LDFLAGS="$LDFLAGS -L../../src/ -Wl,-rpath=../../src/ -lmonkey -lpthread"

[ -z "$CC" ] && CC=gcc

# Check that we can run the tests
if [ ! -f ../../src/libmonkey.so ]; then
	echo -e "\n${YELLOW}Please build and install the library first.\n"

	echo "The tests will link against the source dir, but the library"
	echo "expects to find the plugins in the plugindir (installed plugins)"
	echo $NORMAL
	exit
fi

# Check liana plugin is in place
if [ ! -f ../../plugins/liana/monkey-liana.so ]; then
    echo "Please compile the liana plugin"
    exit
fi
cp ../../plugins/liana/monkey-liana.so ../../plugins/monkey-liana.so

# Precompile the header for faster builds
$CC ../../include/monkey/libmonkey.h

success=0
fail=0

if [ $# == 0 ]; then
    echo "Running all tests; use './run-tests.sh ip-ban.c url-ban.c' to run a subset"
    tests=*.c
else
    echo "Running tests $@"
    tests=$@
fi

rm -rf bin/ && mkdir bin/

for src in $tests; do
	[ ! -f "$src" ] && exit

	test=${src%.c}
	log=${test}.log

	ret=0
	case $test in x*) ret=1 ;; esac

	echo -n "Building test $test... "
	$CC $CFLAGS $src -o bin/$test $LDFLAGS

	if [ $? -ne 0 ]; then
		fail=$((fail + 1))
		echo "${RED}Failed to build $NORMAL"
		continue
	fi

	bin/$test > $log
	if [ $? -ne $ret ]; then
		fail=$((fail + 1))
		echo "${RED}Failed $NORMAL"
	else
		success=$((success + 1))
		echo "$GREEN OK $NORMAL"
		rm -f $log
	fi

	# If empty, remove
	[ ! -s "$log" ] && rm -f $log
done

# Remove the PCH
rm ../../include/monkey/libmonkey.h.gch

echo

total=$((fail + success))
percentage=$(awk "BEGIN{print int($success/$total * 100)}")

[ $fail -eq 0 ] && echo "$GREEN	All tests passed!"
[ $fail -ne 0 -a $percentage -ge 60 ] && echo "$YELLOW	$percentage% passed, $fail/$total fails"
[ $percentage -lt 60 ] && echo "$RED	$percentage% passed, $fail/$total fails"

echo $NORMAL
