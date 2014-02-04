#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

/******************** Forward-Declarations *********************/

@interface CAFilter : NSObject
+(instancetype)filterWithName:(NSString *)name;
@end

@interface SBApplication
-(id)bundleIdentifier;
-(BOOL)isRunning;
@end

@interface SBAppSliderSnapshotView {
    UIImageView *_snapshotImage;
}

@property(retain, nonatomic) SBApplication *application;
+(id)appSliderSnapshotViewForApplication:(id)application orientation:(int)orientation loadAsync:(BOOL)async withQueue:(id)queue statusBarCache:(id)cache;
@end


/*********************** Global Functions **********************/

static NSMutableArray *switcherblur_DisabledApps;  // @"All" means all are disabled, nil means everything's enabled
static NSInteger switcherblur_blurIfInactive;

static void switcherBlur_reloadSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.switcherblur.plist"]];
    NSLog(@"[SwitcherBlur] Reloading settings: %@", settings);

    if([settings objectForKey:@"enabled"] && ![[settings objectForKey:@"enabled"] boolValue]){
        switcherblur_DisabledApps = @[@"All"].mutableCopy;
        switcherblur_blurIfInactive = NO;
    }

    else{
        switcherblur_DisabledApps = [[NSMutableArray alloc] init];
        for(NSString *key in [settings allKeys])
            if(![key isEqualToString:@"enabled"] && [[settings objectForKey:key] boolValue])
                [switcherblur_DisabledApps addObject:[key stringByReplacingOccurrencesOfString:@"Blacklist-" withString:@""]];
        
        if(switcherblur_DisabledApps.count == 0)
            switcherblur_DisabledApps = nil;

        switcherblur_blurIfInactive = ([settings objectForKey:@"running"] && [[settings objectForKey:@"running"] boolValue]) + 1;
    }
}

/**************************** Hooks ****************************/

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