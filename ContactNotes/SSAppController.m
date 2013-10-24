//
//  SSAppController.m
//  ContactNotes
//
//  Created by Seth Griner on 10/22/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSAppController.h"
#import "SSAppFactory.h"
#import "SSContactDetailsViewController.h"
#import "SSContactNotesViewController.h"
#import "SSSDataManager.h"
#import "SSLoginViewController.h"
#import "SSUserDefaults.h"


@interface SSAppFactory (Private)

- (void)setSDataManager:(SSSDataManager *)manager;

@end


@interface SSAppController ()

@property (nonatomic, weak) UIWindow *window;

@end


@implementation SSAppController

- (instancetype)initWithAppFactory:(SSAppFactory *)factory
{
    self = super.init;
    if (!self) return nil;
    
    _factory = factory;
    _factory.appController = self;
    
    return self;
}

- (void)launchInWindow:(UIWindow *)window
{
    UINavigationBar.appearance.barTintColor = [UIColor colorWithRed:254.0/255.0 green:80.0/255.0 blue:0 alpha:1.0];
    UINavigationBar.appearance.tintColor = UIColor.whiteColor;
    UINavigationBar.appearance.titleTextAttributes = @{ NSForegroundColorAttributeName: UIColor.whiteColor };
    
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
    
    self.window = window;
    
    if (self.factory.userDefaults.userName.length && self.factory.userDefaults.password.length && self.factory.userDefaults.sDataURL)
    {
        self.factory.sDataManager = [SSSDataManager.alloc initWithUsername:self.factory.userDefaults.userName password:self.factory.userDefaults.password URL:self.factory.userDefaults.sDataURL];
        [self showContacts:NO];
    }
    else
    {
        [self showLogIn:NO];
    }
    
    [window makeKeyAndVisible];
}

- (void)showContacts:(BOOL)animated
{
    if (!animated)
    {
        self.window.rootViewController = self.factory.contactsNavigationController;
        return;
    }
    
    [UIView transitionWithView:self.window duration:1.0/3.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        self.window.rootViewController = self.factory.contactsNavigationController;
    } completion:nil];
}

- (void)showDetailsForContact:(SSContact *)contact
{
    [self.factory.contactsNavigationController pushViewController:[self.factory contactDetailsViewControllerForContact:contact] animated:YES];
}

- (void)showDetailsForNote:(SSNote *)note readonly:(BOOL)readonly
{
    SSContactNotesViewController *controller = [self.factory contactNotesViewControllerForNote:note];
    controller.readonly = readonly;
    [self.factory.contactsNavigationController pushViewController:controller animated:YES];
}

- (void)showLogIn:(BOOL)animated
{
    if (!animated)
    {
        self.window.rootViewController = self.factory.loginViewController;
        return;
    }
    
    [UIView transitionWithView:self.window duration:1.0/3.0 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        self.window.rootViewController = self.factory.loginViewController;
    } completion:nil];
}

- (void)logOff
{
    self.factory.userDefaults.password = nil;
    self.factory.sDataManager = nil;
    [self showLogIn:YES];
}

- (void)verifyUsername:(NSString *)username password:(NSString *)password URL:(NSURL *)url completion:(void (^)(NSError *))completion
{
    @weakify(self);
    [SSSDataManager verifyUsername:username password:password URL:url completion:^(SSSDataManager *manager, NSError *error) {
        @strongify(self);
        
        if (!error)
        {
            self.factory.userDefaults.userName = username;
            self.factory.userDefaults.password = password;
            self.factory.userDefaults.sDataURL = url;
            [self.factory.userDefaults synchronize];
            
            self.factory.sDataManager = manager;
            [self showContacts:YES];
        }
        
        if (completion)
        {
            completion(error);
        }
    }];
}

@end
