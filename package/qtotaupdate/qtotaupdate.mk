################################################################################
#
# qtotaupdate
#
################################################################################
QTOTAUPDATE_VERSION = master
QTOTAUPDATE_SITE = https://code.qt.io/qt/qtotaupdate.git
QTOTAUPDATE_SITE_METHOD = git

QTOTAUPDATE_DEPENDENCIES = qt-custom

QTOTAUPDATE_LICENSE = GPLv3+
QTOTAUPDATE_LICENSE_FILES = 	LICENSE.GPL3

define QTOTAUPDATE_EXTRACT_CMDS
    rm -rf $(@D)
    (git clone $(QTOTAUPDATE_SITE) $(@D) && \
    cd $(@D) && \
    git checkout $(QTOTAUPDATE_VERSION) )
    touch $(@D)/.stamp_downloaded
endef


define QTOTAUPDATE_CONFIGURE_CMDS
	cd $(@D) && $(TARGET_MAKE_ENV) $(QT5CUSTOM_QMAKE)
	cd $(@D) && $(TARGET_MAKE_ENV) $(MAKE) qmake_all
endef

define QTOTAUPDATE_BUILD_CMDS
	cd $(@D) && $(TARGET_MAKE_ENV) $(MAKE)
endef

define QTOTAUPDATE_INSTALL_TARGET_CMDS
	cd $(@D) && $(TARGET_MAKE_ENV) $(MAKE) install
	mkdir -p $(TARGET_DIR)/usr/local/lib ; \
	cp -dpf $(STAGING_DIR)/usr/local/lib/libQt5OtaUpdate*.s* $(TARGET_DIR)/usr/local/lib || exit 1 ; \
	mkdir -p $(TARGET_DIR)/usr/local/qml ; \
	cp -dpfr $(STAGING_DIR)/usr/local/qml/QtOtaUpdate $(TARGET_DIR)/usr/local/qml ;
endef

$(eval $(generic-package))
