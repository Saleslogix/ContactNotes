//
//  SSUserDefaults.h
//  ContactNotes
//
//  Created by Seth Griner on 10/24/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSUserDefaults : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) NSURL *sDataURL;

- (BOOL)synchronize;

@end
