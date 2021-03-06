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


@protocol IPlayerBoardDelegate <NSObject>

-(void)minesLaidOnMineBoard:(int)numberOfMinesLaid; //布雷完成
-(void)cellMarkChangedFrom:(CellState)oldState to:(CellState)newState atRow:(int)row column:(int)column;
-(void)cellDidUncoverAtRow:(int)row column:(int)column; //打开了一个无雷的单元格
-(void)mineDidExplodAtRow:(int)row column:(int)column; //打开了一个雷，player dead

@end


@interface PlayerBoard : NSObject

@property(readwrite, weak) id<IPlayerBoardDelegate> delegate; //weak引用

//@property(strong, readonly) MineBoard *mineBoard; //move to private property

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
-(int)numberOfMinesLaid;

/**
 * lay numberOfMines mines on this MineBoard randomly
 * ensure that there is no mine at (row, column)
 */
-(void)layMines:(int)numOfMines ensureNoMineAtRow:(int)row column:(int)column;



//------PlayerBoard interface
-(instancetype)initWithRows:(int)rows columns:(int)columns;
//-(instancetype)initWithMineBoard:(MineBoard *)mineBoard; //mineBoard is private to PlayerBoard

- (CellState)cellStateAtRow:(int)row column:(int)column;
/**
 * 标记雷
 * stateMark:={CellStateCorveredNoMark, CellStateCorveredMarkedAsMine, CellStateCoveredMarkedAsUncertain}
 */
-(void)setCellMarkFrom:(CellState)oldStateMark toNewMark:(CellState)stateMark atRow:(int)row column:(int)column;

/**
 * return the number of cells that is around cell[row][column] and state being CellStateCoveredMarkedAsMine
 */
- (int)numberOfMarkedAsMinesAroundRow:(int)row column:(int)column;

-(void)tryUncoverCellAtRow:(int)row column:(int)column recursive:(BOOL)recursive;

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



