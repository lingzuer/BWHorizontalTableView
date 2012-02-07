//
//  HorizontalTableViewCell.h
//  HorizontalTableViewDemo
//
//  Created by ye bingwei on 11-10-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HorizontalTableViewCell : UIView
{
    id<NSObject>    delegate_;
    
    UIView      *selectedView_;
    UIButton    *imageButton_;
    UILabel     *label_;
    UIView      *maskView_;
}

@property(nonatomic, assign) id<NSObject> delegate;
@property(nonatomic, retain) IBOutlet UIView *selectedView;
@property(nonatomic, retain) IBOutlet UIButton *imageButton;
@property(nonatomic, retain) IBOutlet UILabel *label;
@property(nonatomic, retain) IBOutlet UIView *maskView;

- (IBAction)imageButtonTouchDown;
- (IBAction)imageButtonMoveOutside;
- (IBAction)imageButtonPressed;

@end
