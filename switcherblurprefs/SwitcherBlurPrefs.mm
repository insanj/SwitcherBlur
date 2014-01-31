#import <Preferences/Preferences.h>

@interface SwitcherBlurPrefsListController: PSListController {
}
@end

@implementation SwitcherBlurPrefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"SwitcherBlurPrefs" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
