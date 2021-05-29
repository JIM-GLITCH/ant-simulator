
原作者链接https://github.com/piXelicidio/locas-ants

> # locas-ants
>
> Is a modern Lua remake of my old [Ant colony](https://www.youtube.com/watch?v=G5wb4f5n6qQ) simulation.
>
> This is not a translation, is a remake from scratch using opensource engine Löve2D with friendly and popular Lua language.
>
> Last screenshots:
>
> ![](https://raw.githubusercontent.com/piXelicidio/locas-ants/develop/screenshots/nicePath.gif)
>
> (Btw, I'm learning Git/Github so beware of weird things with this my first Open Source"?" project) 
>
> **To quick run it:**
>
> - Install Love2D: https://love2d.org/ 
> - Download the .love file: https://github.com/piXelicidio/locas-ants/releases/latest
> - Double-click .love file.
>
> **To play with the source project:** 
>
> - Download or clone.
> - install love2d: https://love2d.org/
> - install ZeroBrane Studio: https://studio.zerobrane.com/download?not-this-time 
> - Open the Main.Lua with ZeroBrane.
> - On ZeroBrane go to menu : Project -> Lua Interpreter -> LÖVE.
> - And execute with F6 :) ready!
> - [Discussion forum](https://talk.denysalmaral.com/index.php?p=/categories/locas-ants-%28lua-%2B-love2d%29)

修改：

1. 修复了 pan view 同时会remove的bug。并能监控环境中食物数量，探索地图的比例等信息，打印在屏幕上。
2. 添加了pause, stop, change map按钮.
3. 写了一个新算法 algorithm_communication，用蚂蚁之间的通信代替信息素。
4. 在main.lua里添加了处理命令行参数的代码，写了几个实验自动化的py脚本。
