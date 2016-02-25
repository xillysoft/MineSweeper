//
//  MineSweeperViewController.m
//  mine_sweeper
//
//  Created by 赵小健 on 2/25/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import "MineSweeperViewController.h"
#import "MineBoard.h"
#import "PlayerBoard.h"

@interface MineSweeperViewController()

@property(nonatomic) MineBoard *mineBoard;
@property(nonatomic) PlayerBoard *playerBoard;

@end


@implementation MineSweeperViewController

-(MineBoard *)mineBoard
{
    return self.mineBoard;
}

-(PlayerBoard *)playerBoard
{
    return self.playerBoard;
}

- (instancetype)init
{
    self = [super init];
    if(self){
        int rows = 16;
        int columns = 16;
        int numberOfMines = 40;
        self.mineBoard = [[MineBoard alloc] initWithRows:rows columns:columns];
        [self.mineBoard layMines:numberOfMines];
        
        self.playerBoard = [[PlayerBoard alloc] initWithMineBoard:self.mineBoard];
    }
    return self;
}

@end
