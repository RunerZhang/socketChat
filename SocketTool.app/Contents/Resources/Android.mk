LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SHARED_LIBRARIES := stlport_shared
LOCAL_CPPFLAGS += -frtti

LOCAL_MODULE    := yhCommon
LOCAL_SRC_FILES :=  \
yhPort.cpp                                  	\
yhBuffer.cpp                                    \
yhCircularBuffer.cpp                            \
yhCommon.cpp                                    \
yhError.cpp                                     \
yhHeapMonitor.cpp                               \
yhObject.cpp                                    \
yhAutoreleasePool.cpp                           \
yhLog.cpp                                       \
yhLogWriteFileEx.cpp                            \
yhPipe.cpp                                      \
yhMath.cpp                                      \
Profiler/yhProfiler.cpp                         \
Profiler/yhJitterProfiler.cpp                   \
Network/Socket/yhAsyncSocket.cpp                \
Network/Socket/yhAsyncUdpSocket.cpp				\
Network/Http/yhHttpRequest.cpp					\
Thread/yhLock.cpp								\
Thread/yhCondition.cpp							\
Thread/yhOperation.cpp							\
Thread/yhRunLoop.cpp                            \
Thread/yhThread.cpp								\
Thread/yhThreadPool.cpp							\
Thread/yhTimer.cpp								\
Thread/yhTimerScheduler.cpp						\
Utility/yhDeviceUtility.cpp						\
Utility/yhFileUtility.cpp						\
Utility/yhNetworkUtility.cpp                    \
Utility/yhTimeUtility.cpp						\
Utility/yhCompressUtility.cpp                   \
Utility/yhCryptorUtility.cpp                    \
Utility/yhDatabaseUtility.cpp                   \
Utility/zlib/adler32.c                          \
Utility/zlib/compress.c                         \
Utility/zlib/crc32.c                            \
Utility/zlib/deflate.c                          \
Utility/zlib/gzclose.c                          \
Utility/zlib/gzlib.c                            \
Utility/zlib/gzread.c                           \
Utility/zlib/gzwrite.c                          \
Utility/zlib/infback.c                          \
Utility/zlib/inffast.c                          \
Utility/zlib/inflate.c                          \
Utility/zlib/inftrees.c                         \
Utility/zlib/trees.c                            \
Utility/zlib/uncompr.c                          \
Utility/zlib/zutil.c                            \
Utility/md5/md5.cpp                             \
Utility/sqlite3/sqlite3.c                		\
Platform/yhPlatform_Android.cpp            		\

LOCAL_LDLIBS += -llog

LOCAL_C_INCLUDES :=	\
	$(LOCAL_PATH)                               \
    $(LOCAL_PATH)/Common/Network/Socket         \
 	$(LOCAL_PATH)/Common/Thread                 \
 	$(LOCAL_PATH)/Common/Utility                \
    $(LOCAL_PATH)/Common/Utility/zlib           \
    $(LOCAL_PATH)/Common/Utility/md5            \
    $(LOCAL_PATH)/Common/Utility/sqlite3        \
    $(LOCAL_PATH)/Common/Platform              	\

include $(BUILD_SHARED_LIBRARY)
