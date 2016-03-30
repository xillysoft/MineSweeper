//
//  MineSweeperViewController.m
//  mine_sweeper
//
//  Created by 赵小健 on 2/25/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

@import AudioToolbox;
#import "GameViewController.h"
#import "MineBoard.h"
#import "PlayerBoard.h"
#import "PlayerBoardView.h"
#import "CellLocation.h"

@interface GameViewController()

@property(readwrite) int numberOfMinesToLayOnMineBoard; //re-define as read-write

@end


/**
 * 初级：9x9, 10 mines
 * 中级：16x16, 40 mines
 * 高级：30x16, 99 mines
 */
@implementation GameViewController


#pragma mark IPlayerBoardDelegate
//mineboard上已布雷
-(void)minesLaidOnMineBoard:(int)numberOfMinesLaid
{
    [self.playerBoardView minesLaidOnMineBoard:numberOfMinesLaid];
}

//单元格标记改变
-(void)cellMarkChangedFrom:(CellState)oldState to:(CellState)newState
{
    [self.playerBoardView cellMarkChangedFrom:oldState to:newState];
}

//打开了一个无雷的单元格
-(void)cellDidUncoverAtRow:(int)row column:(int)column
{
    [self.playerBoardView cellDidUncoverAtRow:row column:column];
}

//打开了一个有雷的单元格
-(void)mineDidExplodAtRow:(int)row column:(int)column
{
    [self.playerBoardView mineDidExplodAtRow:row column:column];
    self.playerState = PlayerStateDead;
    [self playerDidDie];
}
#pragma mark -

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
//    MineBoard *mineBoard = [[MineBoard alloc] initWithRows:rows columns:columns];
//    self.playerBoard = [[PlayerBoard alloc] initWithMineBoard:mineBoard];
    self.playerBoard = [[PlayerBoard alloc] initWithRows:rows columns:columns];
    self.playerBoard.delegate = self; //接收PlayerBoard事件

    //TODO: 修改为delegate pattern，由view通过delegate查询data model
    self.playerBoardView.playerBoard = self.playerBoard;
    self.numberOfMinesToLayOnMineBoard = numberOfMines;
    self.playerBoardView.delegate = self;

    //defer lay mines until first user-tap action!
//     [self.playerBoard.mineBoard layMines:numberOfMines];

}

-(BOOL)ensureMinesLaiedOnMineBoard:(int)row column:(int)column
{
    //Lay mines on mineBoard id not laied yet
    PlayerBoard *playerBoard = self.playerBoard;

    if([playerBoard numberOfMinesLaid] == 0){
        [playerBoard layMines:self.numberOfMinesToLayOnMineBoard ensureNoMineAtRow:row column:column];
    }
    return YES;
}

#pragma mark - PlayerBoardView delegate method
-(void)player:(PlayerBoardView *)playerBoardView didSingleTapOnCell:(CellLocation *)location
{
    int row = location.row;
    int column = location.column;

    [self ensureMinesLaiedOnMineBoard:row column:column];
    
    [self.playerBoard tryUncoverCellAtRow:row column:column recursive:NO];

}

#pragma mark - PlayerBoardView delegate method
-(void)player:(PlayerBoardView *)playerBoardView didDoubleTapOnCell:(CellLocation *)location
{
    {
        int row = location.row;
        int column = location.column;
        CellState state = [self.playerBoard cellStateAtRow:row column:column];
        switch(state){
            case CellStateCoveredNoMark:{ //Covered==>MarkedAsMine
                [self.playerBoard setCellMarkFrom:CellStateCoveredNoMark toNewMark:CellStateCoveredMarkedAsMine atRow:row column:column];
                [playerBoardView cellMarkChangedFrom:CellStateCoveredNoMark to:CellStateCoveredMarkedAsMine];
            }
                break;
                
            case CellStateCoveredMarkedAsMine:{ //MarkedAsMine==>CoveredNoMark
                [self.playerBoard setCellMarkFrom:CellStateCoveredMarkedAsMine toNewMark:CellStateCoveredNoMark atRow:row column:column];
                [playerBoardView cellMarkChangedFrom:CellStateCoveredMarkedAsMine to:CellStateCoveredNoMark];
            }
                break;
                
            case CellStateCoveredMarkedAsUncertain:{ //Uncertain==>CoveredNoMark
                [self.playerBoard setCellMarkFrom:CellStateCoveredMarkedAsUncertain toNewMark:CellStateCoveredNoMark atRow:row column:column];
                [playerBoardView cellMarkChangedFrom:CellStateCoveredMarkedAsUncertain to:CellStateCoveredNoMark];
            }
                break;
                
            case CellStateUncovered:{ //Uncovered, double click to uncover cells around if available
                    [self.playerBoard uncoverAllNotMarkedAsMineCellsAround:row column:column];
                }
                break;
        }
    }
}

#pragma mark - PlayerBoardView delegate method
-(void)player:(PlayerBoardView *)playerBoardView didLongPressOnCell:(CellLocation *)location
{
    int row = location.row;
    int column = location.column;
    CellState state = [self.playerBoard cellStateAtRow:row column:column];
    if(state == CellStateCoveredNoMark){ //Covered==>Uncertain
        [self.playerBoard setCellMark:CellStateCoveredMarkedAsUncertain atRow:row column:column];
        [self.playerBoardView cellMarkChangedFrom:CellStateCoveredNoMark to:CellStateCoveredMarkedAsUncertain];
    }else if (state == CellStateCoveredMarkedAsUncertain){ //Uncertain==>Covered
        [self.playerBoard setCellMark:CellStateCoveredNoMark atRow:row column:column];
        [self.playerBoardView cellMarkChangedFrom:CellStateCoveredMarkedAsUncertain to:CellStateCoveredNoMark];
    }
}

-(void)playerDidDie
{
    NSLog(@"--Player Dead!");
    
//    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); //vibrate the phone

}


@end
