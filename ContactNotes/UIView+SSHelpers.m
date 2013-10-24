//
//  UIView+SSHelpers.m
//  ContactNotes
//
//  Created by Seth Griner on 10/22/13.
//  Copyright (c) 2013 Sincera Solutions. All rights reserved.
//

#import "UIView+SSHelpers.h"

@implementation UIView (SSHelpers)

- (BOOL)ss_containsView:(UIView *)view
{
    if (self == view) return YES;
    
    for (UIView *subview in self.subviews)
    {
        if ([subview ss_containsView:view])
            return YES;
    }
    
    return NO;
}

@end
