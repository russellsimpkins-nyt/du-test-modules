DEFAULT:
	composer dumpautoload
	$(MAKE) -C src

compile: DEFAULT

docs: FORCE
	rm -rf output && vendor/bin/phpdoc run -d src 
	if [ -d /usr/src/iodocs/public/data ]; then mv docs.json /usr/src/iodocs/public/data; fi

d: docs

test:
	vendor/bin/codecept run --debug -vvv unit
	vendor/bin/run-phpcs

t: test

# Run unit tests and code sniffer.
test_unit:
	vendor/bin/codecept run --debug -vvv unit
	vendor/bin/run-phpcs

test_dev:
	vendor/bin/codecept run functional --env dev $(test)

test_stg:
	vendor/bin/codecept run functional --env stg $(test)

test_prd:
	vendor/bin/codecept run functional --env prd $(test)


test_dev_debug:
	vendor/bin/codecept run functional --debug --env dev $(test)

test_stg_debug:
	vendor/bin/codecept run functional --debug --env stg $(test)

test_prd_debug:
	vendor/bin/codecept run functional --debug --env prd $(test)


# if your code is too complex phpmd will return with a non-zero and I don't want this to fail yet
# that's why I have the phpmd in an or
coverage:
	vendor/bin/codecept run --xml --coverage-xml --coverage-html --report unit
	vendor/bin/phpmd src xml codesize naming unusedcode > tests/_log/pmd.xml | true
	vendor/bin/phpmd src html codesize naming unusedcode > tests/_log/pmd.html | true

c: coverage

update:
	composer update

u: update

selfupdate:
	composer selfupdate
	composer update

clean:
ifneq ($(DESTDIR), )
	if [ -d $(DESTDIR) ]; then rm -rf $(DESTDIR); fi
else
	@echo "This target normally used when packaging. usage: make clean DESTDIR=/install/destination"
endif

install:
ifeq ($(DESTDIR), )
	@echo "You failed to set DESTDIR. usage: make install DESTDIR=/install/destination"
else
	if [ -d vendor ]; then rm -rf vendor; fi
	rm -f composer.lock
	composer install --no-dev
	mkdir -p $(DESTDIR)/var/nyt/apis/du-test-modules
	rsync -a --exclude-from=.rsync-excludes  . $(DESTDIR)/var/nyt/apis/du-test-modules
endif

i: install

help:
	@echo "make\n - runs php lint on all php files in src"
	@echo "make update\n - runs composer update"
	@echo "make selfupdate\n - runs composer update and selfupdate"
	@echo "make coverage\n - runs phpmd and codeception code coverage reports"
	@echo "make test\n - runs unit tests and php code sniffer"
	@echo "make test_unit\n - runs unit tests"
	@echo "make test_dev\n - runs functional tests on QA environment"
	@echo "make test_stg\n - runs functional tests on staging environment"
	@echo "make test_prd\n - runs functional tests on production environment"
	@echo "make test_dev_debug\n - runs functional tests on QA environment with debug output"
	@echo "make test_stg_debug\n - runs functional tests on staging environment with debug output"
	@echo "make test_prd_debug\n - runs functional tests on production environment with debug output"
	@echo "make docs\n - runs the phpdocumentor to generate docs"
	@echo "make install\n - cleans up and moves all required code into DESTDIR"

h: help

FORCE:
