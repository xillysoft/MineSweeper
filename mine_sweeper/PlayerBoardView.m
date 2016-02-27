//
//  PlayerBoardView.m
//  mine_sweeper
//
//  Created by 赵小健 on 2/25/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import "PlayerBoardView.h"
#import "PlayerBoard.h"

@interface PlayerBoardView()


@end


@implementation PlayerBoardView

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initialize];
    }
    return self;
}
-(void)initialize
{
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTapRecognizer];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    [self addGestureRecognizer:doubleTapRecognizer];
    
}

-(void)handleSingleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{    
    CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
    int row, column;
    BOOL onCell = [self cellLocationAtPoint:location resultRow:&row resultColumn:&column];
    if(onCell) {
        [self.playerBoard checkCellStateAtRow:row column:column];
        [self setNeedsDisplay];
    }
}

-(void)handleDoubleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
    int row, column;
    BOOL onCell = [self cellLocationAtPoint:location resultRow:&row resultColumn:&column];
    if(onCell) {
        CellState state = [self.playerBoard cellStateAtRow:row column:column];
        switch(state){
            case CellStateCovered:{
                [self.playerBoard setCellState:CellStateMarkedAsMine AtRow:row column:column];
                [self setNeedsDisplay];
            }
            break;
            
            case CellStateMarkedAsMine:{
                [self.playerBoard setCellState:CellStateMarkedAsUncertain AtRow:row column:column];
                [self setNeedsDisplay];
            }
            break;
                
            case CellStateMarkedAsUncertain:{
                [self.playerBoard setCellState:CellStateCovered AtRow:row column:column];
                [self setNeedsDisplay];
            }
            break;
            
            case CellStateUncovered:{
                
            }
            break;
        }
    }
}

- (BOOL)cellLocationAtPoint:(CGPoint)location resultRow:(int *)resultRowPtr resultColumn:(int *)resultColumnPtr
{
    
    CGRect bounds = self.bounds;
    MineBoard *mineBoard = self.playerBoard.mineBoard;
    CGFloat hSize = bounds.size.width/mineBoard.columns;
    CGFloat vSize = bounds.size.height/mineBoard.rows;
    CGFloat size = MIN(hSize, vSize);
    int columns = mineBoard.columns;
    int rows = mineBoard.rows;
    CGFloat x0 = (bounds.size.width-size*columns)/2;
    CGFloat y0 = (bounds.size.height-size*rows)/2;
    location.x -= x0;
    location.y -= y0;
    if(location.x>=0 && location.x<=size*columns && location.y>=0 && location.y<size*rows){
        int row = location.y/size;
        int column = location.x/size;
        *resultRowPtr = row;
        *resultColumnPtr = column;
        return TRUE;
    }else
        return FALSE;
}

- (void)setPlayerBoard:(PlayerBoard *)playerBoard
{
    _playerBoard = playerBoard;
}

- (void)drawRect:(CGRect)rect
{
    if(self.playerBoard == nil)
        return;
    
    CGRect bounds = self.bounds;
    MineBoard *mineBoard = self.playerBoard.mineBoard;
    CGFloat hSize = bounds.size.width/mineBoard.columns;
    CGFloat vSize = bounds.size.height/mineBoard.rows;
    CGFloat size = MIN(hSize, vSize);
    int columns = mineBoard.columns;
    int rows = mineBoard.rows;
    CGFloat x0 = (bounds.size.width-size*columns)/2;
    CGFloat y0 = (bounds.size.height-size*rows)/2;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSDictionary *attribs =({
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.alignment = NSTextAlignmentCenter;
        @{NSForegroundColorAttributeName:[UIColor blueColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSParagraphStyleAttributeName:paraStyle};
    });
    

    CGFloat y = y0;
    for(int row=0; row<rows; row++, y+=size){
        CGFloat x = x0;
        for(int column=0; column<columns; column++, x+=size){
            CGRect cellRect = CGRectMake(x, y, size, size);
            CellState state = [self.playerBoard cellStateAtRow:row column:column];
            switch(state){
                case CellStateCovered:
                {
                    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
                    CGContextFillRect(context, cellRect);
                }
                break;
                    
                case CellStateMarkedAsMine:
                {
                    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
                    CGContextFillRect(context, cellRect);
                    [[UIColor blueColor] setFill];
                    UIImage *mineIcon = [UIImage imageNamed:@"Minesweeper_Icon1.png"];
                    NSAssert(mineIcon!=nil, @"mine icon could not be loaded.");
                    [mineIcon drawInRect:cellRect blendMode:kCGBlendModeMultiply alpha:1.0];
                }
                break;
                    
                case CellStateMarkedAsUncertain:
                {
                    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
                    CGContextFillRect(context, cellRect);
                    NSString *uncertainMark = @"?";
                    NSDictionary *attributes1 = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:20]};
                    CGSize size1 = [uncertainMark sizeWithAttributes:attributes1];
                    CGPoint point1 = CGPointMake(x+(size-size1.width)/2, y+(size-size1.height)/2);
                    [uncertainMark drawAtPoint:point1 withAttributes:attributes1];

                }
                    break;
                    
                case CellStateUncovered:
                {
                    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
                    CGContextFillRect(context, cellRect);
                    int numberOfMinesAround = [mineBoard numberOfMinesAroundCellAtRow:row column:column];
                    if(numberOfMinesAround > 0){
                        NSString *text = [NSString stringWithFormat:@"%d", numberOfMinesAround];
                        CGSize textSize = [text sizeWithAttributes:attribs];
                        CGRect rect1 = CGRectMake(x, y+(size-textSize.height)/2, size, size);
                        [text drawInRect:rect1 withAttributes:attribs];
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
