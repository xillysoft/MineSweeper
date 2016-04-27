//
//  MineSweeperViewController.h
//  mine_sweeper
//
//  Created by 赵小健 on 2/25/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "PlayerBoard.h"
#import "MineBoard.h"
#import "PlayerBoardView.h"
#import "CellLocation.h"

typedef NS_ENUM(NSInteger, PlayerState){
    PlayerStateInit, //initial state, no first tap yet
    PlayerStateAlive,
    PlayerStateDead
};

/**
 * PlayerBoardViewController view controller owns the PlayBaord data model and PlayerBoardView view.
 */
@interface GameViewController : UIViewController <IPlayerBoardDelegate, IPlayerBoardViewDelegate>

//player state
@property PlayerState playerState;

//player board object
@property(strong) PlayerBoard *playerBoard;
@property(readonly) int numberOfMinesToLayOnMineBoard;

//plaeyr board view object
@property(strong) PlayerBoardView *playerBoardView;

@end
