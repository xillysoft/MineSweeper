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

@implementation MineBoardView

- (void)setMineBoard:(MineBoard *)mineBoard
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGRect bounds = [self bounds];
    CGFloat hSize = bounds.size.width/self.mineBoard.columns;
    CGFloat vSize = bounds.size.height/self.mineBoard.rows;
    CGFloat size = MIN(hSize, vSize);
    CGFloat x0 = (bounds.size.width - size*self.mineBoard.columns)/2;
    CGFloat y0 = (bounds.size.height - size*self.mineBoard.rows)/2;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect0 = CGRectMake(x0-1, y0-1, size*self.mineBoard.columns+2, size*self.mineBoard.rows+2);
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextFillRect(context, rect0);

    UIFont *textFont = [UIFont boldSystemFontOfSize:12];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attri = @{NSFontAttributeName:textFont, NSForegroundColorAttributeName: [UIColor blueColor], NSParagraphStyleAttributeName:paraStyle};
    
    CGFloat y = y0;
    for(int r=0; r<self.mineBoard.rows; r++, y+=size){
        CGFloat x = x0;
        for(int c=0; c<self.mineBoard.columns; c++, x+=size){
            BOOL hasMine = [self.mineBoard hasMineAtRow:r column:c];
            UIColor *color = hasMine ? [UIColor redColor] : [UIColor lightGrayColor];
            CGRect rect = CGRectMake(x, y, size, size);
            CGContextSetFillColorWithColor(context, [color CGColor]);
            CGContextFillRect(context, rect);
            CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
            CGContextStrokeRect(context, rect);
            if(! hasMine){
                int numberOfMinesAround = [self.mineBoard numberOfMinesAroundCellAtRow:r column:c];
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
