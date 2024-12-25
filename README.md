# NCU_Compiler_2024

## 完成項目


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
3. 