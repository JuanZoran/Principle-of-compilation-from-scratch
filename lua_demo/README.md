# a|b
- 正则表达式

a|b

- 后缀表达式

ab|

- 构建得到NFA

```dot
// Start State: 5
// Final State: 6
digraph {
rankdir = LR
5 [color=green]
6 [peripheries=2]
1 -> 2 [label="a"]
3 -> 4 [label="b"]
2 -> 6 [style=dotted, label="ε"]
4 -> 6 [style=dotted, label="ε"]
5 -> 3 [style=dotted, label="ε"]
5 -> 1 [style=dotted, label="ε"]
}
```

- 构建得到DFA :
```dot
digraph {
rankdir = LR
2 [peripheries=2]
3 [peripheries=2]
1 -> 2 [label="a"]
1 -> 3 [label="b"]
}
```
# a*
- 正则表达式

a*

- 后缀表达式

a*

- 构建得到NFA

```dot
// Start State: 3
// Final State: 4
digraph {
rankdir = LR
3 [color=green]
4 [peripheries=2]
1 -> 2 [label="a"]
2 -> 4 [style=dotted, label="ε"]
2 -> 1 [style=dotted, label="ε"]
3 -> 1 [style=dotted, label="ε"]
3 -> 4 [style=dotted, label="ε"]
}
```

- 构建得到DFA :
```dot
digraph {
rankdir = LR
1 [peripheries=2]
2 [peripheries=2]
1 -> 2 [label="a"]
2 -> 2 [label="a"]
}
```
# ab
- 正则表达式

ab

- 后缀表达式

ab^

- 构建得到NFA

```dot
// Start State: 1
// Final State: 4
digraph {
rankdir = LR
1 [color=green]
4 [peripheries=2]
1 -> 2 [label="a"]
3 -> 4 [label="b"]
2 -> 3 [style=dotted, label="ε"]
}
```

- 构建得到DFA :
```dot
digraph {
rankdir = LR
3 [peripheries=2]
1 -> 2 [label="a"]
2 -> 3 [label="b"]
}
```
# (a|b)c
- 正则表达式

(a|b)c

- 后缀表达式

ab|c^

- 构建得到NFA

```dot
// Start State: 5
// Final State: 8
digraph {
rankdir = LR
5 [color=green]
8 [peripheries=2]
1 -> 2 [label="a"]
3 -> 4 [label="b"]
7 -> 8 [label="c"]
2 -> 6 [style=dotted, label="ε"]
4 -> 6 [style=dotted, label="ε"]
5 -> 3 [style=dotted, label="ε"]
5 -> 1 [style=dotted, label="ε"]
6 -> 7 [style=dotted, label="ε"]
}
```

- 构建得到DFA :
```dot
digraph {
rankdir = LR
4 [peripheries=2]
1 -> 2 [label="b"]
1 -> 3 [label="a"]
2 -> 4 [label="c"]
3 -> 4 [label="c"]
}
```
# (a|b)*c
- 正则表达式

(a|b)*c

- 后缀表达式

ab|*c^

- 构建得到NFA

```dot
// Start State: 7
// Final State: 10
digraph {
rankdir = LR
7 [color=green]
10 [peripheries=2]
1 -> 2 [label="a"]
3 -> 4 [label="b"]
9 -> 10 [label="c"]
2 -> 6 [style=dotted, label="ε"]
4 -> 6 [style=dotted, label="ε"]
5 -> 3 [style=dotted, label="ε"]
5 -> 1 [style=dotted, label="ε"]
6 -> 8 [style=dotted, label="ε"]
6 -> 5 [style=dotted, label="ε"]
7 -> 5 [style=dotted, label="ε"]
7 -> 8 [style=dotted, label="ε"]
8 -> 9 [style=dotted, label="ε"]
}
```

- 构建得到DFA :
```dot
digraph {
rankdir = LR
}
```
