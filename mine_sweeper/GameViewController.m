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

@interface GameViewController(){
    int _numberOfMinesLaied;
    int _numberOfMinesUncovered;
    int _numberOfMinesMarkedAsMine;
}

@property(readwrite) int numberOfMinesToLayOnMineBoard; //re-define as read-write

@end


/**
 * 初级：9x9, 10 mines
 * 中级：16x16, 40 mines
 * 高级：30x16, 99 mines
 */
@implementation GameViewController

-(void)checkIfWin
{
    //test whether all mines swept
    int numberOfMinesCorvered = self.playerBoard.rows*self.playerBoard.columns-_numberOfMinesUncovered;
    if(numberOfMinesCorvered==_numberOfMinesLaied
       && _numberOfMinesMarkedAsMine==_numberOfMinesLaied){
        [self playerDidWin];
    }
}

#pragma mark IPlayerBoardDelegate
//mineboard上已布雷
-(void)minesLaidOnMineBoard:(int)numberOfMinesLaid
{
    [self.playerBoardView minesLaidOnMineBoard:numberOfMinesLaid];
    _numberOfMinesLaied = numberOfMinesLaid;
}

//单元格标记改变
-(void)cellMarkChangedFrom:(CellState)oldState to:(CellState)newState atRow:(int)row column:(int)column;
{
    [self.playerBoardView cellMarkChangedFrom:oldState to:newState atRow:row column:column];
    
    if(oldState==CellStateCoveredMarkedAsMine){
        _numberOfMinesMarkedAsMine--;
    }
    if(newState==CellStateCoveredMarkedAsMine){
        _numberOfMinesMarkedAsMine++;
    }
    
    [self checkIfWin];
}

//打开了一个无雷的单元格
-(void)cellDidUncoverAtRow:(int)row column:(int)column
{
    [self.playerBoardView cellDidUncoverAtRow:row column:column];
    
    _numberOfMinesUncovered++;
    [self checkIfWin];
}

//打开了一个有雷的单元格
-(void)mineDidExplodeAtRow:(int)row column:(int)column
{
    [self.playerBoardView mineDidExplodeAtRow:row column:column];
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
    
    int rows = 0;
    int columns = 0;
    int numberOfMines = 0;
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
    self.playerBoardView.listener = self;

    //defer lay mines until first user-tap action!
//     [self.playerBoard.mineBoard layMines:numberOfMines];
    
    //用于测试胜利条件
    _numberOfMinesMarkedAsMine = 0;
    _numberOfMinesUncovered = 0;

//    self.preferredFramesPerSecond = 30;
}


-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
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
-(void)player:(PlayerBoardView *)player didSingleTapOnCell:(CellLocation *)location
{
    int row = location.row;
    int column = location.column;

    [self ensureMinesLaiedOnMineBoard:row column:column];
    
    [self.playerBoard tryUncoverCellAtRow:row column:column recursive:YES];

}

#pragma mark - PlayerBoardView delegate method
-(void)player:(PlayerBoardView *)player didDoubleTapOnCell:(CellLocation *)location
{
    {
        int row = location.row;
        int column = location.column;
        CellState state = [self.playerBoard cellStateAtRow:row column:column];
        switch(state){
            case CellStateCoveredNoMark:{ //Covered==>MarkedAsMine
                [self.playerBoard setCellMarkFrom:CellStateCoveredNoMark toNewMark:CellStateCoveredMarkedAsMine atRow:row column:column];
//                [playerBoardView cellMarkChangedFrom:CellStateCoveredNoMark to:CellStateCoveredMarkedAsMine];
            }
                break;
                
            case CellStateCoveredMarkedAsMine:{ //MarkedAsMine==>CoveredNoMark
                [self.playerBoard setCellMarkFrom:CellStateCoveredMarkedAsMine toNewMark:CellStateCoveredNoMark atRow:row column:column];
//                [playerBoardView cellMarkChangedFrom:CellStateCoveredMarkedAsMine to:CellStateCoveredNoMark];
            }
                break;
                
            case CellStateCoveredMarkedAsUncertain:{ //Uncertain==>CoveredNoMark
                [self.playerBoard setCellMarkFrom:CellStateCoveredMarkedAsUncertain toNewMark:CellStateCoveredNoMark atRow:row column:column];
//                [playerBoardView cellMarkChangedFrom:CellStateCoveredMarkedAsUncertain to:CellStateCoveredNoMark];
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
        [self.playerBoard setCellMarkFrom:CellStateCoveredNoMark toNewMark:CellStateCoveredMarkedAsUncertain atRow:row column:column];
//        [self.playerBoardView cellMarkChangedFrom:CellStateCoveredNoMark to:CellStateCoveredMarkedAsUncertain];
    }else if (state == CellStateCoveredMarkedAsUncertain){ //Uncertain==>Covered
        [self.playerBoard setCellMarkFrom:CellStateCoveredMarkedAsUncertain toNewMark:CellStateCoveredNoMark atRow:row column:column];
//        [self.playerBoardView cellMarkChangedFrom:CellStateCoveredMarkedAsUncertain to:CellStateCoveredNoMark];
    }
}

-(void)playerDidDie
{
    NSLog(@"--GameViewController::Player Dead!");
    
//    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); //vibrate the phone

    //start new game
    GameViewController *viewController = [[GameViewController alloc] init];
    [self showViewController:viewController sender:self];
}

-(void)playerDidWin
{
    NSLog(@"--GameViewController::Player Win!");
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); //vibrate the phone

    //start new game
    GameViewController *viewController = [[GameViewController alloc] init];
    [self showViewController:viewController sender:self];
}

@end
