DEB_DIR=$(DIST_DIR)/DEBIAN
ROOT_DIR=$(DIST_DIR)/usr

all: $(DEB_DIR)/control
	fakeroot dpkg-deb --build $(PACKAGE).deb $(DIST_DIR)
	lintian $(PACKAGE)

$(DEB_DIR)/control: control.in $(DEB_DIR)
	sed "s#@package@#$(PACKAGE_MNEMONIC)#g;\
		s#@version@#$(PACKAGE_VERSION)#g;\
		s#@arch@#$(ARCH)#g;\
		s#@depends@#$(PACKAGE_DEPENDS)#g" < $< > $@

$(DEB_DIR):
	mkdir -p $@

$(ROOT_DIR):
	mkdir -p $@

clean:
	rm -f $(DEB_DIR)/control
