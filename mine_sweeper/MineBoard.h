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
 * designated initializer
 * generate a MineBoard with specified rows and columns
 */
- (instancetype)initWithRows:(int)rows columns:(int)columns;

- (int)rows;
- (int)columns;
- (void)setMineAtRow:(int)row column:(int)column;
- (void)clearMineAtRow:(int)row column:(int)column;
- (BOOL)hasMineAtRow:(int)row column:(int)column;

/**
 * lay mines on this MineBoard
 */
- (void)layMines:(int)numOfMines;

- (int)numbOfMines;

- (int)numberOfMinesAroundCellAtRow:(int)row column:(int)column;
@end
