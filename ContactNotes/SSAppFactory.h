//
//  SSAppFactory.h
//  ContactNotes
//
//  Created by Seth Griner on 10/22/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSAppController, SSContactDetailsViewController, SSContactNotesViewController;
@class SSLoginViewController;
@class SSContact, SSNote;
@class SSSDataManager, SSUserDefaults;

@interface SSAppFactory : NSObject

@property (nonatomic, weak) SSAppController *appController;

@property (nonatomic, weak, readonly) UINavigationController *contactsNavigationController;
- (SSContactDetailsViewController *)contactDetailsViewControllerForContact:(SSContact *)contact;
- (SSContactNotesViewController *)contactNotesViewControllerForNote:(SSNote *)note;

@property (nonatomic, weak, readonly) SSLoginViewController *loginViewController;

@property (nonatomic, readonly) SSSDataManager *sDataManager;
@property (nonatomic, readonly) SSUserDefaults *userDefaults;

@end
