//
//  SSSDataManager.m
//  ContactNotes
//
//  Created by Seth Griner on 10/16/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSSDataManager.h"
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <Mantle/Mantle.h>
#import "SSContact.h"
#import "SSNote.h"


NSString * const SSDataManagerDownloadDidComplete = @"SSDataManagerDownloadDidComplete";
NSString * const SSDataManagerContactsKey = @"contacts";


@interface SSSDataManager ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation SSSDataManager

+ (instancetype)sharedManager
{
    static SSSDataManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = SSSDataManager.new;
    });
    
    return sharedManager;
}

- (instancetype)init
{
    self = super.init;
    if (!self) return nil;
    
    NSURL *baseURL = [NSURL URLWithString:@"https://slx.agreliant.com:43334/sdata/slx/dynamic/-/"];
    NSURLSessionConfiguration *sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration;
    sessionConfiguration.URLCache = nil;
    
    _sessionManager = [AFHTTPSessionManager.alloc initWithBaseURL:baseURL sessionConfiguration:sessionConfiguration];
    _sessionManager.requestSerializer = AFJSONRequestSerializer.serializer;
    [_sessionManager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"mike.hanson" password:@"8Masterkey27"];
    [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return self;
}

- (void)downloadContacts
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    void (^downloadContactsCompleted)(NSURLSessionDataTask *, id responseObject, NSError *) = ^(NSURLSessionDataTask *task, NSDictionary *responseObject, NSError *error) {
        NSArray *contacts = nil;
        
        if (error)
        {
            [SVProgressHUD showErrorWithStatus:@"Error"];
        }
        else
        {
            NSArray *rawResources = responseObject[@"$resources"];
            contacts = [[NSValueTransformer mtl_JSONArrayTransformerWithModelClass:SSContact.class] transformedValue:rawResources];
            
            [SVProgressHUD dismiss];
        }
        
        NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
        if (contacts)
        {
            userInfo[SSDataManagerContactsKey] = contacts;
        }
        [NSNotificationCenter.defaultCenter postNotificationName:SSDataManagerDownloadDidComplete object:self userInfo:userInfo];
    };
    
    NSArray *fieldsToSelect = @[ @"Name", @"Email", @"Mobile", @"Address/Address1", @"Address/City", @"Address/State", @"Address/PostalCode", @"Account" ];
    
    NSDictionary *parameters = @{
                                 @"select": [fieldsToSelect componentsJoinedByString:@","],
                                 @"count": @1000
                                };
    [self.sessionManager GET:@"contacts" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        downloadContactsCompleted(task, responseObject, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        downloadContactsCompleted(task, nil, error);
    }];
}

- (void)saveNote:(SSNote *)note completion:(void (^)(NSURLSessionTask *task, id responseObject, NSError *error))completion
{
    NSDictionary *data = [MTLJSONAdapter JSONDictionaryFromModel:note];
    
    [self.sessionManager POST:@"history" parameters:data success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion)
        {
            completion(task, responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion)
        {
            completion(task, nil, error);
        }
    }];
}

- (void)loadNotesForContact:(SSContact *)contact completion:(void (^)(NSSet *notes, NSError *error))completion
{
    void (^commonCompletion)(NSSet *, NSError *) = ^(NSSet *notes, NSError *error) {
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(notes, error);
            });
        }
    };
    
    NSArray *fieldsToSelect = @[ @"LongNotes", @"CompletedDate" ];
    NSDictionary *parameters = @{
                                 @"where": [NSString stringWithFormat:@"ContactId eq '%@' and Type eq 'atNote'", contact.entityId],
                                 @"select": [fieldsToSelect componentsJoinedByString:@","],
                                 @"count": @1000
                                };
    [self.sessionManager GET:@"history" parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
        NSArray *rawResources = responseObject[@"$resources"];
        NSArray *notes = [[NSValueTransformer mtl_JSONArrayTransformerWithModelClass:SSNote.class] transformedValue:rawResources];
        [notes setValue:contact forKeyPath:@keypath(((SSNote *)nil), contact)];
        contact.notes = [NSSet setWithArray:notes];
        
        commonCompletion(contact.notes, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        commonCompletion(nil, error);
    }];
}

@end
