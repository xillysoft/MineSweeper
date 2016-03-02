//
//  MineSweeperViewController.m
//  mine_sweeper
//
//  Created by 赵小健 on 2/25/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

@import AudioToolbox;
#import "PlayerBoardViewController.h"
#import "MineBoard.h"
#import "PlayerBoard.h"
#import "PlayerBoardView.h"
#import "CellLocation.h"

@interface PlayerBoardViewController()
@property(readwrite) int numberOfMinesToLayOnMineBoard; //re-define as read-write
@end


/**
 * 初级：9x9, 10 mines
 * 中级：16x16, 40 mines
 * 高级：30x16, 99 mines
 */
@implementation PlayerBoardViewController

-(void)loadView
{
    self.playerBoardView = [[PlayerBoardView alloc] init];
    self.view = self.playerBoardView;
    self.view.backgroundColor = [UIColor darkGrayColor];
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playerState = PlayerStateInit;
    
    int rows;
    int columns;
    int numberOfMines;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){ //iPad
        rows = 16;
        columns = 16;
        numberOfMines = 60;
    }else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){//iPhone, iPod Touch
        rows = 9;
        columns = 9;
        numberOfMines = 20;
    }
    MineBoard *mineBoard = [[MineBoard alloc] initWithRows:rows columns:columns];
    self.playerBoard = [[PlayerBoard alloc] initWithMineBoard:mineBoard];

    //TODO: 修改为delegate pattern，由view通过delegate查询data model
    self.playerBoardView.playerBoard = self.playerBoard;
    self.numberOfMinesToLayOnMineBoard = numberOfMines;
    self.playerBoardView.delegate = self;

    //defer lay mines until first user-tap action!
//     [self.playerBoard.mineBoard layMines:numberOfMines];

}


#pragma mark - PlayerBoardView delegate method
-(void)playerBoardView:(PlayerBoardView *)playerBoardView didSingleTapOnCell:(CellLocation *)location
{
    int row = location.row;
    int column = location.column;

    MineBoard *mineBoard = self.playerBoard.mineBoard;
    
    if([mineBoard numberOfMines] == 0){ //mines not laid yet, lay mines now.
        BOOL minesLaid = NO;
        while(! minesLaid){
            [mineBoard layMines:self.numberOfMinesToLayOnMineBoard];
            //satisfied condition: !hasMine && numberOfMinesAround==0
            if(! [mineBoard hasMineAtRow:row column:column]){
                if(! [mineBoard hasMineAroundCellAtRow:row column:column]){
                    minesLaid = YES;
                }
            }
        };
    }
    
    CellState cellState = [self.playerBoard cellStateAtRow:row column:column];
    if(cellState == CellStateCovered){ //Cell is covered
        BOOL hasMine = [self.playerBoard.mineBoard hasMineAtRow:row column:column];
        if(hasMine){ //there is a mine at checked position
            [self.playerBoard setCellState:CellStateUncovered AtRow:row column:column];
            [self playerDidDie];
            //TODO: player state==>dead
            
        }else{ //there isn't a mine at checked position cell[row][column]
            //precondition: cell[row][column]: (1)CellStateCovered (2)!hasMine
            [self.playerBoard uncoverCellAtRow:row column:column];
        }
    }

    
    [playerBoardView setNeedsDisplay]; //change to as [self.delegate reloadData];
}

//--delegate
-(void)playerBoardView:(PlayerBoardView *)playerBoardView didDoubleTapOnCell:(CellLocation *)location
{
    {
        int row = location.row;
        int column = location.column;
        CellState state = [self.playerBoard cellStateAtRow:row column:column];
        switch(state){
            case CellStateCovered:{ //Covered==>MarkedAsMine
                [self.playerBoard setCellState:CellStateMarkedAsMine AtRow:row column:column];
                [playerBoardView setNeedsDisplay];
            }
                break;
                
            case CellStateMarkedAsMine:{ //MarkedAsMine==>Covered
                [self.playerBoard setCellState:CellStateCovered AtRow:row column:column];
                [playerBoardView setNeedsDisplay];
            }
                break;
                
            case CellStateMarkedAsUncertain:{ //Uncertain==>Covered
                [self.playerBoard setCellState:CellStateCovered AtRow:row column:column];
                [playerBoardView setNeedsDisplay];
            }
                break;
                
            case CellStateUncovered:{ //Uncovered, uncover cells around if available
                    BOOL success = [self.playerBoard uncoverAllNotMarkedAsMineCellsAround:row column:column];
                    if(! success){
                        self.playerState = PlayerStateDead;
                        [self playerDidDie];
                    }
                [self.playerBoardView setNeedsDisplay];
                }
                break;
        }
    }
}

//--delegate
-(void)playerBoardView:(PlayerBoardView *)playerBoardView didLongPressOnCell:(CellLocation *)location
{
    int row = location.row;
    int column = location.column;
    CellState state = [self.playerBoard cellStateAtRow:row column:column];
    if(state == CellStateCovered){ //Covered==>Uncertain
        [self.playerBoard setCellState:CellStateMarkedAsUncertain AtRow:row column:column];
        [self.playerBoardView setNeedsDisplay];
    }else if (state == CellStateMarkedAsUncertain){ //Uncertain==>Covered
        [self.playerBoard setCellState:CellStateCovered AtRow:row column:column];
        [self.playerBoardView setNeedsDisplay];
    }
}

-(void)playerDidDie
{
    NSLog(@"--Player Dead!");
    
//    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); //vibrate the phone

}


@end
