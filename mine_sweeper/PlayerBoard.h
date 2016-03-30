//
//  PlayerBoard.h
//  mine_sweeper
//
//  Created by 赵小健 on 2/25/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MineBoard.h"

typedef NS_ENUM(NSInteger, CellState){
    CellStateCoveredNoMark, //覆盖，不可见
    CellStateCoveredMarkedAsMine, //标记为雷
    CellStateCoveredMarkedAsUncertain, //标记为不确定
    CellStateUncovered //点击开，无雷;对于无雷的单元个，在其上显示周围雷数目
};


@interface PlayerBoard : NSObject

//@property(strong, readonly) MineBoard *mineBoard;

@property(readonly) int rows;
@property(readonly) int columns;

//------Mineboard interface delegate
- (BOOL)hasMineAtRow:(int)row column:(int)column;
/**
 * return whether there is a cell with mine around cell[row][column]
 */
-(BOOL)hasMineAroundCellAtRow:(int)row column:(int)column;

/**
 * return number of mines around cell[row][column]
 */
- (int)numberOfMinesAroundCellAtRow:(int)row column:(int)column;

/**
 * return numberOfMines laied
 */
-(int)numberOfMines;

/**
 * lay numberOfMines mines on this MineBoard randomly
 */
- (void)layMines:(int)numOfMines;



//------PlayerBoard interface
-(instancetype)initWithRows:(int)rows columns:(int)columns;
//-(instancetype)initWithMineBoard:(MineBoard *)mineBoard; //mineBoard is private to PlayerBoard

- (CellState)cellStateAtRow:(int)row column:(int)column;
- (void)setCellState:(CellState)state AtRow:(int)row column:(int)column;

/**
 * return the number of cells that is around cell[row][column] and state being CellStateCoveredMarkedAsMine
 */
- (int)numberOfMarkedAsMinesAround:(int)row column:(int)column;

/**
 * uncover all cells around cell[row][column] that is not in state CellStateCoveredMarkedAsMine
 * @pre-condition: none
 */
- (BOOL)uncoverAllNotMarkedAsMineCellsAround:(int)row column:(int)column;

/**
 * Uncover cell[row][column] and all cells around this cell RECURSIVELY that is covered and has no mine
 * @pre-condition:
 *      1. cellState[row][column]==CellStateCoveredNoMark
 *      2. not hasMine at cell[row][column]
 *
 */
- (BOOL)uncoverCellAtRow:(int)row column:(int)column;

@end

