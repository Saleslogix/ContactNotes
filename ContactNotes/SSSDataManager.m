//
//  SSSDataManager.m
//  ContactNotes
//
//  Created by Seth Griner on 10/16/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSSDataManager.h"
#import <AFNetworking/AFNetworking.h>
#import <Mantle/Mantle.h>
#import "SSContact.h"
#import "SSNote.h"


@interface SSSDataManager ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end


@implementation SSSDataManager

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password URL:(NSURL *)url
{
    self = super.init;
    if (!self) return nil;
    
    // Ensure terminal slash for baseURL path, so that NSURL +URLWithString:relativeToURL: works as expected
    if (url.path.length > 0 && ![url.absoluteString hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@""];
    }
    
    NSURL *baseURL = [NSURL URLWithString:@"slx/dynamic/-/" relativeToURL:url];
    NSURLSessionConfiguration *sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration;
    sessionConfiguration.URLCache = nil;
    
    _sessionManager = [AFHTTPSessionManager.alloc initWithBaseURL:baseURL sessionConfiguration:sessionConfiguration];
    _sessionManager.requestSerializer = AFJSONRequestSerializer.serializer;
    [_sessionManager.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
    [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    _sessionManager.responseSerializer = AFJSONResponseSerializer.serializer;
    
    return self;
}

- (void)dealloc
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)loadContactsWithCompletion:(void (^)(NSArray *contacts, NSError *error))completion
{
    NSArray *fieldsToSelect = @[ @"Name", @"Email", @"Mobile", @"Address/Address1", @"Address/City", @"Address/State", @"Address/PostalCode", @"Account" ];
    
    NSDictionary *parameters = @{
                                 @"select": [fieldsToSelect componentsJoinedByString:@","],
                                 @"count": @1000
                                };
    [self.sessionManager GET:@"contacts" parameters:parameters success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
        if (completion)
        {
            NSArray *rawResources = responseObject[@"$resources"];
            NSArray *contacts = [[NSValueTransformer mtl_JSONArrayTransformerWithModelClass:SSContact.class] transformedValue:rawResources];
            completion(contacts, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion)
        {
            completion(nil, error);
        }
    }];
}

- (void)saveNote:(SSNote *)note completion:(void (^)(NSURLSessionTask *task, SSNote *note, NSError *error))completion
{
    NSDictionary *data = [MTLJSONAdapter JSONDictionaryFromModel:note];
    
    [self.sessionManager POST:@"history" parameters:data success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
        if (completion)
        {
            NSError *serializationError = nil;
            SSNote *note = [MTLJSONAdapter modelOfClass:SSNote.class fromJSONDictionary:responseObject error:&serializationError];
            if (note)
                completion(task, note, nil);
            else
                completion(task, nil, serializationError);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion)
        {
            completion(task, nil, error);
        }
    }];
}

- (void)loadNotesForContact:(SSContact *)contact completion:(void (^)(NSArray *notes, NSError *error))completion
{
    void (^commonCompletion)(NSArray *, NSError *) = ^(NSArray *notes, NSError *error) {
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
        contact.notes = notes;
        
        commonCompletion(contact.notes, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        commonCompletion(nil, error);
    }];
}

+ (void)verifyUsername:(NSString *)username password:(NSString *)password URL:(NSURL *)url completion:(void (^)(SSSDataManager *manager, NSError *))completion
{
    SSSDataManager *manager = [self.alloc initWithUsername:username password:password URL:url];
    [manager.sessionManager.requestSerializer setValue:nil forHTTPHeaderField:@"Accept"];
    manager.sessionManager.responseSerializer = AFHTTPResponseSerializer.serializer;
    
    [manager.sessionManager GET:@"../../../$system" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion)
        {
            [manager.sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            manager.sessionManager.responseSerializer = AFJSONResponseSerializer.serializer;
            completion(manager, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion)
        {
            completion(nil, error);
        }
    }];
}

@end
