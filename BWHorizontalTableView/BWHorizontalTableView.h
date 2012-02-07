//
//  BWHorizontalTableView.h
//  
//  Created by yebw on 12-1-12.
//  Version 1.1
//  

#import <UIKit/UIKit.h>

#define BWHT_DEBUG_ENABLED

// Forward declaration
@class BWHorizontalTableView;

// DataSource protocol of the horizontal table view
@protocol BWHorizontalTableViewDataSource <NSObject>
@required
- (NSUInteger)numberOfCellsInHorizontalTableView:(BWHorizontalTableView *)aHorizontalTableView;

- (CGFloat)widthForCellInHorizontalTableView:(BWHorizontalTableView *)aHorizontalTableView;

// Cell display. Implementers should *always* try to reuse cells by querying for available reusable cells with dequeueReusableCell
- (UIView *)horizontalTableView:(BWHorizontalTableView *)aTableView cellAtIndex:(NSInteger)aIndex;

@end

// Delegate protocol of the horizontal table view
@protocol BWHorizontalTableViewDelegate
@end


// Declaration of BWHorizontalTableView
@interface BWHorizontalTableView : UIView<UIScrollViewDelegate>
{
@private
    id<BWHorizontalTableViewDataSource>  dataSource_;
    id<BWHorizontalTableViewDelegate>    delegate_;

    UIScrollView    *scrollView_;
    
    NSMutableArray  *cells_;
    NSMutableArray  *reusableCells_;
    
    NSUInteger      numberOfCells_;
    
    CGFloat         widthForCell_;              // In this version(1.1), all the cells are with the same width;
    NSUInteger      numberOfVisibleCells_;
    
    CGFloat         contentOffset_;
    NSInteger       indexForFirstVisibleCell_;
    NSInteger       indexForSelectedCell_;
    
    NSUInteger      indexForFirstLoadedCell_;
    NSUInteger      indexForLastLoadedCell_;
    
    BOOL            needsReload_;               // Needs reload the data of cells;
    
    // << - (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated >> will call scrollViewDidScroll: which will trigger 
    // the layout performance of all cells, set the ignoreScroll_ to YES to avoid of layouting cells unexpectly;
    BOOL            ignoreScroll_;
    
    BOOL            updating_;                  // Reloading, inserting or deleting cell;
    BOOL            updatingAnimated_;          // Update tableview with animation if updatingAnimated_ is YES;
}

@property(nonatomic, assign) IBOutlet id<BWHorizontalTableViewDataSource>    dataSource;
@property(nonatomic, assign) IBOutlet id<BWHorizontalTableViewDelegate>      delegate;
@property(nonatomic, assign)    CGFloat     contentOffset; 
@property(nonatomic, readonly)  NSInteger   indexForFirstVisibleCell;
@property(nonatomic, readonly)  NSInteger   indexForSelectedCell;

// Querying for available reusable cell;
- (UIView *)dequeueReusableCell;

// Querying for the cell at index sepcified, return nil if aIndex is illegal, OR THE CELL IS NOT VISIBLE;
- (UIView *)cellForIndex:(NSInteger)aIndex;

// Returns an index of cell sepcified, return NSNotFound if aCell is not a cell of current tableview, OR IT'S NOT VISIBLE;
- (NSInteger)indexForCell:(UIView *)aCell;


// Reload the data of cells, no animation is supported;
- (void)reloadData;


// All the updating operation is only support of fading animation now;

// Reload the cell specified with an option to animate the insertion.
- (void)reloadCellAtIndex:(NSInteger)aIndex animated:(BOOL)aAnimated;

// Insert the cell secified with an option to animate the insertion. User should insert the new relevant data befor it is called.
- (void)insertCellAtIndex:(NSInteger)aIndex animated:(BOOL)aAnimated; 

// Delete the cell secified with an option to animate the insertion. User should delete the relevant data befor it is called.
- (void)deleteCellAtIndex:(NSInteger)aIndex animated:(BOOL)aAnimated;


// Select the cell specified with an option to animate the insertion. If a cell is selected, the cell will be layouted to the center of the tableview.
- (void)selectCellAtIndex:(NSInteger)aIndex animated:(BOOL)aAnimated;

// Scroll to the cell sepecified with an option to animate the insertion
- (void)scrollToCellAtIndex:(NSInteger)aIndex animated:(BOOL)aAnimated;

// Note: The rotate event will make the UIScrollView scroll unexpectly, call willRotate and didRotate to avoid it.
// call willRotate in - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//  and didRotate in - (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation if the screen is rotating
- (void)willRotate;
- (void)didRotate;

@end
