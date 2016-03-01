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
#import "CellLocation.h"

typedef NS_ENUM(NSInteger, PlayerState){
    PlayerStateInit, //initial state
    PlayerStateAlive,
    PlayerStateDead
};

/**
 * PlayerBoardViewController view controller owns the PlayBaord data model and PlayerBoardView view.
 */
@interface PlayerBoardViewController : UIViewController <PlayerBoardViewDelegate>

//player state
@property PlayerState playerState;

//player board object
@property(strong) PlayerBoard *playerBoard;

//plaeyr board view object
@property(strong) PlayerBoardView *playerBoardView;

//delegate method for PlayerBoardView object to call
-(void)playerBoardView:(PlayerBoardView *)playerBoardView didSingleTapOnCell:(CellLocation *)location;
//delegate method for PlayerBoardView object to call
-(void)playerBoardView:(PlayerBoardView *)playerBoardView didDoubleTapOnCell:(CellLocation *)location;

@end
