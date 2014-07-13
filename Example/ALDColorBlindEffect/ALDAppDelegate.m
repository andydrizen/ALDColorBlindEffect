//
//  ALDAppDelegate.m
//  ALDSightFilters
//
//  Created by Andy Drizen on 12/07/2014.
//  Copyright (c) 2014 Andy Drizen. All rights reserved.
//

#import "ALDAppDelegate.h"
#import "ALDColorBlindEffect.h"

@implementation ALDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [ALDColorBlindEffect sharedInstance].view = self.window;
    [ALDColorBlindEffect sharedInstance].shouldRenderPresentationLayer = YES;

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

@end
