//
//  ViewController.h
//  HorizontalTableViewDemo
//
//  Created by ye bingwei on 11-10-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWHorizontalTableView.h"

@interface ViewController : UIViewController<BWHorizontalTableViewDataSource, BWHorizontalTableViewDataSource>
{
@private
    UIImageView *imageView_;
    BWHorizontalTableView *horizontalTableView_;
    
    NSMutableArray *images_;
    
    BOOL    selectedCellIndex_;
}

@property(nonatomic, retain) IBOutlet UIImageView *imageView;
@property(nonatomic, retain) IBOutlet BWHorizontalTableView *horizontalTableView;

//- (IBAction)testButtonPressed;

- (void)cellDidSelect:(UIView *)aCell;

@end
