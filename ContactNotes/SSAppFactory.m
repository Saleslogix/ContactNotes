//
//  SSAppFactory.m
//  ContactNotes
//
//  Created by Seth Griner on 10/22/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSAppFactory.h"
#import "SSContactsViewController.h"
#import "SSContactDetailsViewController.h"
#import "SSContactNotesViewController.h"
#import "SSLoginViewController.h"
#import "SSSDataManager.h"
#import "SSController.h"
#import "SSUserDefaults.h"


@interface SSAppFactory ()

@property (nonatomic, strong, readwrite) SSSDataManager *sDataManager;
@property (nonatomic, weak, readwrite) UINavigationController *contactsNavigationController;
@property (nonatomic, weak, readwrite) SSLoginViewController *loginViewController;

@end


@implementation SSAppFactory
{
    SSUserDefaults *_userDefaults;
}

- (UINavigationController *)contactsNavigationController
{
    if (!_contactsNavigationController)
    {
        NSString *name = [NSString stringWithFormat:@"Contacts_%@", UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone ? @"iPhone" : @"iPad"];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:name bundle:nil];
        _contactsNavigationController = storyboard.instantiateInitialViewController;
        
        SSContactsViewController *contactsViewController = (SSContactsViewController *)_contactsNavigationController.topViewController;
        [self configureController:contactsViewController];
    }
    
    return _contactsNavigationController;
}

- (SSContactDetailsViewController *)contactDetailsViewControllerForContact:(SSContact *)contact
{
    SSContactDetailsViewController *controller = [self.contactsNavigationController.storyboard instantiateViewControllerWithIdentifier:@"contactDetails"];
    [self configureController:controller];
    controller.contact = contact;
    
    return controller;
}

- (SSContactNotesViewController *)contactNotesViewControllerForNote:(SSNote *)note
{
    SSContactNotesViewController *controller = [self.contactsNavigationController.storyboard instantiateViewControllerWithIdentifier:@"contactNote"];
    [self configureController:controller];
    controller.note = note;
    
    return controller;
}

- (SSLoginViewController *)loginViewController
{
    if (!_loginViewController)
    {
        _loginViewController = [UIStoryboard storyboardWithName:@"Login" bundle:nil].instantiateInitialViewController;
        [self configureController:_loginViewController];
    }
    
    return _loginViewController;
}

- (SSUserDefaults *)userDefaults
{
    if (!_userDefaults)
    {
        _userDefaults = SSUserDefaults.new;
    }
    
    return _userDefaults;
}

- (void)configureController:(UIViewController *)controller
{
    if ([controller conformsToProtocol:@protocol(SSController)])
    {
        id<SSController> ssController = (id)controller;
        
        if ([ssController respondsToSelector:@selector(setApplicationController:)])
        {
            ssController.applicationController = self.appController;
        }
        
        if ([ssController respondsToSelector:@selector(setSDataManager:)])
        {
            ssController.sDataManager = self.sDataManager;
        }
        
        if ([ssController respondsToSelector:@selector(setUserDefaults:)])
        {
            ssController.userDefaults = self.userDefaults;
        }
    }
}

@end
