//
//  MineBoard.h
//  mine_sweeper
//
//  Created by 赵小健 on 2/24/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MineBoard : NSObject
@property(readonly) int rows;
@property(readonly) int columns;
@property(readonly) int numberOfMines;

/**
 * designated initializer
 * generate a MineBoard with specified rows and columns
 */
- (instancetype)initWithRows:(int)rows columns:(int)columns;

- (void)setMineAtRow:(int)row column:(int)column;
- (void)clearMineAtRow:(int)row column:(int)column;
- (BOOL)hasMineAtRow:(int)row column:(int)column;

/**
 * lay numberOfMines mines on this MineBoard randomly
 */
- (void)layMines:(int)numOfMines;

/**
 * return number of mines around cell[row][column]
 */
- (int)numberOfMinesAroundCellAtRow:(int)row column:(int)column;
@end
