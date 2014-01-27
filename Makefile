THEOS_PACKAGE_DIR_NAME = debs
TARGET=:clang
ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = SwitcherBlur
SwitcherBlur_OBJC_FILES = SwitcherBlur.xm
SwitcherBlur_FRAMEWORKS = UIKit QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

internal-after-install::
	install.exec "killall -9 backboardd"