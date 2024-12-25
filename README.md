# NCU_Compiler_2024

## 完成項目

- [x] Q1. Syntax Validation
- [x] Q2. Print
- [x] Q3. Numerical Operations
- [x] Q4. Logical Operations
- [x] Q5. if Expression
- [x] Q6. Variable Definition
- [x] Q7. Function
- [x] Q8. Named Function
-------------------------------
- [x] B1. Recursion
- [x] B2. Type Checking
- [x] B3. Nested Function
- [ ] B4. First-calss Function


## 程式邏輯

### 建立AST 


#### 每個node所存的結構
```
typedef struct node{
    enum nodeType type;
    int value;
    char *name;
    struct node *right;
    struct node *left;
} node;
```


1. 將每個`exp`建為一個binary tree，其parent為此`exp`的`operator`，左右子樹分別為其參數或是其他`exp`所建的tree
2. 在`print-stmt`時，才會呼叫`EvaluateTree(node* root)`去跑這個樹，並回傳結果


| node      | left  | right  |
|-----------|-----------|-----------|
|  exp  | 節點 A    | 節點 B    |
| 節點 A    | 節點 C    | 節點 D    |
| 節點 B    | 節點 E    | 節點 F    |
| 節點 C    | `null`    | `null`    |
| 節點 D    | `null`    | `null`    |

```
root
├── A
│   ├── C
│   └── D
└── B
    ├── E
    └── F
```

#### Function 結構