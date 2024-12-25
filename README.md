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

## 編譯

### 環境
`Windows`

### 使用`.bat`編譯yacc和lex檔
```
.\run.bat smli
```
會得到 `smli.exe`

### 讀取檔案
```
.\smli.exe file.lsp
```



## 程式大綱

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

#### var(變數)的結構
```
enum varType {
    var_n, var_b
};

typedef struct{
    enum varType type;
    int value;
    char *name;
    node *func;
}var;
```

1. 將每個`exp`建為一個binary tree，其parent為此`exp`的`operator`，左右子樹分別為其參數或是其他`exp`所建的tree
2. 在`print-stmt`時，才會呼叫`EvaluateTree(node* root)`去跑這個樹，並回傳結果


### Fuction

#### Function 結構

| node      | left  | right  |
|-----------|-----------|-----------|
|  func  | variable    | func_body    |
| variable(func的參數名稱)    | variable    | `null`    |
| func_body    | define    | exp    |
| define(在func裡定義的變數)    | define    | `null`    |
| func_call(呼叫func)    | param    | func    |
| param(func參數)    | param    | `null`    |

#### Function call 執行順序
1. 先判斷是否為Named function
2. 用 `cal_param` 計算parameter的值
3. 將參數名稱填入 `local_vars` 中
4. 使用`set_param` 設置parameter到對應的參數名稱
5. `EvaluateTree(func_body)` 遍歷這個function