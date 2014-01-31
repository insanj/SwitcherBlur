TARGET=:clang
ARCHS = armv7 armv7s arm64
include theos/makefiles/common.mk

BUNDLE_NAME = SwitcherBlurPrefs
SwitcherBlurPrefs_FILES = SwitcherBlurPrefs.xm
SwitcherBlurPrefs_INSTALL_PATH = /Library/PreferenceBundles
SwitcherBlurPrefs_FRAMEWORKS = UIKit
SwitcherBlurPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SwitcherBlurPrefs.plist$(ECHO_END)
