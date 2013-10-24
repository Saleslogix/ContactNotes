//
//  SSContactDetailViewController.h
//  ContactNotes
//
//  Created by Seth Griner on 10/17/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "SSController.h"

@class SSSDataManager, SSAppController;
@class SSContact;

@interface SSContactDetailsViewController : UITableViewController <SSController>

@property (nonatomic, strong) SSContact *contact;

@end
