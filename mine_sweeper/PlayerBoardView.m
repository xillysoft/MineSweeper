//
//  PlayerBoardView.m
//  mine_sweeper
//
//  Created by 赵小健 on 2/25/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import "PlayerBoard.h"
#import "PlayerBoardView.h"
#import "CellLocation.h"
#import "PlayerBoardViewController.h"

@interface PlayerBoardView()

@end


@implementation PlayerBoardView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initialize];
    }
    return self;
}

-(instancetype)init
{
    self = [super init];
    if(self){
        [self initialize];
    }
    return self;
}

//initializer method
-(void)initialize
{
    //register single-tap handler
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTapRecognizer];
    
    //register double-tap handler
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    [self addGestureRecognizer:doubleTapRecognizer];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPressRecognizer.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:longPressRecognizer];
}

//UITapGestureRecognizer handler, 通知delegate单击事件发生
-(void)handleSingleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{    
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    CellLocation *location = [self cellLocationAtPoint:point];
    if(location && [self.delegate respondsToSelector:@selector(playerBoardView:didSingleTapOnCell:)]) {
        [self.delegate playerBoardView:self didSingleTapOnCell:location];
    }
}


//UITapGestureRecognizer handler，通知delegate双击事件发生
-(void)handleDoubleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    CellLocation *location = [self cellLocationAtPoint:point];
    if(location && [self.delegate respondsToSelector:@selector(playerBoardView:didDoubleTapOnCell:)]){
        [self.delegate playerBoardView:self didDoubleTapOnCell:location];
    }
}

//UITapGestureRecognizer handler，通知delegate长按事件发生
-(void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    //UILongPressGestureRecognizer is a continuous recognizer
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
        CellLocation *location = [self cellLocationAtPoint:point];
        if(location && [self.delegate respondsToSelector:@selector(playerBoardView:didLongPressOnCell:)]) {
            [self.delegate playerBoardView:self didLongPressOnCell:location];
        }
    }
}

//计算在view上的touch point(x,y)对应的单元格(row, column)
- (CellLocation *)cellLocationAtPoint:(CGPoint)point
{
    CGRect bounds = self.bounds;
    PlayerBoard *playerBoard = self.playerBoard;
    CGFloat hSize = bounds.size.width/playerBoard.columns;
    CGFloat vSize = bounds.size.height/playerBoard.rows;
    CGFloat size = MIN(hSize, vSize);
    int columns = playerBoard.columns;
    int rows = playerBoard.rows;
    CGFloat x0 = (bounds.size.width-size*columns)/2; //必须和-drawRect:方法相对应
    CGFloat y0 = (bounds.size.height-size*rows)/2;
    point.x -= x0;
    point.y -= y0;
    if(point.x>=0 && point.x<=size*columns && point.y>=0 && point.y<size*rows){
        int row = point.y/size;
        int column = point.x/size;
        return [[CellLocation alloc] initWithRow:row column:column];
    }else{
        return nil;
    }
}


-(void)minesLaidOnMineBoard:(int)numberOfMinesLaid
{
    [self setNeedsDisplay];
}

-(void)cellMarkChangedFrom:(CellState)oldState to:(CellState)newState
{
    [self setNeedsDisplay];
}

-(void)cellDidUncoverAtRow:(int)row column:(int)column
{
    [self setNeedsDisplay];
}

-(void)mineDidExplodAtRow:(int)row column:(int)column
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if(self.playerBoard == nil)
        return;
    
    CGRect bounds = self.bounds;
    PlayerBoard *playerBoard = self.playerBoard;
    CGFloat hSize = bounds.size.width/playerBoard.columns;
    CGFloat vSize = bounds.size.height/playerBoard.rows;
    CGFloat size = MIN(hSize, vSize);
    int columns = playerBoard.columns;
    int rows = playerBoard.rows;
    CGFloat x0 = (bounds.size.width-size*columns)/2;
    CGFloat y0 = (bounds.size.height-size*rows)/2;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSDictionary *attribs =({
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.alignment = NSTextAlignmentCenter;
        @{NSForegroundColorAttributeName:[UIColor blueColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:16], NSParagraphStyleAttributeName:paraStyle};
    });
    

    CGFloat y = y0;
    for(int row=0; row<rows; row++, y+=size){
        CGFloat x = x0;
        for(int column=0; column<columns; column++, x+=size){
            CGRect cellRect = CGRectMake(x, y, size, size);
            CellState state = [self.playerBoard cellStateAtRow:row column:column];
            switch(state){
                case CellStateCoveredNoMark:
                {
                    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
                    CGContextFillRect(context, cellRect);
                    BOOL showHiddenMine = NO;
                    if(showHiddenMine){
                        if([playerBoard hasMineAtRow:row column:column]){
                            CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
                            CGRect rect1 = CGRectMake(x+size/4, y+size/4, size/2, size/2);
                            CGContextStrokeEllipseInRect(context, rect1);
                        }
                    }
                }
                break;
                    
                case CellStateCoveredMarkedAsMine:
                {
                    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
                    CGContextFillRect(context, cellRect);
                    
                    UIImage *mineIcon = [UIImage imageNamed:@"mine_flag.png"];
                    [mineIcon drawInRect:cellRect blendMode:kCGBlendModeNormal alpha:1.0];
                }
                break;
                    
                case CellStateCoveredMarkedAsUncertain:
                {
                    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
                    CGContextFillRect(context, cellRect);
                    NSString *uncertainMark = @"?";
                    NSDictionary *attributes1 = @{NSForegroundColorAttributeName:[UIColor grayColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:20]};
                    CGSize size1 = [uncertainMark sizeWithAttributes:attributes1];
                    CGPoint point1 = CGPointMake(x+(size-size1.width)/2, y+(size-size1.height)/2);
                    [uncertainMark drawAtPoint:point1 withAttributes:attributes1];
                    
                }
                break;
                    
                case CellStateUncovered:
                {
                    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
                    CGContextFillRect(context, cellRect);
                    if([playerBoard hasMineAtRow:row column:column]){
                        CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
                        CGContextFillRect(context, cellRect);
                        
                        UIImage *mineIcon = [UIImage imageNamed:@"Minesweeper_Icon1.png"];
                        [mineIcon drawInRect:cellRect blendMode:kCGBlendModeMultiply alpha:1.0];
                    }else{
                        int numberOfMinesAround = [playerBoard numberOfMinesAroundCellAtRow:row column:column];
                        if(numberOfMinesAround > 0){
                            NSString *text = [NSString stringWithFormat:@"%d", numberOfMinesAround];
                            CGSize textSize = [text sizeWithAttributes:attribs];
                            CGRect rect1 = CGRectMake(x, y+(size-textSize.height)/2, size, size);
                            [text drawInRect:rect1 withAttributes:attribs];
                        }
                    }
                }
                break;
            }
            
            CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
            CGContextStrokeRect(context, cellRect);
        }
    }
}

@end
