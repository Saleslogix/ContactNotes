//
//  SSNote.m
//  ContactNotes
//
//  Created by Seth Griner on 10/18/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSNote.h"
#import "SSContact.h"


@interface SSNote ()

@property (nonatomic, strong, readonly) NSString *accountId;
@property (nonatomic, strong, readonly) NSString *contactId;
@property (nonatomic, strong, readonly) NSString *type;
@property (nonatomic, assign, readonly) BOOL timeless;
@property (nonatomic, assign, readonly) uint16_t duration;
@property (nonatomic, strong, readonly) NSString *result;

@end


@implementation SSNote

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *properties = super.JSONKeyPathsByPropertyKey.mutableCopy;
    
    SSNote *n = nil;
    properties[@keypath(n, text)] = @"LongNotes";
    properties[@keypath(n, contact)] = NSNull.null;
    
    return properties;
}

- (instancetype)initWithContact:(SSContact *)contact
{
    self = super.init;
    if (!self) return nil;
    
    self.contact = contact;
    _type = @"atNote";
    _timeless = YES;
    _duration = 0;
    _result = nil;
    
    return self;
}

- (instancetype)init
{
    return [self initWithContact:nil];
}

- (void)setContact:(SSContact *)contact
{
    _contact = contact;
    _contactId = contact.entityId;
    _accountId = contact.accountId;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p> %@", self.class, self, self.dictionaryValueWithoutCircularReferences];
}

- (NSDictionary *)dictionaryValueWithoutCircularReferences
{
    NSMutableSet *keys = self.class.propertyKeys.mutableCopy;
    [keys removeObject:@keypath(self, contact)];
	return [self dictionaryWithValuesForKeys:keys.allObjects];
}

@end
