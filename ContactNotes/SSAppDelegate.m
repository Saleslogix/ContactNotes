//
//  SSAppDelegate.m
//  ContactNotes
//
//  Created by Seth Griner on 10/15/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSAppDelegate.h"
#import "SSAppController.h"
#import "SSAppFactory.h"


@implementation SSAppDelegate
{
    SSAppController *_appController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [UIWindow.alloc initWithFrame:UIScreen.mainScreen.bounds];
    [self.appController launchInWindow:self.window];
    
    return YES;
}
							
- (SSAppController *)appController
{
    if (!_appController)
    {
        _appController = [SSAppController.alloc initWithAppFactory:SSAppFactory.new];
    }
    
    return _appController;
}

@end
