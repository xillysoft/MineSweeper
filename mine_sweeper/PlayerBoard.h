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
    CellStateCovered, //覆盖，不可见
    CellStateUncovered, //点击开，无雷;对于无雷的单元个，在其上显示周围雷数目
    CellStateMarkedAsMine, //标记为雷
    CellStateMarkedAsUncertain, //标记为不确定
};


@interface PlayerBoard : NSObject

@property(readonly) int rows;
@property(readonly) int columns;

-(instancetype)initWithRows:(int)rows columns:(int)columns;
-(instancetype)initWithMineBoard:(MineBoard *)mineBoard; //TODO: remove this initializer
@property(strong, readonly) MineBoard *mineBoard;
- (CellState)cellStateAtRow:(int)row column:(int)column;
- (void)setCellState:(CellState)state AtRow:(int)row column:(int)column;

/**
 * return the number of cells that is around cell[row][column] and state being CellStateMarkedAsMine
 */
- (int)numberOfMarkedAsMinesAround:(int)row column:(int)column;

/**
 * uncover all cells around cell[row][column] is not in state CellStateMarkedAsMine
 * @pre-condition: none
 */
- (BOOL)uncoverAllNotMarkedAsMineCellsAround:(int)row column:(int)column;

/**
 * Uncover cell[row][column] and all cells around this cell RECURSIVELY that is covered and has no mine
 * @pre-condition:
 *      1. cellState[row][column]==CellStateCovered
 *      2. not hasMine at cell[row][column]
 *
 */
- (BOOL)uncoverCellAtRow:(int)row column:(int)column;
@end

