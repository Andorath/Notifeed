//
//  UIAppearance+Swift.h
//  Notifeed
//
//  Created by Marco Salafia on 08/06/15.
//  Copyright (c) 2015 Marco Salafia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIBarItem (UIViewAppearance_Swift)
// appearanceWhenContainedIn: is not available in Swift. This fixes that.
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end
