//
//  PCRUserNotificationHelper.m
//  ChromeGIFCopier
//
//  Created by Jeffrey Wear on 10/5/14.
//  Copyright (c) 2014 Jeffrey Wear. All rights reserved.
//

#import "PCRUserNotificationHelper.h"

#import <objc/runtime.h>

@implementation PCRUserNotificationHelper

/**
 `NSUserNotificationCenter` will not deliver notifications from Foundation CLI
 tools (rdar://11956694 ), only apps, but we can trick it into thinking that
 we're an app by causing `[[NSBundle mainBundle] bundleIdentifier]` to return the
 identifier of a known application: http://stackoverflow.com/a/14698543/495611 .
 
 This causes the notification to use the icon of the app. In this case we return
 Chrome's bundle identifier since we're the host of a Chrome extension anyway.
 */
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL bundleIdentifierSEL = @selector(bundleIdentifier);
        Method bundleIdentifierMethod = class_getInstanceMethod([NSBundle class], bundleIdentifierSEL);
        
        __block IMP originalBundleIdentifierIMP = NULL;
        IMP newBundleIdentifierIMP = imp_implementationWithBlock(^NSString *(id _self){
            if (_self == [NSBundle mainBundle]) {
                return @"com.google.Chrome";
            } else {
                return ((NSString *(*)(id, SEL))originalBundleIdentifierIMP)(_self, bundleIdentifierSEL);
            }
        });
        originalBundleIdentifierIMP = method_setImplementation(bundleIdentifierMethod, newBundleIdentifierIMP);
    });
}

static BOOL didDeliverNotification = NO;
static NSTimeInterval kNotificationDeliveryTimeout = 2.0;

+ (void)deliverNotification:(NSUserNotification *)notification {
    NSUserNotificationCenter *userNotificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    [userNotificationCenter setDelegate:(id<NSUserNotificationCenterDelegate>)self];
    
    // After delivering the notification, we must wait to return until we confirm
    // delivery–so that we can force delivery if Chrome is frontmost.
    // (Without waiting, the tool might quit before `NSUserNotificationCenter` asks
    // us whether it should present the notification.)
    didDeliverNotification = NO;
    NSDate *startDeliveryDate = [NSDate date];
    [userNotificationCenter deliverNotification:notification];
    while (!didDeliverNotification &&
           [[NSDate date] timeIntervalSinceDate:startDeliveryDate] < kNotificationDeliveryTimeout) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
    }
}

#pragma mark - NSUserNotificationCenterDelegate

// These are technically instance methods, per the `NSUserNotificationCenterDelegate`
// protocol, but the signatures are all that matters. We mark them as class methods
// because that's how they're implemented.
+ (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

+ (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification {
    didDeliverNotification = YES;
}

@end
