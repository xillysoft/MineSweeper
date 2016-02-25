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
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:gestureRecognizer];
}

-(void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{    
    CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
    
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
        NSLog(@"--touched at cell:[%d, %d]", row, column);
        [self.playerBoard checkCellStateAtRow:row column:column];
        [self setNeedsDisplay];
    }

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
    
    CGFloat x = x0;
    for(int row=0; row<rows; row++, x+=size){
        CGFloat y = y0;
        for(int column=0; column<columns; column++, y+=size){
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
                    CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
                    CGContextFillEllipseInRect(context, cellRect);
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
                        CGRect rect1 = CGRectMake(x, (size-textSize.height)/2, size, size);
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
