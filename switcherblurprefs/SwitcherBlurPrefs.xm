#import <Preferences/PSListController.h>

@interface SwitcherBlurPrefsListController: PSListController
@end

@implementation SwitcherBlurPrefsListController

-(id)specifiers{
	if(!_specifiers)
		_specifiers = [[self loadSpecifiersFromPlistName:@"SwitcherBlurPrefs" target:self] retain];

	return _specifiers;
}

-(void)viewWillAppear:(BOOL)animated{
    [(UITableView *)self.view deselectRowAtIndexPath:((UITableView *)self.view).indexPathForSelectedRow animated:YES];

	UIColor *tintColor = [UIColor orangeColor];
	self.view.tintColor = tintColor;
    self.navigationController.navigationBar.tintColor = tintColor;
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	self.view.tintColor = nil;
	self.navigationController.navigationBar.tintColor = nil;
}

@end