THEOS_PACKAGE_DIR_NAME = debs
TARGET=:clang
ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = SwitcherBlur
SwitcherBlur_OBJC_FILES = SwitcherBlur.xm CKBlurView.m
SwitcherBlur_FRAMEWORKS = UIKit QuartzCore CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += switcherblurprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

internal-after-install::
	install.exec "killall -9 backboardd"
