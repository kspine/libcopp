﻿# 默认配置选项
#####################################################################

if (CMAKE_CONFIGURATION_TYPES)
	message(STATUS "Available Build Type: ${CMAKE_CONFIGURATION_TYPES}")
else()
	message(STATUS "Available Build Type: Unknown")
endif()

if(NOT CMAKE_BUILD_TYPE)
	# set(CMAKE_BUILD_TYPE "Debug")
	set(CMAKE_BUILD_TYPE "RelWithDebInfo")
endif()

# 编译器选项 (仅做了GCC、VC和Clang兼容)
if( ${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
    add_definitions(-Wall -Werror)

    if(NOT WIN32 AND NOT CYGWIN AND NOT MINGW) 
        add_definitions(-fPIC)
    endif()

    include(CheckCCompilerFlag)
    message(STATUS "Check Flag: -rdynamic -- running")
    CHECK_C_COMPILER_FLAG(-rdynamic, C_FLAGS_RDYNAMIC_AVAILABLE)
    if(C_FLAGS_RDYNAMIC_AVAILABLE)
        message(STATUS "Check Flag: -rdynamic -- yes")
        add_definitions(-rdynamic)
    else()
        message(STATUS "Check Flag: -rdynamic -- no")
    endif()

    # gcc 4.9 编译输出颜色支持
    if ( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "4.9.0" OR CMAKE_CXX_COMPILER_VERSION  VERSION_EQUAL "4.9.0" )
        add_definitions(-fdiagnostics-color=auto)
    endif()
    # 检测GCC版本大于等于4.8时，默认-Wno-unused-local-typedefs (普片用于type_traits，故而关闭该警告)
    if ( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "4.8.0" OR CMAKE_CXX_COMPILER_VERSION  VERSION_EQUAL "4.8.0" )
        add_definitions(-Wno-unused-local-typedefs)
        message(STATUS "GCC Version ${CMAKE_CXX_COMPILER_VERSION} Found, -Wno-unused-local-typedefs added.")
    endif()

    if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "5.0.0" OR CMAKE_CXX_COMPILER_VERSION  VERSION_EQUAL "5.0.0" )
        set(CMAKE_C_STANDARD 11)
        set(CMAKE_CXX_STANDARD 14)
        message(STATUS "GCC Version ${CMAKE_CXX_COMPILER_VERSION} , using -std=c11/c++14.")
    elseif ( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "4.7.0" OR CMAKE_CXX_COMPILER_VERSION  VERSION_EQUAL "4.7.0" )
        set(CMAKE_C_STANDARD 11)
        set(CMAKE_CXX_STANDARD 11)
        message(STATUS "GCC Version ${CMAKE_CXX_COMPILER_VERSION} , using -std=c11/c++11.")
    elseif( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "4.4.0" OR CMAKE_CXX_COMPILER_VERSION  VERSION_EQUAL "4.4.0" )
        list(APPEND CMAKE_CXX_FLAGS -std=c++0x)
        message(STATUS "GCC Version ${CMAKE_CXX_COMPILER_VERSION} , using -std=c++0x.")
    endif()

    if(MINGW)
        list(APPEND COMPILER_OPTION_EXTERN_CXX_LIBS stdc++)
    endif()
elseif( ${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
    add_definitions(-Wall -Werror -fPIC)
    if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "3.4" OR CMAKE_CXX_COMPILER_VERSION  VERSION_EQUAL "3.4" )
        set(CMAKE_C_STANDARD 11)
        set(CMAKE_CXX_STANDARD 14)
        message(STATUS "Clang Version ${CMAKE_CXX_COMPILER_VERSION} , using -std=c11/c++14.")
    elseif ( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "3.3" OR CMAKE_CXX_COMPILER_VERSION  VERSION_EQUAL "3.3" )
        set(CMAKE_C_STANDARD 11)
        set(CMAKE_CXX_STANDARD 11)
        message(STATUS "Clang Version ${CMAKE_CXX_COMPILER_VERSION} , using -std=c11/c++11.")
    endif()
    # 优先使用libc++和libc++abi
    find_library (COMPILER_CLANG_HAS_LIBCXX NAMES c++ libc++)
    find_library (COMPILER_CLANG_HAS_LIBCXXABI NAMES c++abi libc++abi)
    if(COMPILER_CLANG_HAS_LIBCXX AND COMPILER_CLANG_HAS_LIBCXXABI)
        add_definitions(-stdlib=libc++)
        message(STATUS "Clang use stdlib=libc++")
        list(APPEND COMPILER_OPTION_EXTERN_CXX_LIBS c++ c++abi)
    else()
        message(STATUS "Clang use stdlib=default(libstdc++)")
        if(MINGW)
            list(APPEND COMPILER_OPTION_EXTERN_CXX_LIBS stdc++)
        endif()
    endif()

elseif( ${CMAKE_CXX_COMPILER_ID} STREQUAL "AppleClang")
    add_definitions(-Wall -Werror -fPIC)
    if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "6.0")
        set(CMAKE_C_STANDARD 11)
        set(CMAKE_CXX_STANDARD 14)
        message(STATUS "AppleClang Version ${CMAKE_CXX_COMPILER_VERSION} , using -std=c11/c++14.")
    elseif ( CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "5.0" OR CMAKE_CXX_COMPILER_VERSION  VERSION_EQUAL "5.0" )
        set(CMAKE_C_STANDARD 11)
        set(CMAKE_CXX_STANDARD 11)
        message(STATUS "Clang Version ${CMAKE_CXX_COMPILER_VERSION} , using -std=c11/c++11.")
    endif()
    # 优先使用libc++和libc++abi
    find_library (COMPILER_CLANG_HAS_LIBCXX NAMES c++ libc++)
    find_library (COMPILER_CLANG_HAS_LIBCXXABI NAMES c++abi libc++abi)
    if(COMPILER_CLANG_HAS_LIBCXX AND COMPILER_CLANG_HAS_LIBCXXABI)
        add_definitions(-stdlib=libc++)
        message(STATUS "Clang use stdlib=libc++")
    else()
        message(STATUS "Clang use stdlib=default(libstdc++)")
    endif()
endif()

# 配置公共编译选项
if ( NOT MSVC )
    list(APPEND CMAKE_CXX_FLAGS_DEBUG -ggdb -O0)
    #list(APPEND CMAKE_CXX_FLAGS_RELEASE)
    list(APPEND CMAKE_CXX_FLAGS_RELWITHDEBINFO -ggdb)
    #list(APPEND CMAKE_CXX_FLAGS_MINSIZEREL)
else()
    list(APPEND CMAKE_CXX_FLAGS_DEBUG /Od /MDd)
    list(APPEND CMAKE_CXX_FLAGS_RELEASE /O2 /MD /D NDEBUG)
    list(APPEND CMAKE_CXX_FLAGS_RELWITHDEBINFO /O2 /MDd)
    list(APPEND CMAKE_CXX_FLAGS_MINSIZEREL /Ox /MD /D NDEBUG)
endif()

# list => string
string(REPLACE ";" " " CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
string(REPLACE ";" " " CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
string(REPLACE ";" " " CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
string(REPLACE ";" " " CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL}")
string(REPLACE ";" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
string(REPLACE ";" " " CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}")
string(REPLACE ";" " " CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}")
string(REPLACE ";" " " CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO}")
string(REPLACE ";" " " CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL}")
string(REPLACE ";" " " CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")

# 库文件的附加参数 -fPIC, 多线程附加参数 -pthread -D_POSIX_MT_

# 功能函数
macro(add_compiler_define)
	foreach(def ${ARGV})
    	if ( NOT MSVC )
            add_definitions(-D${def})
        else()
            add_definitions("/D ${def}")
        endif()
	endforeach()
endmacro(add_compiler_define)
