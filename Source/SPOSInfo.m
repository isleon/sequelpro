//
//  SPOSInfo.m
//  sequel-pro
//
//  Created by Max Lohrmann on 14.02.15.
//  Copyright (c) 2015 Max Lohrmann. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//
//  More info at <https://github.com/sequelpro/sequelpro>

#import "SPOSInfo.h"

// Needed because this class is also compiled with SequelProTunnelAssistant which can't access SPConstants.h
#ifndef __MAC_10_10
#define __MAC_10_10 101000
#endif

#if __MAC_OS_X_VERSION_MAX_ALLOWED < __MAC_10_10
// This code is available since 10.8 but public only since 10.10
typedef struct {
	NSInteger majorVersion;
	NSInteger minorVersion;
	NSInteger patchVersion;
} NSOperatingSystemVersion;

@interface NSProcessInfo ()
- (NSOperatingSystemVersion)operatingSystemVersion;
- (BOOL)isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion)version;
@end

#endif

int SPOSVersionCompare(SPOSVersion left, SPOSVersion right)
{
	if(left.major != right.major) return (left.major < right.major)? -1 : 1;
	if(left.minor != right.minor) return (left.minor < right.minor)? -1 : 1;
	if(left.patch != right.patch) return (left.patch < right.patch)? -1 : 1;
	return 0;
}

@implementation SPOSInfo

+ (SPOSVersion)osVersion
{
	NSProcessInfo *procInfo = [NSProcessInfo processInfo];
	if([procInfo respondsToSelector:@selector(operatingSystemVersion)]) {
		NSOperatingSystemVersion nsVer = [procInfo operatingSystemVersion];
		//structs cannot be casted per C standard
		SPOSVersion spVer = {nsVer.majorVersion,nsVer.minorVersion,nsVer.patchVersion};
		return spVer;
	}
	else {
		SInt32 versionMajor = 0;
		SInt32 versionMinor = 0;
		SInt32 versionPatch = 0;
		Gestalt(gestaltSystemVersionMajor, &versionMajor);
		Gestalt(gestaltSystemVersionMinor, &versionMinor);
		Gestalt(gestaltSystemVersionBugFix, &versionPatch);
		
		SPOSVersion spVer = {versionMajor,versionMinor,versionPatch};
		return spVer;
	}
}

+ (BOOL)isOSVersionAtLeastMajor:(NSInteger)major minor:(NSInteger)minor patch:(NSInteger)patch
{
	NSProcessInfo *procInfo = [NSProcessInfo processInfo];
	if([procInfo respondsToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
		NSOperatingSystemVersion nsVer = {major,minor,patch};
		return [procInfo isOperatingSystemAtLeastVersion:nsVer];
	}
	else {
		SPOSVersion runningVersion   = [self osVersion];
		SPOSVersion referenceVersion = {major, minor, patch};
		return (SPOSVersionCompare(runningVersion, referenceVersion) >= 0);
	}
}

@end
