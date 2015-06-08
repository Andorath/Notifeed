//
//  UIAppearance+Swift.m
//  Notifeed
//
//  Created by Marco Salafia on 08/06/15.
//  Copyright (c) 2015 Marco Salafia. All rights reserved.
//

#import "UIAppearance+Swift.h"

@implementation UIBarItem (UIViewAppearance_Swift)
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedIn:containerClass, nil];
}
@end
