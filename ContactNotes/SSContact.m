//
//  SSContact.m
//  ContactNotes
//
//  Created by Seth Griner on 10/16/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSContact.h"
#import "SSAddress.h"
#import "SSNote.h"

@implementation SSContact

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    SSContact *c = nil;
    NSMutableDictionary *keyPaths = super.JSONKeyPathsByPropertyKey.mutableCopy;
    keyPaths[@keypath(c, entityId)] = @"$key";
    keyPaths[@keypath(c, accountId)] = @"Account.$key";
    
    return keyPaths;
}

+ (NSValueTransformer *)addressJSONTransformer
{
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:SSAddress.class];
}

+ (NSValueTransformer *)notesJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:SSNote.class];
}

@end
