//
//  WTProtoLogging.h
//  WTProtocalKit
//
//  Created by Vilson on 2019/11/22.
//  Copyright © 2019 Vilson. All rights reserved.
//

#ifndef WTLogging_H
#define WTLogging_H

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

bool WTLogEnabled();
void WTLog(NSString *format, ...);
void WTLogSetLoggingFunction(void (*function)(NSString *, va_list args));
void WTLogSetEnabled(bool);

#ifdef __cplusplus
}
#endif

#endif
