//
//  SSSDataManager.h
//  ContactNotes
//
//  Created by Seth Griner on 10/16/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//


@class SSContact, SSNote;


@interface SSSDataManager : NSObject

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password URL:(NSURL *)url;

- (void)loadContactsWithCompletion:(void (^)(NSArray *contacts, NSError *error))completion;
- (void)saveNote:(SSNote *)note completion:(void (^)(NSURLSessionTask *task, SSNote *note, NSError *error))completion;
- (void)loadNotesForContact:(SSContact *)contact completion:(void (^)(NSArray *notes, NSError *error))completion;

+ (void)verifyUsername:(NSString *)username password:(NSString *)password URL:(NSURL *)url completion:(void (^)(SSSDataManager *manager, NSError *error))completion;

@end
