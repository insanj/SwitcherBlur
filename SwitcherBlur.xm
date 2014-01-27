#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

@interface CAFilter : NSObject
+(instancetype)filterWithName:(NSString *)name;
@end

@interface SBAppSliderSnapshotView {
    UIImageView *_snapshotImage;
}

+(id)appSliderSnapshotViewForApplication:(id)application orientation:(int)orientation loadAsync:(BOOL)async withQueue:(id)queue statusBarCache:(id)cache;
@end

%hook SBAppSliderSnapshotView
+(id)appSliderSnapshotViewForApplication:(id)application orientation:(int)orientation loadAsync:(BOOL)async withQueue:(id)queue statusBarCache:(id)cache{
    NSLog(@"[SwitcherBlur]: Blurring application-specific snapshotImage %@", %orig());

    UIImageView *snapshot = (UIImageView *) %orig();
    CAFilter *filter = [CAFilter filterWithName:@"gaussianBlur"];
    [filter setValue:@5 forKey:@"inputRadius"];
    snapshot.layer.filters = [NSArray arrayWithObject:filter];
    return snapshot;
}

%end