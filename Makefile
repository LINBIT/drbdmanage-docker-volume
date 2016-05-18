GIT = git
INSTALLFILES=.installfiles
override GITHEAD := $(shell test -e .git && $(GIT) rev-parse HEAD)

# U := $(shell ./setup.py versionup2date >/dev/null 2>&1; echo $$?;)

all:
	python setup.py build

drbdmanage-docker-volume.8.gz: README
	pandoc -s -t man README -o drbdmanage-docker-volume.8
	gzip -f drbdmanage-docker-volume.8

doc: drbdmanage-docker-volume.8.gz

install:
	python setup.py install --record $(INSTALLFILES)

uninstall:
	test -f $(INSTALLFILES) && cat $(INSTALLFILES) | xargs rm -rf || true
	rm -f $(INSTALLFILES)

release: clean doc
	python setup.py sdist
	@echo && echo "Did you run distclean?"

debrelease: clean doc
	echo 'recursive-include debian *' >> MANIFEST.in
	dh_clean
	make release
	git checkout MANIFEST.in

deb:
	[ -d ./debian ] || (echo "Your checkout/tarball does not contain a debian directory" && false)
	debuild -i -us -uc -b

# it is up to you (or the buildenv) to provide a distri specific setup.cfg
rpm:
	python setup.py bdist_rpm

clean:
	python setup.py clean

distclean: clean
	git clean -d -f || true
