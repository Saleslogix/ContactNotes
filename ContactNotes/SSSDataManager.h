//
//  SSSDataManager.h
//  ContactNotes
//
//  Created by Seth Griner on 10/16/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//


@protocol SSDataManagerDelegate;
@class SSNote;
@class SSContact;


extern NSString * const SSDataManagerDownloadDidComplete;
extern NSString * const SSDataManagerContactsKey;


@interface SSSDataManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, weak) id<SSDataManagerDelegate> delegate;
- (void)downloadContacts;
- (void)saveNote:(SSNote *)note completion:(void (^)(NSURLSessionTask *task, id responseObject, NSError *error))completion;
- (void)loadNotesForContact:(SSContact *)contact completion:(void (^)(NSSet *notes, NSError *error))completion;

@end


@protocol SSDataManagerDelegate <NSObject>

- (void)managerDidCompleteDownload:(SSSDataManager *)manager;

@end
