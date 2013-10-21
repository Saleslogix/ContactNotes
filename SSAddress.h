//
//  SSAddress.h
//  ContactNotes
//
//  Created by Seth Griner on 10/16/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSModel.h"

@interface SSAddress : SSModel

@property (nonatomic, strong) NSString *address1;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *postalCode;

@end
