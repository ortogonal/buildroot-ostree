################################################################################
#
# qt-custom
#
################################################################################

QT_CUSTOM_VERSION = v5.8.0
QT_CUSTOM_SITE = https://code.qt.io/qt/qt5.git
QT_CUSTOM_SITE_METHOD = git
QT_CUSTOM_INSTALL_STAGING = YES
QT_CUSTOM_DEPENDENCIES = host-pkgconf zlib pcre

define QT_CUSTOM_EXTRACT_CMDS
    rm -rf $(@D)
    (git clone $(QT_CUSTOM_SITE) $(@D) && \
    cd $(@D) && \
    git checkout $(QT_CUSTOM_VERSION) && \
    git submodule init && \
    git submodule update)
    touch $(@D)/.stamp_downloaded
endef

define QT_CUSTOM_CONFIGURE_CMDS
        (cd $(@D); \
                PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
                PKG_CONFIG_LIBDIR="$(STAGING_DIR)/usr/lib/pkgconfig" \
                PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
                MAKEFLAGS="$(MAKEFLAGS) -j$(PARALLEL_JOBS)" \
                ./configure \
                -v \
                -opensource \
                -no-opengl \
                -confirm-license \
                -prefix /usr/local \
                -hostprefix $(HOST_DIR)/usr \
                -headerdir /usr/include/qt5 \
                -sysroot $(STAGING_DIR) \
                -nomake examples \
                -device linux-arm-generic \
                -device-option CROSS_COMPILE="$(TARGET_CROSS)" \
                -device-option BR_CCACHE="$(CCACHE)" \
                -device-option BR_COMPILER_CFLAGS="$(TARGET_CFLAGS)" \
                -device-option BR_COMPILER_CXXFLAGS="$(TARGET_CXXFLAGS)" \
        )
endef

# Build the list of libraries to be installed on the target
QT_CUSTOM_INSTALL_LIBS += Qt5Core Qt5Network Qt5Concurrent Qt5Sql Qt5Test Qt5Xml Qt5Gui Qt5Quick Qt5Qml Qt5Widgets

define QT_CUSTOM_BUILD_CMDS
        $(MAKE) -C $(@D) module-qtbase
        $(MAKE) -C $(@D) module-qtdeclarative
endef

define QT_CUSTOM_INSTALL_STAGING_CMDS
        $(MAKE) -C $(@D) module-qtbase-install_subtargets
        $(MAKE) -C $(@D) module-qtdeclarative-install_subtargets
        $(QT5_LA_PRL_FILES_FIXUP)
endef

define QT_CUSTOM_INSTALL_TARGET_LIBS
        for lib in $(QT_CUSTOM_INSTALL_LIBS); do \
                mkdir -p $(TARGET_DIR)/usr/local/lib ; \
                cp -dpf $(STAGING_DIR)/usr/local/lib/lib$${lib}*.s* $(TARGET_DIR)/usr/local/lib || exit 1 ; \
        done
endef

define QT_CUSTOM_INSTALL_TARGET_PLUGINS
        if [ -d $(STAGING_DIR)/usr/local/plugins/ ] ; then \
		echo "$(TARGET_DIR)/usr/local/plugins" ; \
                mkdir -p $(TARGET_DIR)/usr/local/plugins ; \
                cp -dpfr $(STAGING_DIR)/usr/local/plugins/* $(TARGET_DIR)/usr/local/plugins ; \
        fi
endef

define QT_CUSTOM_INSTALL_TARGET_EXAMPLES
        if [ -d $(STAGING_DIR)/usr/local/lib/qt/examples/ ] ; then \
                mkdir -p $(TARGET_DIR)/usr/local/lib/qt/examples ; \
                cp -dpfr $(STAGING_DIR)/usr/local/lib/qt/examples/* $(TARGET_DIR)/usr/local/lib/qt/examples ; \
        fi
endef

define QT_CUSTOM_INSTALL_TARGET_CMDS
        $(QT_CUSTOM_INSTALL_TARGET_LIBS)
        $(QT_CUSTOM_INSTALL_TARGET_PLUGINS)
        $(QT_CUSTOM_INSTALL_TARGET_FONTS)
        mkdir -p $(TARGET_DIR)/usr/local/bin ; \
        cp -dpf $(STAGING_DIR)/usr/local/bin/qml* $(TARGET_DIR)/usr/local/bin
        cp -dpfr $(STAGING_DIR)/usr/local/qml $(TARGET_DIR)/usr/local
endef

define QT5_LA_PRL_FILES_FIXUP
        for i in $$(find $(STAGING_DIR)/usr/local/lib* -name "libQt5*.la"); do \
                $(SED)  "s:$(BASE_DIR):@BASE_DIR@:g" \
                        -e "s:$(STAGING_DIR):@STAGING_DIR@:g" \
                        -e "s:\(['= ]\)/usr:\\1@STAGING_DIR@/usr:g" \
                        -e "s:@STAGING_DIR@:$(STAGING_DIR):g" \
                        -e "s:@BASE_DIR@:$(BASE_DIR):g" \
                        $$i ; \
                $(SED) "/^dependency_libs=/s%-L/usr/local/lib %%g" $$i ; \
        done
        for i in $$(find $(STAGING_DIR)/usr/local/lib* -name "libQt5*.prl"); do \
                $(SED) "s%-L/usr/local/lib%%" $$i; \
        done
endef

# Variable for other Qt applications to use
QT5CUSTOM_QMAKE = $(HOST_DIR)/usr/bin/qmake


$(eval $(generic-package))


#./configure -opensource -confirm-license -opengl es2 -device linux-imx6 -device-option CROSS_COMPILE="$(TARGET_CROSS)" -sysroot $(STAGING_DIR) -prefix /usr/local/qt5-imx6-debug -debug -nomake examples && \
