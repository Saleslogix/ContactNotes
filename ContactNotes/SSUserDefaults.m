//
//  SSUserDefaults.m
//  ContactNotes
//
//  Created by Seth Griner on 10/24/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSUserDefaults.h"
#import <Lockbox/Lockbox.h>


@interface SSUserDefaults ()

@property (nonatomic, strong) NSUserDefaults *defaults;

@end


@implementation SSUserDefaults

- (instancetype)init
{
    self = super.init;
    if (!self) return nil;
    
    _defaults = NSUserDefaults.standardUserDefaults;
    
    return self;
}

- (void)setUserName:(NSString *)userName
{
    [self.defaults setObject:userName forKey:@keypath(self, userName)];
}

- (NSString *)userName
{
    return [self.defaults stringForKey:@keypath(self, userName)];
}

- (void)setPassword:(NSString *)password
{
    [Lockbox setString:password forKey:@keypath(self, password) accessibility:kSecAttrAccessibleAfterFirstUnlock];
}

- (NSString *)password
{
    return [Lockbox stringForKey:@keypath(self, password)];
}

- (void)setSDataURL:(NSURL *)sDataURL
{
    [self.defaults setURL:sDataURL forKey:@keypath(self, sDataURL)];
}

- (NSURL *)sDataURL
{
    return [self.defaults URLForKey:@keypath(self, sDataURL)];
}

- (BOOL)synchronize
{
    return [self.defaults synchronize];
}

@end
