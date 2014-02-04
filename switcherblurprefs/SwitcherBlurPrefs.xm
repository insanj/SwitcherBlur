#import <Preferences/PSListController.h>
#import <UIKit/UIActivityViewController.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>

#define URL_ENCODE(string) [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)(string), NULL, CFSTR(":/=,!$& '()*+;[]@#?"), kCFStringEncodingUTF8) autorelease]

@interface SwitcherBlurPrefsListController: PSListController <MFMailComposeViewControllerDelegate>{
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
	//[UILabel appearanceWhenContainedIn:self.class, nil].textColor = tintColor;
}

-(void)viewWillAppear:(BOOL)animated{
    [(UITableView *)self.view deselectRowAtIndexPath:((UITableView *)self.view).indexPathForSelectedRow animated:YES];

	self.view.tintColor = tintColor;
    self.navigationController.navigationBar.tintColor = tintColor;
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	self.view.tintColor = nil;
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

-(void)mail{
	NSURL *helpurl = [NSURL URLWithString:@"mailto:insanjmail%40gmail.com?subject=SwitcherBlur%20(1.1.1)%20Support"];
	if([MFMailComposeViewController canSendMail]){
		MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
		[composeViewController setMailComposeDelegate:self];
		[composeViewController setToRecipients:@[@"insanjmail@gmail.com"]];
		[composeViewController setSubject:@"SwitcherBlur (1.1.1) Support"];
		[self presentViewController:composeViewController animated:YES completion:nil];
	}//end if
		
	else if ([[UIApplication sharedApplication] canOpenURL:helpurl])
		[[UIApplication sharedApplication] openURL:helpurl];
		
	else
		[[[UIAlertView alloc] initWithTitle:@"Contact Developer" message:@"Shoot an email to insanjmail@gmail.com, or talk to me on twitter (@insanj) if you have any problems, requests, or ideas!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil] show];
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