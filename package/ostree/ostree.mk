################################################################################
#
# OSTREE
#
################################################################################

OSTREE_VERSION = master
OSTREE_SITE = https://github.com/ostreedev/ostree.git
OSTREE_SITE_METHOD = git
OSTREE_LICENSE_FILES = COPYING

define OSTREE_EXTRACT_CMDS
    rm -rf $(@D)
    (git clone $(OSTREE_SITE) $(@D) -b master --depth 1 && \
    cd $(@D) )
    touch $(@D)/.stamp_downloaded
endef

#define HOST_OSTREE_EXTRACT_CMDS
#    rm -rf $(@D)
#    (git clone $(OSTREE_SITE) $(@D) -b master --depth 1 && \
#    cd $(@D) )
#    touch $(@D)/.stamp_downloaded
#endef

OSTREE_AUTORECONF = YES
OSTREE_AUTORECONF_ENV = PKG_CONFIG_PATH=$(STAGING_DIR)/usr/lib/pkgconfig/ 
HOST_OSTREE_AUTORECONF_ENV = PKG_CONFIG_PATH=/usr/lib/pkgconfig
OSTREE_CONF_OPTS = --with-gpgme-prefix=$(STAGING_DIR)/usr


define OSTREE_INSTALL_TARGET_CONF
	$(INSTALL) -m 755 -D $(@D)/ostree-prepare-root $(TARGET_DIR)/usr/bin; \
	$(INSTALL) -m 755 -D $(@D)/ostree-remount $(TARGET_DIR)/usr/bin; \
	$(INSTALL) -D -m 0755 package/ostree/ostree.sh $(HOST_DIR)/usr/bin; 
endef

OSTREE_POST_INSTALL_TARGET_HOOKS += OSTREE_INSTALL_TARGET_CONF

define OSTREE_RUN_AUTOGEN
	cd $(@D) && PATH=$(BR_PATH) NOCONFIGURE=1 ./autogen.sh
endef

OSTREE_POST_PATCH_HOOKS += OSTREE_RUN_AUTOGEN
#HOST_OSTREE_POST_PATCH_HOOKS += OSTREE_RUN_AUTOGEN

$(eval $(autotools-package))
#$(eval $(host-autotools-package))
