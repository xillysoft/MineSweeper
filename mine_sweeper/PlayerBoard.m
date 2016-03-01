
//
//  PlayerBoard.m
//  mine_sweeper
//
//  Created by 赵小健 on 2/25/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import "PlayerBoard.h"
#import "MineBoard.h"

@interface PlayerBoard()
@property(readwrite) int rows;
@property(readwrite) int columns;
@property(readwrite) MineBoard *mineBoard;
@end

@implementation PlayerBoard{
    NSMutableData *_playerBoardData;
}

-(instancetype)initWithRows:(int)rows columns:(int)columns
{
    self = [super init];
    if(self){
        _rows = rows;
        _columns = columns;
        _mineBoard = [[MineBoard alloc] initWithRows:rows columns:columns];
        [self createPlayBoardData];
    }
    return self;
}

- (instancetype)initWithMineBoard:(MineBoard *)mineBoard
{
    self = [super init];
    if(self){
        _mineBoard = mineBoard;
        _rows = mineBoard.rows;
        _columns = mineBoard.columns;
        [self createPlayBoardData];
    }
    return self;
}

-(void)createPlayBoardData
{
    int rows = self.rows;
    int columns = self.columns;
    _playerBoardData = [NSMutableData dataWithLength:rows*columns*sizeof(CellState)];
    CellState *cellStates = (CellState *)[_playerBoardData bytes];
    for(int i=0; i<rows*columns; i++){
        cellStates[i] = CellStateCovered;
    }
}

/** cell state of plyaer
 */
- (CellState)cellStateAtRow:(int)row column:(int)column
{
    CellState *cells = (CellState *)[_playerBoardData bytes];
    return cells[row*self.columns+column];
}

- (void)setCellState:(CellState)state AtRow:(int)row column:(int)column
{
    CellState *cells = (CellState *)[_playerBoardData bytes];
    cells[row*self.columns+column] = state;
}

/**
 * The number of cells that is of CellStateMarkedAsMine around cell[row][column]
 */
- (int)numberOfMarkedAsMinesAround:(int)row column:(int)column
{
    int count=0;
    for(int r=row-1; r<=row+1; r++){
        for(int c=column-1; c<=column+1; c++){
            if((r>=0 && r<self.rows) && (c>=0 && c<self.columns) && !(r==row && c==column)){
                if([self cellStateAtRow:r column:c] == CellStateMarkedAsMine){
                    count++;
                }
            }
        }
    }
    return count;
}

/** 
 * uncover all cells around cell[row][column] is not in state CellStateMarkedAsMine
 * @pre-condition: none
 */
- (BOOL)uncoverAllNotMarkedAsMineCellsAround:(int)row column:(int)column
{
    //周围实际雷数
    int numberOfMinesAround = [self.mineBoard numberOfMinesAroundCellAtRow:row column:column];

    //周围标记为雷的数目
    int numberOfMarkedAsMinesAround = [self numberOfMarkedAsMinesAround:row column:column];
    if(numberOfMarkedAsMinesAround == numberOfMinesAround){
        //uncover all cells that is not marked as mine
        for(int r=row-1; r<=row+1; r++){
            for(int c=column-1; c<=column+1; c++){
                if((r>=0 && r<self.rows) && (c>=0 && c<self.columns) && !(r==row && c==column)){
                    CellState cellState = [self cellStateAtRow:r column:c];
                    if(cellState == CellStateCovered){ //so that it is not CellStateMarkedAsMine
                        BOOL success = [self uncoverCellAtRow:r column:c];
                        if(! success){
                            return FALSE;
                        } //else continue;
                    }
                }
            }
        }
    }

    return TRUE;
}

/**
 * Uncover cell[row][column] and all cells around this cell RECURSIVELY that is covered and has no mine
 * @pre-condition: 
 *      1. cellState[row][column]==CellStateCovered
 *      2. not hasMine at cell[row][column], or else return FALSE.
 *
 */
- (BOOL)uncoverCellAtRow:(int)row column:(int)column
{
    if([self cellStateAtRow:row column:column] == CellStateCovered){ //only do uncover covered cells
        
        if([self.mineBoard hasMineAtRow:row column:column]){
            [self setCellState:CellStateUncovered AtRow:row column:column];
            return FALSE; //player dead.
        }
        
        //not has mine, set state to Uncovered
        [self setCellState:CellStateUncovered AtRow:row column:column]; //uncover cell[row][column]
        
        //process cells around cell[row][column]
        int numberOfMinesAround = [self.mineBoard numberOfMinesAroundCellAtRow:row column:column];
        int numberOfMarkedAsMinesAround = [self numberOfMarkedAsMinesAround:row column:column];
        if(numberOfMinesAround == numberOfMarkedAsMinesAround){ //there isn't mine around cell[row][column]
            for(int r=row-1; r<=row+1; r++){
                for(int c=column-1; c<=column+1; c++){
                    if((r>=0 && r<self.rows) && (c>=0 && c<self.columns) && !(r==row && c==column)){
                        //TODO: change depth-first to broadth-first non-recursive algorithm
                        BOOL success = [self uncoverCellAtRow:r column:c]; //precondition: there isn't mine at cell[r][c]
                        if(! success){
                            return FALSE; //player dead, don't continue.
                        }// else continue;
                    }
                }
            }
        }
    }
    return TRUE;
}

@end
