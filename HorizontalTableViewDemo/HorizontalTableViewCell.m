//
//  HorizontalTableViewCell.m
//  HorizontalTableViewDemo
//
//  Created by ye bingwei on 11-10-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HorizontalTableViewCell.h"

@implementation HorizontalTableViewCell

@synthesize delegate = delegate_;
@synthesize selectedView = selectedView_;
@synthesize imageButton = imageButton_;
@synthesize label = label_;
@synthesize maskView = maskView_;

- (IBAction)imageButtonTouchDown
{
    [maskView_ setHidden:NO];
}

- (IBAction)imageButtonMoveOutside
{
    [maskView_ setHidden:YES];
}

- (IBAction)imageButtonPressed
{
    [maskView_ setHidden:YES];
    
    if ([delegate_ respondsToSelector:@selector(cellDidSelect:)])
    {
        [delegate_ performSelector:@selector(cellDidSelect:) withObject:self];
    }
}

- (void)dealloc
{
    self.selectedView = nil;
    self.imageButton = nil;
    self.label = nil;
    self.maskView = nil;
    
    [super dealloc];
}

@end
