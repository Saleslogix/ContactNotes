//
//  SSController.h
//  ContactNotes
//
//  Created by Seth Griner on 10/24/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SSAppController;
@class SSSDataManager;
@class SSUserDefaults;

@protocol SSController <NSObject>

@optional

@property (nonatomic, weak) SSAppController *applicationController;
@property (nonatomic, weak) SSSDataManager *sDataManager;
@property (nonatomic, weak) SSUserDefaults *userDefaults;

@end
