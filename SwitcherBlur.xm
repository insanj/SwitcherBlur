#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "CKBlurView.h"

/**************************** Forward-Declarations ****************************/

@interface CAFilter : NSObject
+(instancetype)filterWithName:(NSString *)name;
@end

@interface SpringBoard : UIApplication
-(void)_relaunchSpringBoardNow;
@end

@interface SBApplication
-(id)bundleIdentifier;
-(BOOL)isRunning;
@end

@interface SBAppSliderWindow : UIWindow
@end

@interface SBAppSliderSnapshotView {
    UIImageView *_snapshotImage;
}

@property(retain, nonatomic) SBApplication *application;
+(id)appSliderSnapshotViewForApplication:(id)application orientation:(int)orientation loadAsync:(BOOL)async withQueue:(id)queue statusBarCache:(id)cache;
@end


/**************************** Settings Assignments ***************************/

static NSMutableArray *switcherblur_DisabledApps;  // @"All" means all are disabled, nil means everything's enabled
static NSInteger switcherblur_blurIfInactive, switcherblur_blurWallpaper;

static void switcherBlur_reloadSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.switcherblur.plist"]];
    NSLog(@"[SwitcherBlur] Reloading settings: %@", settings);

    if([settings objectForKey:@"enabled"] && ![[settings objectForKey:@"enabled"] boolValue]){
        switcherblur_DisabledApps = @[@"All"].mutableCopy;
        switcherblur_blurIfInactive = 1;
        switcherblur_blurWallpaper = 1;
    }

    else{
        switcherblur_DisabledApps = [[NSMutableArray alloc] init];
        for(NSString *key in [settings allKeys])
            if(![key isEqualToString:@"enabled"] && [[settings objectForKey:key] boolValue])
                [switcherblur_DisabledApps addObject:[key stringByReplacingOccurrencesOfString:@"Blacklist-" withString:@""]];
        
        if(switcherblur_DisabledApps.count == 0)
            switcherblur_DisabledApps = nil;

        switcherblur_blurIfInactive = ([settings objectForKey:@"running"] && [[settings objectForKey:@"running"] boolValue]) + 1;

        int previousWallpaper = switcherblur_blurWallpaper;
        switcherblur_blurWallpaper = ([settings objectForKey:@"wallpaper"] && [[settings objectForKey:@"wallpaper"] boolValue]) + 1;
        if(previousWallpaper != switcherblur_blurWallpaper)
            [(SpringBoard *)[%c(SpringBoard) sharedApplication] _relaunchSpringBoardNow];
    }
}

/**************************** Background Blur ****************************/

%hook SBAppSliderWindow

-(id)initWithFrame:(CGRect)frame{
    if(switcherblur_blurWallpaper == 0){
        NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.switcherblur.plist"]];
        switcherblur_blurWallpaper = ([settings objectForKey:@"wallpaper"] && [[settings objectForKey:@"wallpaper"] boolValue]) + 1;
    }

    SBAppSliderWindow *window = %orig();

    if(switcherblur_blurWallpaper == 2){
        NSLog(@"[SwitcherBlur] Blurrig app switcher background : %@", self);
        CKBlurView *blurView = [[CKBlurView alloc] initWithFrame:frame];
        [window addSubview:blurView];
    }

    return window;
}

%end

/**************************** Snapshot Blur ****************************/

%hook SBAppSliderSnapshotView

+(id)appSliderSnapshotViewForApplication:(SBApplication*)application orientation:(int)orientation loadAsync:(BOOL)async withQueue:(id)queue statusBarCache:(id)cache{
    if(switcherblur_blurIfInactive == 0){
        NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.switcherblur.plist"]];
        switcherblur_blurIfInactive = ([settings objectForKey:@"running"] && [[settings objectForKey:@"running"] boolValue]) + 1;
    }

    if(!switcherblur_DisabledApps || ![switcherblur_DisabledApps[0] isEqualToString:@"All"]){
        if(![switcherblur_DisabledApps containsObject:[application bundleIdentifier]] && !((switcherblur_blurIfInactive == 2) && [application isRunning])){
            NSLog(@"[SwitcherBlur]: Blurring application-specific snapshotImage %@", %orig());

            UIImageView *snapshot = (UIImageView *) %orig();
            CAFilter *filter = [CAFilter filterWithName:@"gaussianBlur"];
            [filter setValue:@5 forKey:@"inputRadius"];
            snapshot.layer.filters = [NSArray arrayWithObject:filter];
            return snapshot;
        }
    }

    return %orig;
}

%end

%ctor{
    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(r, NULL, &switcherBlur_reloadSettings, CFSTR("com.insanj.switcherblur/reloadSettings"), NULL, 0);
}