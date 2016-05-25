GIT = git
INSTALLFILES=.installfiles
PYTHON = python2
override GITHEAD := $(shell test -e .git && $(GIT) rev-parse HEAD)

U := $(shell $(PYTHON) ./setup.py versionup2date >/dev/null 2>&1; echo $$?;)

all:
	$(PYTHON) setup.py build

drbdmanage-docker-volume.8.gz: README
	pandoc -s -t man README -o drbdmanage-docker-volume.8
	gzip -f drbdmanage-docker-volume.8

doc: drbdmanage-docker-volume.8.gz

install:
	$(PYTHON) setup.py install --record $(INSTALLFILES)

uninstall:
	test -f $(INSTALLFILES) && cat $(INSTALLFILES) | xargs rm -rf || true
	rm -f $(INSTALLFILES)

ifneq ($(U),0)
up2date:
	$(error "Update your Version strings/Changelogs")
else
up2date:
	$(info "Version strings/Changelogs up to date")
endif

release: clean up2date doc
	$(PYTHON) setup.py sdist
	@echo && echo "Did you run distclean?"

debrelease: clean up2date doc
	echo 'recursive-include debian *' >> MANIFEST.in
	dh_clean
	make release
	git checkout MANIFEST.in

deb:
	[ -d ./debian ] || (echo "Your checkout/tarball does not contain a debian directory" && false)
	debuild -i -us -uc -b

# it is up to you (or the buildenv) to provide a distri specific setup.cfg
rpm:
	$(PYTHON) setup.py bdist_rpm

clean:
	$(PYTHON) setup.py clean

distclean: clean
	git clean -d -f || true
