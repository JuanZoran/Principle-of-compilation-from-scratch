#pragma once
#include <iostream>

namespace Zoran {

constexpr auto End  = "\033[0m";
constexpr auto Endl = "\033[0m\n";
/// @brief ASCII 颜色输出
constexpr auto Red    = "\033[31m";
constexpr auto Green  = "\033[1;32m";
constexpr auto Yellow = "\033[33m";
constexpr auto Blue   = "\033[34m";
constexpr auto Purpor = "\033[35m";
constexpr auto Dgreen = "\033[36m";
constexpr auto White  = "\033[37m";

/// @brief attribute
constexpr auto HighLight = "\033[1m";  // 高亮
constexpr auto HalfLight = "\033[2m";  // 亮度减半
constexpr auto Italic    = "\033[3m";  // 斜体
constexpr auto UnderLine = "\033[4m";  // 下划线
constexpr auto Twinkle   = "\033[5m";  // 闪烁
constexpr auto Flash     = "\033[6m";  // 快闪

/// @brief background
constexpr auto BLACK   = "\033[40m";  // 黑色
constexpr auto RED     = "\033[41m";  // 红色
constexpr auto GREEN   = "\033[42m";  // 绿色
constexpr auto BROWN   = "\033[43m";  // 棕色
constexpr auto BLUE    = "\033[44m";  // 蓝色
constexpr auto SKYBLUE = "\033[46m";  // 孔雀蓝
constexpr auto WHITE   = "\033[47m";  // 白色

static auto line = []( auto obj, std::string color = Zoran::Dgreen ) { std::cout << color << obj << Zoran::Endl; };

#define STR( n ) #n

// 向上移动 n
#define UP( n ) STR(\033[\
n##A)

// 向下移动n
#define DOWN( n ) STR(\033[\
n##B)

// 向右移动n
#define RIGHT( n ) STR(\033[\
n##C)

// 向左移动n
#define LEFT( n ) STR(\033[\
n##D)

// 设定光标的位置
#define SET( y, x ) STR(\x1b[\
y;x##H)

constexpr auto Save    = "\033[s";     // 保存当前光标位置
constexpr auto Recover = "\033[u";     // 恢复之前保存的位置
constexpr auto Hide    = "\033[?25l";  // 隐藏光标
constexpr auto Show    = "\033[?25h";  // 显示光标

}  // namespace Zoran
