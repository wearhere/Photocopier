//
//  PCRUserNotificationHelper.h
//  ChromeGIFCopier
//
//  Created by Jeffrey Wear on 10/5/14.
//  Copyright (c) 2014 Jeffrey Wear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCRUserNotificationHelper : NSObject

+ (void)deliverNotification:(NSUserNotification *)notification;

@end
