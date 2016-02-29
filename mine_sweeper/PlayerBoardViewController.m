//
//  MineSweeperViewController.m
//  mine_sweeper
//
//  Created by 赵小健 on 2/25/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import "PlayerBoardViewController.h"
#import "MineBoard.h"
#import "PlayerBoard.h"

@interface PlayerBoardViewController()

@end


/*
 * 初级：9x9, 10 mines
 * 中级：16x16, 40 mines
 * 高级：30x16, 99 mines
 */
@implementation PlayerBoardViewController

-(void)loadView
{
    self.playerBoardView = [[PlayerBoardView alloc] init];
    self.view = self.playerBoardView;
    self.view.backgroundColor = [UIColor whiteColor];
    
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
        numberOfMines = 40;
    }else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){//iPhone, iPod Touch
        rows = 9;
        columns = 9;
        numberOfMines = 10;
    }
    MineBoard *mineBoard = [[MineBoard alloc] initWithRows:rows columns:columns];
    self.playerBoard = [[PlayerBoard alloc] initWithMineBoard:mineBoard];

    //TODO: 修改为delegate pattern，由view通过delegate查询data model
    self.playerBoardView.playerBoard = self.playerBoard;

    //defer lay mines until first user-tap action!
    /* [self.mineBoard layMines:numberOfMines]; */

}

@end
