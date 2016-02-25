//
//  MineBoardView.m
//  mine_sweeper
//
//  Created by 赵小健 on 2/24/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import "MineBoardView.h"

@interface MineBoardView()

@end

@implementation MineBoardView{
    MineBoard *_mineBoard;
}

- (void)setMineBoard:(MineBoard *)mineBoard
{
    _mineBoard = mineBoard;
    [self setNeedsDisplay];
}

- (MineBoard *)mineBoard
{
    return _mineBoard;
}

- (void)drawRect:(CGRect)rect
{
    CGRect bounds = [self bounds];
    CGFloat hSize = bounds.size.width/_mineBoard.columns;
    CGFloat vSize = bounds.size.height/_mineBoard.rows;
    CGFloat size = MIN(hSize, vSize);
    CGFloat x0 = (bounds.size.width - size*_mineBoard.columns)/2;
    CGFloat y0 = (bounds.size.height - size*_mineBoard.rows)/2;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect0 = CGRectMake(x0-1, y0-1, size*_mineBoard.columns+2, size*_mineBoard.rows+2);
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextFillRect(context, rect0);

    UIFont *textFont = [UIFont boldSystemFontOfSize:12];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attri = @{NSFontAttributeName:textFont, NSForegroundColorAttributeName: [UIColor blueColor], NSParagraphStyleAttributeName:paraStyle};
    
    CGFloat y = y0;
    for(int r=0; r<_mineBoard.rows; r++, y+=size){
        CGFloat x = x0;
        for(int c=0; c<_mineBoard.columns; c++, x+=size){
            BOOL hasMine = [_mineBoard hasMineAtRow:r column:c];
            UIColor *color = hasMine ? [UIColor redColor] : [UIColor lightGrayColor];
            CGRect rect = CGRectMake(x, y, size, size);
            CGContextSetFillColorWithColor(context, [color CGColor]);
            CGContextFillRect(context, rect);
            CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
            CGContextStrokeRect(context, rect);
            if(! hasMine){
                int numberOfMinesAround = [_mineBoard numberOfMinesAroundCellAtRow:r column:c];
                if(numberOfMinesAround > 0 ){
                    NSString *text = [NSString stringWithFormat:@"%d", numberOfMinesAround];
                    CGSize textSize = [text sizeWithAttributes:attri];
                    CGRect rectText = CGRectMake(x, y+(size-textSize.height)/2, size, textSize.height);
                    [text drawInRect:rectText withAttributes:attri];
                }
            }
        }
    }
}

@end
