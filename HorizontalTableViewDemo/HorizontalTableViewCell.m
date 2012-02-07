//
//  HorizontalTableViewCell.m
//  HorizontalTableViewDemo
//
//  Created by ye bingwei on 11-10-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HorizontalTableViewCell.h"

@implementation HorizontalTableViewCell

@synthesize imageButton;
@synthesize label;

- (void)dealloc {
    self.imageButton = nil;
    self.label = nil;
    
    [super dealloc];
}

@end
