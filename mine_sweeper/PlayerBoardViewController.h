//
//  MineSweeperViewController.h
//  mine_sweeper
//
//  Created by 赵小健 on 2/25/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerBoard.h"
#import "MineBoard.h"
#import "PlayerBoardView.h"

typedef NS_ENUM(NSInteger, PlayerState){
    PlayerStateInit, //initial state
    PlayerStateAlive,
    PlayerStateDead
};


@interface PlayerBoardViewController : UIViewController

//player state
@property PlayerState playerState;

//player board object
@property PlayerBoard *playerBoard;

//plaeyr board view object
@property PlayerBoardView *playerBoardView;

@end
