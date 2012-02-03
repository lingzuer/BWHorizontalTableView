//
//  ViewController.m
//  HorizontalTableViewDemo
//
//  Created by ye bingwei on 11-10-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "HorizontalTableViewCell.h"

@implementation ViewController

@synthesize imageView = imageView_;
@synthesize horizontalTableView = horizontalTableView_;

- (NSUInteger)numberOfCellsInHorizontalTableView:(BWHorizontalTableView *)aHorizontalTableView
{
    return [images_ count];
}

- (CGFloat)widthForCellInHorizontalTableView:(BWHorizontalTableView *)aHorizontalTableView
{
    return 100.f;
}

- (UIView *)horizontalTableView:(BWHorizontalTableView *)aTableView cellAtIndex:(NSInteger)aIndex
{
    HorizontalTableViewCell *cell = (HorizontalTableViewCell *)[aTableView dequeueReusableCell];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"HorizontalTableViewCell" owner:nil options:nil] lastObject];
    }
    
    [cell.imageView setImage:[images_ objectAtIndex:aIndex]];
    [cell.label setText:[NSString stringWithFormat:@"%d", aIndex]];
    
    return cell;
}

//- (IBAction)testButtonPressed
//{
//    [horizontalTableView_ selectCellAtIndex:5 animated:YES];
//    
////      [horizontalTableView selectCellAtIndex:5 animated:YES];
//    
////    [images_ addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", [images_ count]]]];
////    [horizontalTableView insertCellAtIndex:[images_ count]-1 animated:YES];
//    
////    [images_ removeObjectAtIndex:0];
////    [horizontalTableView deleteCellAtIndex:0 animated:YES];
//    
////    [images_ replaceObjectAtIndex:1 withObject:[UIImage imageNamed:@"3.jpg"]];
////    [horizontalTableView reloadCellAtIndex:1 animated:YES];
//    
////    [images_ removeAllObjects];
////    [images_ addObject:[UIImage imageNamed:@"1.jpg"]];
//    
////    [horizontalTableView setContentOffset:320 animated:YES];
//}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (images_ == nil)
    {
        images_ = [[NSMutableArray alloc] init];
    }
    for (NSInteger index=0; index<10; index++)
    {
        [images_ addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", index+1]]];
    }
    
    [self.imageView setImage:[UIImage imageNamed:@"1.jpg"]];
    
    [horizontalTableView_ selectCellAtIndex:5 animated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.imageView = nil;
    self.horizontalTableView = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [horizontalTableView_ willRotate];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        [imageView_ setFrame:CGRectMake(0.f, 0.f, 480.f, 190.f)];
    }
    else
    {
        [imageView_ setFrame:CGRectMake(0.f, 0.f, 320.f, 350.f)];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [horizontalTableView_ didRotate];
}

- (void)dealloc {
    [images_ release];
    [imageView_ release];
    [horizontalTableView_ release];
    
    [super dealloc];
}

@end
