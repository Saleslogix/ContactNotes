//
//  SSModel.m
//  ContactNotes
//
//  Created by Seth Griner on 10/16/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSModel.h"

@implementation SSModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSSet *propertyKeys = self.propertyKeys;
    NSMutableDictionary *paths = [NSMutableDictionary dictionaryWithCapacity:propertyKeys.count];
    for (NSString *key in propertyKeys)
    {
        paths[key] = [[[key substringToIndex:1] capitalizedString] stringByAppendingString:[key substringFromIndex:1]];
    }
    
    return paths;
}

@end
