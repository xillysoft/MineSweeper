//
//  PlayerBoardView.h
//  mine_sweeper
//
//  Created by 赵小健 on 2/25/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerBoard.h"

@interface PlayerBoardView : UIView

//TODO: 修改为delegate模式
@property(weak) PlayerBoard *playerBoard;

@end
