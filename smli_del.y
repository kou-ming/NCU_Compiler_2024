%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


void yyerror(const char *s);
extern int yylex();
extern int yyparse();
extern FILE *yyin;

enum nodeType {
    plus_op, minus_op, mul_op, div_op, mod_op,
    and_op, or_op, not_op,
    greater_op, smaller_op, equal_op, sec_equal_op,
    num, bool, variable,
    func, func_call, func_body, param,
    if_, define, nullnode
};

const char* nodeTypeNames[] = {
    "plus_op", "minus_op", "mul_op", "div_op", "mod_op",
    "and_op", "or_op", "not_op",
    "greater_op", "smaller_op", "equal_op", "sec_equal_op",
    "num", "bool", "variable",
    "func", "func_call", "func_body", "param",
    "if_", "define", "nullnode"
};


typedef struct node{
    enum nodeType type;
    int value;
    char *name;
    struct node *right;
    struct node *left;
} node;

enum varType {
    var_n, var_b
};

typedef struct{
    enum varType type;
    int value;
    char* name;
    node* func;
    node* exp;
}var;

typedef struct{
    var data[500];
    int top;
}variables;

node *CreateNode(enum nodeType type, int value, char* name);
var EvaluateTree(node* root);
var create_var(int _value, enum varType _type);

variables var_table;    // 用來存所有variable
int search_vartable(char* var_name);

variables local_vars;
int search_local(char* var_name);
void get_local(node* root);
void go_back_to(char* varname);
void define_local_var(node* root);

variables param_stack;

void set_param(node* root);
void cal_param(node* root);

int equal_num[300];
int equal_top;
void get_equal_num(node* root);

void type_check(var _var, enum varType _type);

%}

%union{
    int ival;
    char *word;
    struct node *N;
};

%token MOD AND OR NOT
%token PRINT_NUM PRINT_BOOL IF DEFINE FUN
%token<ival> NUM BOOL
%token<word> ID
%type<N> exp exps_plus exps_mul exps_and exps_or exps_equal
%type<N> if_exp
%type<N> fun_exp fun_body fun_call fun_ids
%type<N> num_op plus minus multiply divide modulus greater smaller equal logical_op and_op or_op not_op
%type<N> variable ids params param
%type<N> test_exp then_exp else_exp
%type<N> def_loc_stmts def_loc_stmt
%type<word> def_global_variable fun_name


%%

program:
    stmts {}
    ;

stmts:
    stmt stmts
    | {}
    ;

stmt:
    exp { EvaluateTree($1); }
    | print_stmt {}
    | def_stmt {}
    ;

print_stmt:
    '(' PRINT_NUM exp ')' {
        printf("%d\n", EvaluateTree($3).value);
    }
    | '(' PRINT_BOOL exp ')' {
        if(EvaluateTree($3).value != 0){
            printf("#t\n");
        }
        else{
            printf("#f\n");
        }
    }
    ;

exp:
    BOOL{
        node *newnode = CreateNode(bool, $1, "");
        $$ = newnode;
    }
    | NUM {
        node *newnode = CreateNode(num, $1, "");
        $$ = newnode;
    }
    | variable {
        $$ = $1;
    }
    | num_op{
        $$ = $1;
    }
    | logical_op{
        $$ = $1;
    }
    | fun_exp {
        $$ = $1;
    }
    | fun_call {
        $$ = $1;
    }
    | if_exp{
        $$ = $1;
    }
    ;


num_op:
    plus { 
        $$ = $1;
    }
    | minus {
        $$ = $1;
    }
    | multiply {
        $$ = $1;
    }
    | divide {
        $$ = $1;
    }
    | modulus {
        $$ = $1;
    }
    | greater {
        $$ = $1;
    }
    | smaller {
        $$ = $1;
    }
    | equal {
        $$ = $1;
    }
    ;


plus:
    '(' '+' exp exps_plus ')' {
        node *newnode = CreateNode(plus_op, 0, "");
        newnode -> left = $3;
        newnode -> right=$4;
        $$ = newnode;
    }
    ;
    // 處理會加超過一個以上的情況
    exps_plus:
        exp { $$ = $1; }
        | exp exps_plus {
            node *newnode = CreateNode(plus_op, 0, "");
            newnode -> left = $1;
            newnode -> right = $2;
            $$ = newnode;
        }
        ;

minus:
    '(' '-' exp exp ')'{
        node *newnode = CreateNode(minus_op, 0, "");
        newnode -> left = $3;
        newnode -> right=$4;
        $$ = newnode;
    }
    ;

multiply:
    '(' '*' exp exps_mul ')' {
        node *newnode = CreateNode(mul_op, 0, "");
        newnode -> left = $3;
        newnode -> right=$4;
        $$ = newnode;
    }
    ;
    exps_mul:
        exp { $$ = $1; }
        | exp exps_mul {
            node *newnode = CreateNode(mul_op, 0, "");
            newnode -> left = $1;
            newnode -> right = $2;
            $$ = newnode;
        }
        ;

divide:
    '(' '/' exp exp ')' {
        node *newnode = CreateNode(div_op, 0, "");
        newnode -> left = $3;
        newnode -> right=$4;
        $$ = newnode;
    }
    ;

modulus:
    '(' MOD exp exp ')' {
        node *newnode = CreateNode(mod_op, 0, "");
        newnode -> left = $3;
        newnode -> right=$4;
        $$ = newnode;
    }
    ;

greater:
    '(' '>' exp exp ')' {
        node *newnode = CreateNode(greater_op, 0, "");
        newnode -> left = $3;
        newnode -> right = $4;
        $$ = newnode;
    }
    ;

smaller:
    '(' '<' exp exp ')' {
        node *newnode = CreateNode(smaller_op, 0, "");
        newnode -> left = $3;
        newnode -> right = $4;
        $$ = newnode;
    }
    ;

equal:
    '(' '=' exp exps_equal ')' {
        node *newnode = CreateNode(equal_op, 0, "");
        newnode -> left = $3;
        newnode -> right = $4;
        $$ = newnode;
    }
    ;
    exps_equal:
        exp { $$ = $1; }
        | exp exps_equal {
            node *newnode = CreateNode(sec_equal_op, 0, "");
            newnode -> left = $1;
            newnode -> right = $2;
            $$ = newnode;
        }
        ;

logical_op:
    and_op {
        $$ = $1;
    }
    | or_op {
        $$ = $1;
    }
    | not_op {
        $$ = $1;
    }
    ;

and_op:
    '(' AND exp exps_and')' {
        node* newnode = CreateNode(and_op, 0, "");
        newnode->left = $3;
        newnode->right = $4;
        $$ = newnode;
    }
    ;
    exps_and:
        exp { $$ = $1; }
        | exp exps_and {
            node* newnode = CreateNode(and_op, 0 , "");
            newnode -> left = $1;
            newnode -> right = $2;
            $$ = newnode;
        }
        ;

or_op:
    '(' OR exp exps_or ')' {
        node* newnode = CreateNode(or_op, 0, "");
        newnode -> left = $3;
        newnode -> right = $4;
        $$ = newnode;
    }
    ;
    exps_or:
        exp { $$ = $1; }
        | exp exps_or {
            node* newnode = CreateNode(or_op, 0 , "");
            newnode -> left = $1;
            newnode -> right = $2;
            $$ = newnode;
        }
        ;

not_op:
    '(' NOT exp ')' {
        node* newnode = CreateNode(not_op, 0, "");
        newnode -> left = $3;
        newnode -> right = NULL;
        $$ = newnode;
    }
    ;

// 定義 define
def_stmt:
    '(' DEFINE def_global_variable exp ')' {
        printf("define %s's right type is %s\n", $3, nodeTypeNames[$4->type]);
        var_table.data[search_vartable($3)].exp = $4; // 若變數是function name
        // if($4->type == func){ 
        //     var_table.data[search_vartable($3)].func = $4; // 若變數是function name
        // }
        // else{
        //     var_table.data[search_vartable($3)].value = EvaluateTree($4).value;
        // }
    }
    ;

// 只用來定義global variable
def_global_variable:
    ID{
        if(search_vartable($1) == -1){
            var_table.top ++;
            var_table.data[var_table.top].name = $1;
            var_table.data[var_table.top].value = 0;
        }
        $$ = $1;
    }
    ;

variable:
    ID {
        node* newnode;
        newnode = CreateNode(variable, 0, $1);
        $$ = newnode;
    }
    ;

// 呼叫或建立function都會遇到
fun_exp:
    '(' FUN fun_ids fun_body ')'{
        node* newnode = CreateNode(func, 0, "");
        newnode -> left = $3;
        newnode -> right = $4;
        $$ = newnode;
    }
    ;

fun_ids:
    '(' ')' { $$ = NULL; }
    | '(' ids ')' { 
        $$ = $2; 
    }
    ;
    ids:
        ID {
            node* newnode = CreateNode(variable, 0 ,$1);
            newnode -> left = NULL;
            newnode -> right = NULL;
            $$ = newnode;
        }
        | ids ID {
            node* newnode = CreateNode(variable, 0 ,$2);
            newnode -> left = $1;
            newnode -> right = NULL;
            $$ = newnode;
        }
        ;

// now doing
fun_body:
    def_loc_stmts exp { 
        node* newnode = CreateNode(func_body, 0, "");
        newnode -> left = $1;
        newnode -> right = $2;
        $$ = newnode;
    }
    | exp {
        node* newnode = CreateNode(func_body, 0, "");
        newnode -> left = NULL;
        newnode -> right = $1;
        $$ = newnode;
    }
    ;

def_loc_stmts:
    def_loc_stmt { $$ = $1; }
    | def_loc_stmts def_loc_stmt {
        $2 -> left = $1;
        $$ = $2;
    }
    ;

def_loc_stmt:
    '(' DEFINE ID exp ')' {
        node* newnode = CreateNode(define, 0, $3);
        newnode -> left = NULL;
        newnode -> right = $4;
        $$ = newnode;
    }
    ;

// 呼叫函式
fun_call:
    '(' fun_exp ')' { 
        // 建立func call的點，先不及著call
        node* newnode = CreateNode(func_call, 0, "");
        newnode -> left = NULL;
        newnode -> right = $2;
        $$ = newnode;
    }
    | '(' fun_exp params')' {
        node* newnode = CreateNode(func_call, 0, "");
        newnode -> left = $3;
        newnode -> right = $2;

        $$ = newnode;
    }
    | '(' fun_name ')' {
        // 回傳這個funciton的node
        node* newnode = CreateNode(func_call, 0, $2);
        newnode -> left = NULL;
        newnode -> right = NULL;
        $$ = newnode;
    }
    | '(' fun_name params')' {
        node* newnode = CreateNode(func_call, 0, $2);
        newnode -> left = $3;
        newnode -> right = NULL;
        $$ = newnode;
    }
    ;
    params:
        param {
            node* newnode = CreateNode(param, 0, "");
            newnode -> left = NULL;
            newnode -> right = $1;
            $$ = newnode;
        }
        | params param {
            node* newnode = CreateNode(param, 0, "");
            newnode -> left = $1;
            newnode -> right = $2;
            $$ = newnode;
        }
        ;
    param:
        exp { 
            $$ = $1;
        }
        ;

fun_name:
    ID { 
        $$ = $1;
    }
    ;

if_exp:
    '(' IF test_exp then_exp else_exp ')' {
        node* newnode = CreateNode(if_, 0, "");
        newnode -> left = $3;
        // 不能直接這樣給左右子樹
        node* ansnode = CreateNode(nullnode, 0, "");
        newnode -> right = ansnode;
        ansnode -> left = $4;
        ansnode -> right = $5;
        // newnode -> right -> right = $5;
        $$ = newnode;
    }
    ;
    test_exp:
        exp {$$ = $1;}
        ;
    
    then_exp:
        exp {$$ = $1;}
        ;

    else_exp:
        exp {$$ = $1;}
        ;


%%

node *CreateNode(enum nodeType type, int value, char *name){
    node* newnode = (node*) malloc(sizeof(node));
    newnode -> type = type;
    newnode -> value = value;
    newnode -> name = name;
    newnode -> left = NULL;
    newnode -> right = NULL;
    return newnode;
}


var EvaluateTree(node* root){
    if(root == NULL){

    }
    else{
        if(root->type == plus_op){
            var left_var = EvaluateTree(root->left);
            var right_var = EvaluateTree(root->right);
            type_check(left_var, var_n);
            type_check(right_var, var_n);
            var _var = create_var(left_var.value + right_var.value, var_n);
            printf("plus: %d\n", _var.value);
            return(_var);
        }
        else if(root->type == minus_op){
            var left_var = EvaluateTree(root->left);
            var right_var = EvaluateTree(root->right);
            type_check(left_var, var_n);
            type_check(right_var, var_n);
            var _var = create_var(left_var.value - right_var.value, var_n);
            return(_var);
        }
        else if(root->type == mul_op){
            var left_var = EvaluateTree(root->left);
            var right_var = EvaluateTree(root->right);
            type_check(left_var, var_n);
            type_check(right_var, var_n);
            var _var = create_var(left_var.value * right_var.value, var_n);
            printf("mul: %d\n", _var.value);
            return(_var);
        }
        else if(root->type == div_op){
            var left_var = EvaluateTree(root->left);
            var right_var = EvaluateTree(root->right);
            type_check(left_var, var_n);
            type_check(right_var, var_n);
            var _var = create_var(left_var.value / right_var.value, var_n);
            return(_var);
        }
        else if(root->type == mod_op){
            var left_var = EvaluateTree(root->left);
            var right_var = EvaluateTree(root->right);
            type_check(left_var, var_n);
            type_check(right_var, var_n);
            var _var = create_var(left_var.value % right_var.value, var_n);
            return(_var);
        }
        else if(root->type == greater_op){
            var left_var = EvaluateTree(root->left);
            var right_var = EvaluateTree(root->right);
            type_check(left_var, var_n);
            type_check(right_var, var_n);
            var _var = create_var(left_var.value > right_var.value, var_b);
            return(_var);
        }
        else if(root->type == smaller_op){
            var left_var = EvaluateTree(root->left);
            var right_var = EvaluateTree(root->right);
            type_check(left_var, var_n);
            type_check(right_var, var_n);
            var _var = create_var(left_var.value < right_var.value, var_b);
            return(_var);
        }
        else if(root->type == equal_op){

            // 有2個以上的數進行比較會先使用get_equal_num獲得數字陣列
            if(root->right->type == sec_equal_op){
                get_equal_num(root->right);
            }
            else{
                var left_var = EvaluateTree(root->left);
                var right_var = EvaluateTree(root->right);
                type_check(left_var, var_n);
                type_check(right_var, var_n);
                var _var = create_var(left_var.value == right_var.value, var_b);
                return(_var);
            }

            // 將第一個數與其他數進行比較
            int equal_flag = 1, first_num = EvaluateTree(root->left).value;
            for(int i = 0 ; i <= equal_top; i++){
                if(first_num != equal_num[i]){
                    equal_flag = 0;
                    break;
                }
            }
            equal_top = -1;     // 清空equal_num的stack
            var _var = create_var(equal_flag, var_b);

            return(_var);
        }
        else if(root->type == sec_equal_op){
            
        }
        else if(root->type == and_op){
            var left_var = EvaluateTree(root->left);
            var right_var = EvaluateTree(root->right);
            type_check(left_var, var_b);
            type_check(right_var, var_b);
            var _var = create_var(left_var.value && right_var.value, var_b);
            return(_var);
        }
        else if(root->type == or_op){
            var left_var = EvaluateTree(root->left);
            var right_var = EvaluateTree(root->right);
            type_check(left_var, var_b);
            type_check(right_var, var_b);
            var _var = create_var(left_var.value || right_var.value, var_b);
            return(_var);
        }
        else if(root->type == not_op){
            var _var = EvaluateTree(root->left);
            type_check(_var, var_b);
            _var.value = !_var.value;
            return(_var);
        }
        else if(root->type == num){
            var _var;
            _var.type = var_n;
            _var.value = root->value; 
            return(_var);
        }
        else if(root->type == bool){
            var _var;
            _var.type = var_b;
            _var.value = root->value; 
            return(_var);
        }
        else if(root->type == variable){
            // 若是變數型態就會先去搜尋local接著才去搜尋global
            int index = search_local(root->name);
            var _var;
            if(index != -1){
                _var = local_vars.data[search_local(root->name)];
                /* _var = EvaluateTree(local_vars.data[index].exp); */
                printf("_var ( %s )'s value is %d\n", root->name, _var.value);
                return(_var);
            }
            _var = var_table.data[search_vartable(root->name)];
            return(_var);
        }
        /* else if(root->type == func){
            var _var = EvaluateTree(root->right);
            return(_var);
        } */
        else if(root->type == if_){
            var if_var = EvaluateTree(root->left);
            type_check(if_var, var_b);
            if(if_var.value != 0){
                return(EvaluateTree(root->right->left));
            }
            else{
                return(EvaluateTree(root->right->right));
            }
        }
        else if(root->type == func_call){
            // 取得內部define的local變數
            printf("[+] now call function: %s, ", root->name);
            if(root->name != ""){
                int index = search_local(root->name);
                if(index == -1){
                    index = search_vartable(root->name);
                    if(index > -1){
                        root->right = var_table.data[index].exp;
                    }
                }
                else{
                    root->right = local_vars.data[index].exp;
                }
            }
            printf("func first type: %s\n", nodeTypeNames[root->right->type]);
            // 計算parameter
            cal_param(root->left);

            /* get_local(root->right->left);
            local_vars.top ++;
            local_vars.data[local_vars.top].name = "_ebp";
            printf("[+] get local finish\n"); */
            /* set_param(root->left); 
            printf("[+] set param finish\n"); */

            var ans = EvaluateTree(root->right);
            go_back_to("_end");

            return(ans);

        }
        else if(root->type == func){
            get_local(root->left);
            local_vars.top ++;
            local_vars.data[local_vars.top].name = "_ebp";
            printf("[+] get local finish\n");

            set_param(root->left); 
            printf("[+] set param finish\n");

            var _var = EvaluateTree(root->right);
            return(_var);
        }
        else if(root->type == func_body){
            // 取得內部define的變數，並最後用_end蓋起來
            define_local_var(root->left);
            local_vars.top ++;
            local_vars.data[local_vars.top].name = "_end";
            return(EvaluateTree(root->right));
        }
    }
}

// 用變數名稱搜尋global變數
int search_vartable(char* var_name){
    for( int i = 0 ; i <= var_table.top ; i++){
        if(strcmp(var_name, var_table.data[i].name) == 0){
            // 在var_table中
            return i;
        }
    }
    // 若不在var_table中，則回傳-1
    return(-1);
}

// 用變數名稱搜尋local變數
int search_local(char* var_name){
    for( int i = local_vars.top ; i > -1 ; i--){
        if(strcmp(var_name, local_vars.data[i].name) == 0){
            // 在var_table中
            return i;
        }
    }
    // 若不在var_table中，則回傳-1
    return(-1);
}

// 用於多個數進行equal判斷時
void get_equal_num(node* root){
    if(root != NULL){
        if(root->type == sec_equal_op){
            equal_top ++;
            var _var = EvaluateTree(root->left);
            type_check(_var, var_n);
            equal_num[equal_top] = _var.value;
            if(root->right->type == sec_equal_op){
                get_equal_num(root->right);
            }
            else{
                _var = EvaluateTree(root->left);
                type_check(_var, var_n);
                equal_top ++;
                equal_num[equal_top] = _var.value;
            }
        }
    }
}

// 將function會用到的參數名稱加到local variable裡
void get_local(node* root){
    if(root != NULL){
        printf("%s\n", nodeTypeNames[root->type]);
        get_local(root->left);
        local_vars.top ++;
        local_vars.data[local_vars.top].name = root->name;
        local_vars.data[local_vars.top].value = 0;
        printf("[+] get local variable: %s\n", root->name);
    }
}

void go_back_to(char* varname){
    local_vars.top --;
    for(; local_vars.top >= 0 ; local_vars.top --){
        if(strcmp(varname, local_vars.data[local_vars.top].name) == 0){
            break;
        }
    }
}

// 在function內define的變數
void define_local_var(node* root){
    while(root != NULL){
        local_vars.top ++;
        local_vars.data[local_vars.top].name = root->name;
        if(root->right->type == func){
            local_vars.data[search_local(root->name)].exp = root->right; // 若變數是function name
        }
        else{
            local_vars.data[local_vars.top].value = EvaluateTree(root->right).value;
        }
        root = root->left;
    }
}

void cal_param(node* root){
    // 參數從右到左讀取
    while(root != NULL){
        param_stack.top ++ ; 
        param_stack.data[param_stack.top].exp = root->right;
        printf("[+] push param_stack, now top is: %d\n", param_stack.top);
        root = root -> left;
    }
}


void set_param(node* root){
    if(root != NULL){
        set_param(root->left);
        printf("[+] set param in local_var( %s )\n", root->name);
        /* local_vars.data[search_local(root->name)].exp = param_stack.data[param_stack.top].exp; */
        local_vars.data[search_local(root->name)].value = EvaluateTree(param_stack.data[param_stack.top].exp).value;
        /* printf("%d\n", EvaluateTree(param_stack.data[param_stack.top].exp).value); */
        param_stack.top --;
        printf("[+] pop param_stack, now top is: %d\n", param_stack.top);
    }
    /* int top = local_vars.top -1;  */
    // 參數從右到左讀取
}

var create_var(int _value, enum varType _type){
    var _var;
    _var.value = _value;
    _var.type = _type;
    return(_var);
}

void type_check(var _var, enum varType _type){
    if(_var.type != _type){
        printf("Type error!\n");
        exit(0);
    }
}


void yyerror(const char *message)
{	
    printf("Syntax Error\n");
    
}

int main(int argc, char *argv[])
{
    var_table.top = -1;
    local_vars.top = -1;
    param_stack.top = -1;
    equal_top = -1;

    if(argc > 1){
        printf("read file: %s\n", argv[argc-1]);
        FILE* fp = fopen(argv[argc-1], "r");
        if (fp == NULL) {
            printf("cannot open %s\n", argv[argc-1]);
            return -1;
        }
        yyin = fp;
    }
    yyparse();
    return(0);
}