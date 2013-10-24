//
//  SSContactNotesViewController.h
//  ContactNotes
//
//  Created by Seth Griner on 10/17/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSController.h"

@class SSNote;


@interface SSContactNotesViewController : UIViewController <SSController>

@property (nonatomic, strong) SSNote *note;
@property (nonatomic, assign, getter=isReadonly) BOOL readonly;

@end
