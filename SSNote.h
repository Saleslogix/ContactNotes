//
//  SSNote.h
//  ContactNotes
//
//  Created by Seth Griner on 10/18/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSModel.h"
@class SSContact;

@interface SSNote : SSModel

@property (nonatomic, weak) SSContact *contact;
@property (nonatomic, strong) NSString *text;

- (instancetype)initWithContact:(SSContact *)contact;

@end
