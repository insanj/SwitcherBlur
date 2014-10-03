#import <Preferences/PSListController.h>
#import <UIKit/UIActivityViewController.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>

#define URL_ENCODE(string) [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)(string), NULL, CFSTR(":/=,!$& '()*+;[]@#?"), kCFStringEncodingUTF8) autorelease]

@interface SwitcherBlurPrefsListController : PSListController <MFMailComposeViewControllerDelegate>{
	UIColor *tintColor;
}
@end

@implementation SwitcherBlurPrefsListController

-(id)specifiers{
	if(!_specifiers)
		_specifiers = [[self loadSpecifiersFromPlistName:@"SwitcherBlurPrefs" target:self] retain];

	return _specifiers;
}

-(void)loadView{
	[super loadView];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped:)] autorelease];
}

-(void)viewDidLoad{
	[super viewDidLoad];

	tintColor = [UIColor orangeColor];
	[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = tintColor;
	// [UILabel appearanceWhenContainedIn:self.class, nil].textColor = tintColor;
}

-(void)viewWillAppear:(BOOL)animated{
    [[self table] deselectRowAtIndexPath:[self table].indexPathForSelectedRow animated:YES];

	[self table].tintColor = tintColor;
    self.navigationController.navigationBar.tintColor = tintColor;
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self table].tintColor = nil;
	self.navigationController.navigationBar.tintColor = nil;
}

-(void)twitter{
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/insanj"]];

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) 
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitterrific:///profile?screen_name=insanj"]];

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) 
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetings:///user?screen_name=insanj"]];

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) 
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=insanj"]];

	else 
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/insanj"]];
}

-(void)shareTapped:(UIBarButtonItem *)sender{
	NSString *text = @"An iOS 7 switcher with style, utility, and a bit of blur. Get SwitcherBlur from @insanj today!";
	NSURL *url = [NSURL URLWithString:@"https://github.com/insanj/SwitcherBlur/"];

	if(%c(UIActivityViewController)){
		UIActivityViewController *viewController = [[[%c(UIActivityViewController) alloc] initWithActivityItems:[NSArray arrayWithObjects:text, url, nil] applicationActivities:nil] autorelease];
		[self.navigationController presentViewController:viewController animated:YES completion:NULL];
	}

	else if(%c(TWTweetComposeViewController) && [TWTweetComposeViewController canSendTweet]){
		TWTweetComposeViewController *viewController = [[[TWTweetComposeViewController alloc] init] autorelease];
		viewController.initialText = text;
		[viewController addURL:url];
		[self.navigationController presentViewController:viewController animated:YES completion:NULL];
	}

	else
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/intent/tweet?text=%@%%20%@", URL_ENCODE(text), URL_ENCODE(url.absoluteString)]]];
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end