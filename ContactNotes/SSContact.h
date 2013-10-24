//
//  SSContact.h
//  ContactNotes
//
//  Created by Seth Griner on 10/16/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSModel.h"
@class SSAddress, SSNote;

@interface SSContact : SSModel

@property (nonatomic, strong) NSString *entityId;
@property (nonatomic, strong) NSString *accountId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) SSAddress *address;
@property (nonatomic, copy) NSArray *notes;

- (void)addNote:(SSNote *)note;

@end
