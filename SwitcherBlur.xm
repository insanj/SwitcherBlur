#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static BOOL enabled = YES;

@interface CAFilter : NSObject
+(instancetype)filterWithName:(NSString *)name;
@end

@interface SBAppSliderSnapshotView {
    UIImageView *_snapshotImage;
}

+(id)appSliderSnapshotViewForApplication:(id)application orientation:(int)orientation loadAsync:(BOOL)async withQueue:(id)queue statusBarCache:(id)cache;
@end

@interface SBApplication
-(id)bundleIdentifier;
@end

static void reloadSettings(CFNotificationCenterRef center,
                                    void *observer,
                                    CFStringRef name,
                                    const void *object,
                                    CFDictionaryRef userInfo)
{
    NSDictionary *prefs = [NSDictionary 
        dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.insanj.switcherblur.plist"];

    if ([prefs objectForKey:@"enabled"] != nil)
        enabled = [[prefs objectForKey:@"enabled"] boolValue];
    else
        enabled = YES;
}

%hook SBAppSliderSnapshotView
+(id)appSliderSnapshotViewForApplication:(SBApplication*)application orientation:(int)orientation loadAsync:(BOOL)async withQueue:(id)queue statusBarCache:(id)cache{
    if (enabled)
    {
        NSDictionary *blacklist = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.insanj.switcherblur.plist"];
        NSString *prefix = @"Blacklist-";
        if ([[blacklist objectForKey: [prefix stringByAppendingString:[application bundleIdentifier]]] boolValue])
            return %orig;

        NSLog(@"[SwitcherBlur]: Blurring application-specific snapshotImage %@", %orig());

        UIImageView *snapshot = (UIImageView *) %orig();
        CAFilter *filter = [CAFilter filterWithName:@"gaussianBlur"];
        [filter setValue:@5 forKey:@"inputRadius"];
        snapshot.layer.filters = [NSArray arrayWithObject:filter];
        return snapshot;
    }
    return %orig;
}

%end

%ctor
{
    CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(r, NULL, &reloadSettings, CFSTR("com.insanj.switcherblur/reloadSettings"), NULL, 0);
}