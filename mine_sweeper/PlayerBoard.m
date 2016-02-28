
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
@property(readwrite) MineBoard *mineBoard;
@end

@implementation PlayerBoard{
    NSMutableData *_playerBoardData;
}

- (instancetype)initWithMineBoard:(MineBoard *)mineBoard
{
    self = [super init];
    if(self){
        _mineBoard = mineBoard;
        
        const int rows = [mineBoard rows];
        const int columns = [mineBoard columns];
        _playerBoardData = [NSMutableData dataWithLength:rows*columns*sizeof(CellState)];
        CellState *cellStates = (CellState *)[_playerBoardData bytes];
        for(int i=0; i<rows*columns; i++){
            cellStates[i] = CellStateCovered;
        }
    }
    return self;
}

- (int)rows
{
    return self.mineBoard.rows;
}
- (int)columns
{
    return self.mineBoard.columns;
}

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

- (void)uncoverUnmarkedAsMineCellsAround:(int)row column:(int)column
{
    BOOL success = TRUE;
    for(int r=row-1; r<=row+1 && success; r++){
        for(int c=column-1; c<=column+1 && success; c++){
            if((r>=0 && r<self.rows) && (c>=0 && c<self.columns) && !(r==row && c==column)){
                CellState cellState = [self cellStateAtRow:r column:c];
                if(cellState == CellStateCovered){ //so that it is not CellStateMarkedAsMine
                    if(! [self.mineBoard hasMineAtRow:r column:c]){
                        [self setCellState:CellStateUncovered AtRow:r column:c];
                        if([self.mineBoard numberOfMinesAroundCellAtRow:r column:c] == 0){
                            [self uncoverUnmarkedAsMineCellsAround:r column:c];
                        }
                    }else{ //uncover a cell that is a mine, player dead.
                        success = FALSE;
                        [self setCellState:CellStateUncovered AtRow:r column:c];
                    }
                }
            }
        }
    }
    if(! success){
        //TODO: player state==>dead
        NSLog(@"--Player Dead!");
    }
}

//internal use only
- (void)checkCellStateAtRow:(int)row column:(int)column
{
    if([self cellStateAtRow:row column:column] == CellStateCovered){ //Cell is covered
        if([self.mineBoard hasMineAtRow:row column:column]){ //there is a mine at checked position
            [self setCellState:CellStateUncovered AtRow:row column:column];
            //TODO: player state==>dead
//            NSLog(@"###There is mine here, player dead!");
            
        }else{ //there isn't a mine at checked position cell[row][column]
            //precondition: cell[row][column]: (1)covered (2)hasn't mine
            [self uncoverCellAtRow:row column:column];
        }
    }
}

//internal use only
- (void)markCellAtRow:(int)row column:(int)column
{
    if([self cellStateAtRow:row column:column] == CellStateCovered){ //Cell is covered
        [self setCellState:CellStateMarkedAsMine AtRow:row column:column];
    }
}

//pre-condition: has no mine at cell[row][column]
- (void)uncoverCellAtRow:(int)row column:(int)column
{
    if([self cellStateAtRow:row column:column] == CellStateCovered){ //only do uncover covered cells
        [self setCellState:CellStateUncovered AtRow:row column:column]; //uncover cell[row][column]
        //process cells around cell[row][column]
        int numberOfMinesAround = [self.mineBoard numberOfMinesAroundCellAtRow:row column:column];
        if(numberOfMinesAround == 0){ //there isn't mine around cell[row][column]
            for(int r=row-1; r<=row+1; r++){
                for(int c=column-1; c<=column+1; c++){
                    if((r>=0 && r<self.rows) && (c>=0 && c<self.columns) && !(r==row && c==column))
                        //TODO: change depth-first to broadth-first non-recursive algorithm
                        [self uncoverCellAtRow:r column:c]; //precondition: there isn't mine at cell[r][c]
                }
            }
        }
    }
    
}

@end
