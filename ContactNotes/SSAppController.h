//
//  SSAppController.h
//  ContactNotes
//
//  Created by Seth Griner on 10/22/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSAppFactory;
@class SSContact, SSNote;

@interface SSAppController : NSObject

- (instancetype)initWithAppFactory:(SSAppFactory *)factory;
@property (nonatomic, readonly) SSAppFactory *factory;

- (void)launchInWindow:(UIWindow *)window;

- (void)showContacts:(BOOL)animated;
- (void)showDetailsForContact:(SSContact *)contact;
- (void)showDetailsForNote:(SSNote *)note readonly:(BOOL)readonly;

- (void)showLogIn:(BOOL)animated;
- (void)logOff;
- (void)verifyUsername:(NSString *)username password:(NSString *)password URL:(NSURL *)url completion:(void (^)(NSError *error))completion;

@end
