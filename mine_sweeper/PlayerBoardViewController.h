//
//  MineSweeperViewController.h
//  mine_sweeper
//
//  Created by 赵小健 on 2/25/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PlayerState){
    PlayerStateInit, //initial state
    PlayerStateAlive,
    PlayerStateDead
};


@interface PlayerBoardViewController : UIViewController

@end
