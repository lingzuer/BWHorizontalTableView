//
//  BWHorizontalTableView.m
//
//  Created by bw ye on 12-1-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BWHorizontalTableView.h"

@implementation BWHorizontalTableView

#define kReusableCellsCapacity  5

@synthesize dataSource = dataSource_;
@synthesize delegate = delegate_;
@synthesize contentOffset = contentOffset_;
@synthesize indexForFirstVisibleCell = indexForFirstVisibleCell_;
@synthesize indexForSelectedCell = indexForSelectedCell_;

#pragma mark - Private Methods

- (void)initialize
{
    needsReload_ = YES;
    
    cells_ = [[NSMutableArray alloc] init];
    reusableCells_ = [[NSMutableArray alloc] init];

    indexForFirstVisibleCell_ = 0;
    indexForSelectedCell_ = 0;

    scrollView_ = [[UIScrollView alloc] initWithFrame:self.bounds];
    
    [scrollView_ setDelegate:self];
    [scrollView_ setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [scrollView_ setBackgroundColor:[UIColor clearColor]];
    
    // In iOS4, UIScrollView always calls the layoutSubviews of the superview while scrolling;
    // Here we add another superview for it
    UIView *superViewOfScrollView = [[UIView alloc] initWithFrame:self.bounds];
    [superViewOfScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [superViewOfScrollView setBackgroundColor:[UIColor clearColor]];
    [superViewOfScrollView addSubview:scrollView_];

    [self setBackgroundColor:[UIColor clearColor]];
    [self addSubview:superViewOfScrollView];
    [superViewOfScrollView release];
}

- (CGFloat)offsetWithSelectedIndex:(NSInteger)aIndex
{   
    BOOL enoughSpaceAtLeft  = indexForSelectedCell_*widthForCell_ >= (self.bounds.size.width-widthForCell_)/2;
    BOOL enoughSpaceAtRight = scrollView_.contentSize.width-indexForSelectedCell_*widthForCell_ > (self.bounds.size.width+widthForCell_)/2;
    CGFloat offset = 0.f;
    if (!enoughSpaceAtLeft)
    {
        offset = 0.f;
    }
    else
    {
        if (enoughSpaceAtRight)
        {
            offset = indexForSelectedCell_*widthForCell_ - (self.bounds.size.width-widthForCell_)/2;
        }
        else
        {
            offset = scrollView_.contentSize.width - self.bounds.size.width;
        }
    }
    
    return offset;
}

- (void)queueReuseCell:(UIView *)aCell
{
    if (aCell==nil || [reusableCells_ count]>=kReusableCellsCapacity)
    {
        return;
    }
    
#ifdef BWHT_DEBUG_ENABLED
    NSLog(@"BWHorizontalTableView: Add cell at index: %d to reusable cells(count: %d)", [self indexForCell:aCell], [reusableCells_ count]);
#endif
    
    [reusableCells_ addObject:aCell];
}

- (void)removeCellAtIndex:(NSInteger)aIndex
{
	NSParameterAssert(aIndex>=0 && aIndex<[cells_ count]);
    
    UIView *cell = [self cellForIndex:aIndex];
    [self queueReuseCell:cell];	
    
	if (cell.superview != nil)
    {
		[cell removeFromSuperview];
	}
    
    [cells_ replaceObjectAtIndex:aIndex withObject:[NSNull null]];
}

- (void)layoutCellAtIndex:(NSInteger)aIndex animated:(BOOL)aAnimated
{
	NSParameterAssert(aIndex>=0 &&aIndex<[cells_ count]);
    
	UIView *cell = [cells_ objectAtIndex:aIndex];
	if ((NSObject *)cell == [NSNull null])  // no loaded yet
    {
#ifdef BWHT_DEBUG_ENABLED
        NSLog(@"BWHorizontalTableView: Layouting new cell at index: %d", aIndex);
#endif
		
        cell = [dataSource_ horizontalTableView:self cellAtIndex:aIndex];
        NSAssert(cell!=nil, @"datasource must not return nil cell");
        
        [cells_ replaceObjectAtIndex:aIndex withObject:cell];
	}

    if (cell.superview == nil)
    {
        [scrollView_ addSubview:cell];
        [cell setAlpha:0.f];
        [cell setFrame:CGRectMake(aIndex * widthForCell_, 0.f, widthForCell_, self.bounds.size.height)];
        
        if (aAnimated)
        {
            [UIView animateWithDuration:0.3f animations:^{
                [cell setAlpha:1.f];
            }];
        }
        else
        {
            [cell setAlpha:1.f];
        }
    }
    else
    {
        if (aAnimated)
        {
            [UIView animateWithDuration:0.3f animations:^{
                [cell setFrame:CGRectMake(aIndex * widthForCell_, 0.f, widthForCell_, self.bounds.size.height)];
            }];   
        }
        else
        {
            [cell setFrame:CGRectMake(aIndex * widthForCell_, 0.f, widthForCell_, self.bounds.size.height)];
        }
    }
}
- (void)layoutAllCellsAnimated:(BOOL)aAnimated
{
    // Step 1: Caculate the number of visible cells, now we have the first visible cell index;
	// If the first visible cell is much wider than the cells near by, there will be problems if only "+2", because
    // When the first visible cell scrolls to the left, the layoutAllCells will not be called, if the firstVisibleIndex_ not changed.
    numberOfVisibleCells_ = 0;
	CGFloat visibleCellsWidth = 0.f;
    for (NSInteger index=indexForFirstVisibleCell_; index<[cells_ count]; index++)
    {
		numberOfVisibleCells_++;
        visibleCellsWidth = numberOfVisibleCells_ * widthForCell_;
		if (visibleCellsWidth>=self.bounds.size.width && visibleCellsWidth-widthForCell_>=self.bounds.size.width)
        {
			break;
		}
	}
    numberOfVisibleCells_ = MIN(numberOfVisibleCells_, [cells_ count]);   // Plus 2 for: One left nearby, one right nearby;
    
    // Step 2: Layout the visible cells, remove the invisible cell
	NSInteger leftMostVisibleCellIndex = MAX(indexForFirstVisibleCell_, 0);
	NSInteger rightMostVisibleCellIndex = MIN(leftMostVisibleCellIndex+numberOfVisibleCells_-1, [cells_ count]-1);
    
#ifdef BWHT_DEBUG_ENABLED
    //NSLog(@"BWHorizontalTableView: Layouting %d-%d (%d)cells", leftMostVisibleCellIndex, rightMostVisibleCellIndex, numberOfVisibleCells_);
#endif
    
    for (NSInteger index=0; index<leftMostVisibleCellIndex; index++)
    {
        [self removeCellAtIndex:index];
    }
    
    for (NSInteger index=rightMostVisibleCellIndex+1; index<[cells_ count]; index++)
    {
        [self removeCellAtIndex:index];
    }
    
	for (NSInteger index=leftMostVisibleCellIndex; index<=rightMostVisibleCellIndex; index++)
    {
		[self layoutCellAtIndex:index animated:aAnimated];
	}
}

#pragma mark - Public Methods

- (UIView *)dequeueReusableCell
{
    UIView *cell = [[reusableCells_ lastObject] retain];
    if (cell != nil)
    {
        [reusableCells_ removeLastObject];
    }
    
    return [cell autorelease];
}

- (UIView *)cellForIndex:(NSInteger)aIndex
{
    NSParameterAssert(aIndex>=0 && aIndex<[cells_ count]);
    
	UIView *cell = [cells_ objectAtIndex:aIndex];
	if ((NSObject *)cell == [NSNull null])
    {
		cell = nil;
	}
    
	return cell;
}

- (NSInteger)indexForCell:(UIView *)aCell
{
    NSParameterAssert(aCell != nil);
    
	NSInteger index;
	for (index=0; index<[cells_ count]; index++)
    {
		if ([cells_ objectAtIndex:index] == aCell)
        {
			break;
		}
	}
    
	if (index == [cells_ count])
    {
		index = NSNotFound;
	}
	
	return index;
}

- (void)reloadData
{
    needsReload_ = YES;

    [self setNeedsLayout];
}

- (void)reloadCellAtIndex:(NSInteger)aIndex animated:(BOOL)aAnimated
{
    NSParameterAssert(aIndex>=0 && aIndex<=[cells_ count]);
    
    if (updating_)
    {
        return;
    }
    updating_ = YES;
    updatingAnimated_ = aAnimated;
    
    [cells_ replaceObjectAtIndex:aIndex withObject:[NSNull null]];
    
    forceLayout_ = YES;
    [self setContentOffset:scrollView_.contentOffset.x animated:NO];
}

- (void)insertCellAtIndex:(NSInteger)aIndex animated:(BOOL)aAnimated
{
    NSParameterAssert(aIndex>=0 && aIndex<=[cells_ count]);
    
    if (updating_)
    {
        return;
    }
    updating_ = YES;
    updatingAnimated_ = aAnimated;
    
    // Reset cells
    [cells_ insertObject:[NSNull null] atIndex:aIndex];
    numberOfCells_++;
    
    // Reset the content size of scroll view
    [scrollView_ setContentSize:CGSizeMake(numberOfCells_*widthForCell_, scrollView_.bounds.size.height)];
    
    // If the cell is not visible, don't update the scrollview
    if (aIndex<indexForFirstVisibleCell_ || aIndex>indexForFirstVisibleCell_+numberOfVisibleCells_-1)
    {
        updating_ = NO;
        return;
    }
        
    forceLayout_ = YES;
    [self setContentOffset:scrollView_.contentOffset.x animated:NO];
}

- (void)deleteCellAtIndex:(NSInteger)aIndex animated:(BOOL)aAnimated
{
	NSParameterAssert(aIndex>=0 && aIndex<[cells_ count]);
    
    if (updating_)
    {
        return;
    }
    updating_ = YES;
    updatingAnimated_ = aAnimated;
    
    // Remove the cell from super view without animation
    [self removeCellAtIndex:aIndex];
    
    // Reset the cells_, minus 1
    [cells_ removeObjectAtIndex:aIndex];
    numberOfCells_--;
    
    // Reset the content size of scroll view
    [scrollView_ setContentSize:CGSizeMake(numberOfCells_*widthForCell_, scrollView_.bounds.size.height)];
    
    // If the cell is not visible, don't update the scrollview
    if (aIndex<indexForFirstVisibleCell_ || aIndex>indexForFirstVisibleCell_+numberOfVisibleCells_-1)
    {
        updating_ = NO;
        return;
    }
    
    // Reset the content offset of scroll view
    CGFloat contentOffsetX = scrollView_.contentOffset.x;
    if (scrollView_.contentOffset.x + scrollView_.bounds.size.width > scrollView_.contentSize.width)
    {
        contentOffsetX = scrollView_.contentSize.width - scrollView_.bounds.size.width;
    }
    contentOffsetX = MAX(0, contentOffsetX);
    
    forceLayout_ = YES;
    [self setContentOffset:contentOffsetX animated:YES];
}

- (void)selectCellAtIndex:(NSInteger)aIndex animated:(BOOL)aAnimated;
{
    if ([cells_ count] == 0)    // Just set the indexForSelectedCell_
    {
        indexForSelectedCell_ = aIndex;
        
        return;
    }
    
	NSParameterAssert(aIndex>=0 && aIndex<[cells_ count]);
	
    indexForSelectedCell_ = aIndex;

    [self setContentOffset:[self offsetWithSelectedIndex:aIndex] animated:aAnimated];
}

- (void)setContentOffset:(CGFloat)aContentOffset
{
    if (numberOfCells_ == 0)
    {
        contentOffset_ = aContentOffset;
    }
    else
    {
        [self setContentOffset:aContentOffset animated:NO];
    }
}

- (void)setContentOffset:(CGFloat)aOffset animated:(BOOL)aAnimated;
{
    // If the contet offset is not changed and not forced, return directly
    if (aOffset==scrollView_.contentOffset.x && !forceLayout_)
    {
        return;
    }
    
    contentOffset_ = aOffset;
    
    aOffset = MAX(0, MIN(scrollView_.contentSize.width-self.bounds.size.width, aOffset));
    
    //1. Caculate the indexForFirstVisibleCell_ with aOffset
    for (NSInteger index=0; index<[cells_ count]; index++)
    {
        if ((index+1)*widthForCell_ > aOffset)
        {
            indexForFirstVisibleCell_ = index;
            break;
        }
    }
    
    if (aOffset == scrollView_.contentOffset.x) // If offset is not changed
    {
        [self layoutAllCellsAnimated:updatingAnimated_];
        
        forceLayout_ = NO;
        updating_ = NO;
    }
    else
    {   
        ignoreScroll_ = aAnimated;
        
        [scrollView_ setContentOffset:CGPointMake(aOffset, 0.f) animated:aAnimated];
        
        if (!aAnimated)
        {
            [self layoutAllCellsAnimated:updatingAnimated_];
            
            updating_ = NO;
        }
    }
}

- (void)willRotate
{
    ignoreScroll_ = YES;
}

- (void)didRotate
{
    ignoreScroll_ = NO;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{    
    if (ignoreScroll_)
    {
        if (updating_)
        {
            [self layoutAllCellsAnimated:updatingAnimated_];
            updating_ = NO;
        }
        else
        {
            [self layoutAllCellsAnimated:NO];
        }

    }
    
    ignoreScroll_ = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (ignoreScroll_)
    {
        return;
    }

    contentOffset_ = scrollView_.contentOffset.x;
    
	NSInteger index = 0;
	for (index=0; index<MIN(indexForFirstVisibleCell_+1, [cells_ count]); index++)
    {
		if ((index+1)*widthForCell_ > scrollView.contentOffset.x)
        {
			break;
		}
	}
    
    if (indexForFirstVisibleCell_ == index)
    {
        return;
    }
    
	indexForFirstVisibleCell_ = index;

	[self layoutAllCellsAnimated:NO];    
}


#pragma mark - System Frame work

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        [self initialize];
    }
    
    return self;
}

- (void)layoutSubviews
{
    if (needsReload_)
    {
        needsReload_ = NO;

        // Reset the numberOfCells_
        numberOfCells_ = [self.dataSource numberOfCellsInHorizontalTableView:self];
        if (numberOfCells_ == 0)
        {
            return;
        }
        
        // Clean the memory of old cells
        for (NSInteger index=0; index<[cells_ count]; index++)
        {
            UIView *cell = [cells_ objectAtIndex:index];
            if ((NSObject *)cell != [NSNull null])
            {
                if (cell.superview != nil)
                {
                    [cell removeFromSuperview];
                }
            }   
        }
        [cells_ removeAllObjects];
        [reusableCells_ removeAllObjects];
        
        indexForFirstVisibleCell_ = 0;

        // User may set the indexForSelectedCell_ after calling reloadData, so keep this value here
        indexForSelectedCell_ = MIN(indexForSelectedCell_, numberOfCells_-1);

        // Fill the cells_ with [NSNull null]
        for (NSInteger index=0; index<numberOfCells_; index++)
        {
            [cells_ addObject:[NSNull null]];
        }
    }
    
    // Refresh the width for cell
    widthForCell_ = [dataSource_ widthForCellInHorizontalTableView:self];
    
    // Refresh the content size of scrollview_
    [scrollView_ setContentSize:CGSizeMake(numberOfCells_*widthForCell_, self.bounds.size.height)];
    
    forceLayout_ = YES; // Layout all the cells even if the offset not changed;
    [self setContentOffset:[self offsetWithSelectedIndex:indexForSelectedCell_] animated:YES];   
}

- (void)dealloc
{
    [cells_ release];
    [reusableCells_ release];
    
    [scrollView_ removeFromSuperview];
    [scrollView_ release];
    
    [super dealloc];
}

@end
