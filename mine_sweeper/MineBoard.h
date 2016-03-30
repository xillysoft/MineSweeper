//
//  MineBoard.h
//  mine_sweeper
//
//  Created by 赵小健 on 2/24/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MineBoard : NSObject
/**
 * number of row in the mineboard
 */
@property(readonly) int rows;
/**
 * number of columns in the mineboard
 */
@property(readonly) int columns;
/**
 * number of mines layed.
 */
@property(readonly) int numberOfMines;

/**
 * designated initializer
 * generate a MineBoard with specified rows and columns
 */
- (instancetype)initWithRows:(int)rows columns:(int)columns;

/**
 * get and set mine at location (row, column)
 */
- (void)setMineAtRow:(int)row column:(int)column;
- (void)clearMineAtRow:(int)row column:(int)column;
- (BOOL)hasMineAtRow:(int)row column:(int)column;

/**
 * lay randomly numOfMines mines in the rows*columns mineboard
 */
- (void)layMines:(int)numOfMines;
/**
 * return whether there is a cell with mine around cell[row][column]
 */
-(BOOL)hasMineAroundCellAtRow:(int)row column:(int)column;

/**
 * return number of mines around cell[row][column]
 */
- (int)numberOfMinesAroundCellAtRow:(int)row column:(int)column;
@end
