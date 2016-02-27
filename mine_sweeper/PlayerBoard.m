
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

//internal use only
- (void)checkCellStateAtRow:(int)row column:(int)column
{
    if([self cellStateAtRow:row column:column] == CellStateCovered){ //Cell is covered
        if([self.mineBoard hasMineAtRow:row column:column]){ //there is a mine at checked position
            //TODO: player state==>dead
            NSLog(@"###There is mine here, player dead!");
        }else{ //there isn't a mine at checked position
            [self setCellState:CellStateUncovered AtRow:row column:column];
            if ([self.mineBoard numberOfMinesAroundCellAtRow:row column:column] == 0) { //there isn't mine around this position
                //TODO: recursively uncover cells around this cell
                [self uncoverCellAtRow:row column:column];
            }
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

//internal use only
- (void)uncoverCellAtRow:(int)row column:(int)column
{
    if([self cellStateAtRow:row column:column] == CellStateCovered){
        if([self.mineBoard numberOfMinesAroundCellAtRow:row column:column] == 0){
            for(int r=row-1; r<=row+1; r++){
                for(int c=column-1; c<=column+1; c++){
                    if(!(r==row && c==column) && (r>=0 && r<[self rows]) && (c>=0 && c<[self columns])){
                        [self setCellState:CellStateUncovered AtRow:r column:c];
                        //recursively uncover cells without mines around
                        [self uncoverCellAtRow:r column:c];
                    }
                }
            }
        }
    }
}

@end
