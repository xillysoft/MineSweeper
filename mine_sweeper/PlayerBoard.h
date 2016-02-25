//
//  PlayerBoard.h
//  mine_sweeper
//
//  Created by 赵小健 on 2/25/16.
//  Copyright © 2016 赵小健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MineBoard.h"

typedef NS_ENUM(NSInteger, CellState){
    CellStateCovered, //覆盖，不可见
    CellStateUncovered, //点击开，无雷;对于无雷的单元个，在其上显示周围雷数目
    CellStateMarkedAsMine //标记为雷
};


@interface PlayerBoard : NSObject

-(instancetype)initWithMineBoard:(MineBoard *)mineBoard;
@property(readonly) MineBoard *mineBoard;
- (CellState)cellStateAtRow:(int)row column:(int)column;
- (void)setCellState:(CellState)state AtRow:(int)row column:(int)column;


- (void)checkCellStateAtRow:(int)row column:(int)column;
@end

