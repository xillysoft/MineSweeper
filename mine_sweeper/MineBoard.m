//
//  MineBoard.m
//  mine_sweeper
//
//  Created by 赵小健 on 2/24/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import "MineBoard.h"

@implementation MineBoard{
    NSData *_mineBoardData; //internal mineboard data storage
}

- (instancetype)initWithRows:(int)rows columns:(int)columns
{
    self = [super init];
    if(self){
        _rows = rows;
        _columns = columns;
        _mineBoardData = [NSMutableData dataWithLength:rows*columns*sizeof(BOOL)];
    }
    return self;
}

- (void)setMineAtRow:(int)row column:(int)column
{
    BOOL *cells = (BOOL *)[_mineBoardData bytes];
    cells[row*_columns+column] = TRUE;
}

-(void)clearMineAtRow:(int)row column:(int)column
{
    BOOL *cells = (BOOL *)[_mineBoardData bytes];
    cells[row*_columns+column] = FALSE;
}
-(BOOL)hasMineAtRow:(int)row column:(int)column
{
    BOOL *cells = (BOOL *)[_mineBoardData bytes];
    return cells[row*_columns+column];
}

/**
 * lay numOfMines mines randomly
 */
- (void)layMines:(int)numOfMines
{
    _numberOfMines = numOfMines;

    for(int r=0; r<_rows; r++){
        for(int c=0; c<_columns ; c++){
            [self clearMineAtRow:r column:c];
        }
    }

    //lay numOfMines mines on rows*columns board
    int numCells = self.rows*self.columns;
    for(int i=0; i<numOfMines; i++){
        //在剩下的(numCells-i)个空白单元格中随机选择一个位置pos布雷
        int pos = arc4random_uniform(numCells-i); //pos: [0..numOfMines-i-1]
        
        int k=0;
        BOOL flag = TRUE;
        for(int r=0; r<self.rows && flag; r++){
            for(int c=0; c<self.columns && flag; c++){
                if(! [self hasMineAtRow:r column:c]){
                    if(k ==  pos){
                        [self setMineAtRow:r column:c];
                        flag = FALSE;
                    }else{
                        k++;
                    }
                }
            }
        }
    }
}

//TODO: cache these calculated numbers
-(int)numberOfMinesAroundCellAtRow:(int)row column:(int)column
{
    int count = 0;
    for(int r=row-1; r<=row+1; r++){
        for(int c=column-1; c<=column+1; c++){
            if(!(r==row && c==column) && (r>=0 && r<_rows) && (c>=0 && c<_columns)){
                if([self hasMineAtRow:r column:c]){
                    count++;
                }
            }
        }
    }
    return count;
}

@end
