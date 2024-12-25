%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


void yyerror(const char *s);
extern int yylex();
extern int yyparse();

enum nodeType {
    plus_op, minus_op, mul_op, div_op, mod_op,
    and_op, or_op, not_op,
    greater_op, smaller_op, equal_op, sec_equal_op,
    num, bool, variable, local, func, if_, nullnode
};


typedef struct TOKEN_STRUCT{
    int index;
    int ival;
    int result_plus;
    int result_mul;
    int result_and;
    int result_or;
} token; 

typedef struct node{
    enum nodeType type;
    // token var;
    int value;
    char *name;
    struct node *right;
    struct node *left;
} node;


node *CreateNode(enum nodeType type, int value, char* name);
int EvaluateTree(node* root);

enum varType {
    var_n, var_b
};

typedef struct{
    // enum varType type;
    int value;
    char *name;
    node *func;
}var;

typedef struct{
    var data[500];
    int top;
}variables;

variables var_table;    // 用來存所有variable
int search_vartable(char* var_name);

variables local_vars;
int search_local(char* var_name);
void get_local(node* root);
void clear_local();

int parameters[300];
int param_top;
void set_param(node* root);

int equal_num[300];
int equal_top;
void get_equal_num(node* root);

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
%type<N> fun_exp fun_body fun_call fun_ids fun_name
%type<N> num_op plus minus multiply divide modulus greater smaller equal logical_op and_op or_op not_op
%type<N> variable ids
%type<N> test_exp then_exp else_exp
%type<word> def_global_variable
%type<ival> param params


%%

program:
    stmts {}
    ;

stmts:
    stmt stmts
    | {}
    ;

stmt:
    exp { 
        // printf("%d\n", $1.ival); 
    }
    | print_stmt {}
    | def_stmt {}
    ;

print_stmt:
    '(' PRINT_NUM exp ')' {
        printf("%d\n", EvaluateTree($3));
    }
    | '(' PRINT_BOOL exp ')' {
        if(EvaluateTree($3) != 0){
            printf("#t\n");
        }
        else{
            printf("#f\n");
        }
    }
    ;

exp:
    BOOL{
        node *newnode = CreateNode(num, $1, "");
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

def_stmt:
    '(' DEFINE def_global_variable exp ')' {
        var_table.data[search_vartable($3)].value = EvaluateTree($4);
        // printf("%d\n", EvaluateTree($4));
        var_table.data[search_vartable($3)].func = $4; // 若變數是function name
    }
    ;

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
        if(search_local($1) > -1 || search_vartable($1) > -1){
            // newnode = CreateNode(local, 0, $1);
            newnode = CreateNode(variable, 0, $1);
            // printf("create variable: %s\n", $1);

            // printf("find loacal!!\n");
        }
        else{
            printf("%s not exist\n", $1);
            YYABORT;
        }
        $$ = newnode;
    }
    ;

fun_exp:
    '(' FUN fun_ids fun_body ')'{
        node* newnode = CreateNode(func, 0, "");
        newnode -> right = $4;
        newnode -> left = $3;
        $$ = newnode;
        // clear_local
        local_vars.top = -1;
        // $$ = $4;
    }
    ;

fun_ids:
    '(' ')' { $$ = NULL; }
    | '(' ids ')' { $$ = $2; }
    ;
    ids:
        ID {
            // node* newnode = CreateNode(local, 0 ,$1);
            node* newnode = CreateNode(variable, 0 ,$1);
            newnode -> left = NULL;
            newnode -> right = NULL;
            $$ = newnode;

            local_vars.top ++;
            local_vars.data[local_vars.top].name = $1;
            local_vars.data[local_vars.top].value = 0;
            // node* newnode = CreateNode(local, 0, $1);
            // $$ = $1;
        }
        | ids ID {
            // printf("%s\n", $2);
            // node* newnode = CreateNode(local, 0 ,$1);
            node* newnode = CreateNode(variable, 0 ,$2);
            newnode -> left = $1;
            newnode -> right = NULL;
            $$ = newnode;
            local_vars.top ++;
            local_vars.data[local_vars.top].name = $2;
            local_vars.data[local_vars.top].value = 0;
            // node* newnode = CreateNode(local, 0, $1);
            // newnode -> left
            // $$ = $1;
        }
        ;

fun_body:
    exp { $$ = $1; }
    ;

fun_call:
    '(' fun_exp ')' {
        get_local($2->left);
        $$ = $2;
        // 把parameter和local變數皆清空
        // param_top = -1;
        // local_vars.top = -1; 
    }
    | '(' fun_exp params')' {
        get_local($2->left);
        set_param($2->right);
        $$ = $2;
        // 把parameter和local變數皆清空
        param_top = -1;
        clear_local();
        // local_vars.top = -1; 
    }
    | '(' fun_name ')' {
        // 回傳這個funciton的node
        printf("func_name call\n");
        // left是local變數
        get_local($2->left);
        $$ = $2;
        // 把parameter和local變數皆清空
        // param_top = -1;
        // clear_local();
        // local_vars.top = -1; 
    }
    | '(' fun_name params')' {
        printf("func_name call with param\n");
        get_local($2->left);
        local_vars.top ++;
        local_vars.data[local_vars.top].name = "_ebp";
        local_vars.data[local_vars.top].value = 0;
        printf("put local: _ebp\n");

        set_param($2->right);
        $$ = $2;
        // 把parameter和local變數皆清空
        // 不能直接清空
        param_top = -1;
        clear_local();
        // local_vars.top = -1; 
    }
    ;
    params:
        param {
            param_top ++;
            parameters[param_top] = $1;
        }
        | params param {
            param_top ++;
            parameters[param_top] = $2;
        }
        ;
    param:
        exp { $$ = EvaluateTree($1); }
        ;

fun_name:
    ID { 
        int index = search_vartable($1);
        if(index > -1){
            $$ = var_table.data[index].func;
            // node* newnode = CreateNode(func, 0, "");
            // newnode -> left = var_table
        }
        else{
            printf("function 不存在\n");
            YYABORT;
        }
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
        // if(EvaluateTree($3) != 0){
        //     $$ = $4;
        // }
        // else{
        //     $$ = $5;
        // }
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
    /* printf("create node: %d\n", newnode->type); */
    return newnode;
}

int EvaluateTree(node* root){
    // leaf
    if(root == NULL){
        return(0); 
    }
    if(root->type == plus_op){
        /* printf("plus\n"); */
        return(EvaluateTree(root->left) + EvaluateTree(root->right));
    }
    else if(root->type == minus_op){
        return(EvaluateTree(root->left) - EvaluateTree(root->right));
    }
    else if(root->type == mul_op){
        return(EvaluateTree(root->left) * EvaluateTree(root->right));
    }
    else if(root->type == div_op){
        return(EvaluateTree(root->left) / EvaluateTree(root->right));
    }
    else if(root->type == mod_op){
        return(EvaluateTree(root->left) % EvaluateTree(root->right));
    }
    else if(root->type == greater_op){
        /* printf("greater\n"); */
        return(EvaluateTree(root->left) > EvaluateTree(root->right));
    }
    else if(root->type == smaller_op){
        return(EvaluateTree(root->left) < EvaluateTree(root->right));
    }
    else if(root->type == equal_op){
        if(root->right->type == sec_equal_op){
            get_equal_num(root->right);
        }
        else{
            return(EvaluateTree(root->left) == EvaluateTree(root->right));
        }
        int equal_flag = 1, first_num = EvaluateTree(root->left);
        for(int i = 0 ; i <= equal_top; i++){
            if(first_num != equal_num[i]){
                equal_flag = 0;
                break;
            }
            /* printf("%d\n", equal_num[i]); */
        }
        equal_top = -1;
        return(equal_flag);
        /* return(EvaluateTree(root->left) == EvaluateTree(root->right)); */
    }
    else if(root->type == sec_equal_op){
        /* int left = EvaluateTree(root->left);
        int right = EvaluateTree(root->right);
        if(left == right){
            return(left);
        }
        else{
            return 0;
        } */
    }
    else if(root->type == and_op){
        return(EvaluateTree(root->left) & EvaluateTree(root->right));
    }
    else if(root->type == or_op){
        return(EvaluateTree(root->left) | EvaluateTree(root->right));
    }
    else if(root->type == not_op){
        return(!EvaluateTree(root->left));
    }
    else if(root->type == num){
        /* printf("num: %d\n", root->value); */
        return(root->value);
    }
    else if(root->type == bool){
        return(root->value);
    }
    else if(root->type == variable){
        printf("%d\n", search_local(root->name));
        if(root->value != 0){
            return root->value;
        }
        /* if(search_local(root->name) != -1){
            return root->value;
        } */
        return(var_table.data[search_vartable(root->name)].value);
    }
    else if(root->type == func){
        return(EvaluateTree(root->right));
    }
    else if(root->type == if_){
        if(EvaluateTree(root->left) != 0){
            /* printf("this if is true\n"); */
            EvaluateTree(root->right->left);
        }
        else{
            /* printf("this if is false\n"); */
            EvaluateTree(root->right->right);
        }
    }
    else{ return 0; }
}


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

int search_local(char* var_name){
    for( int i = 0 ; i <= local_vars.top ; i++){
        if(strcmp(var_name, local_vars.data[i].name) == 0){
            // 在var_table中
            return i;
        }
    }
    // 若不在var_table中，則回傳-1
    return(-1);
}

void get_equal_num(node* root){
    if(root != NULL){
        if(root->type == sec_equal_op){
            equal_top ++;
            equal_num[equal_top] = EvaluateTree(root->left);
            if(root->right->type == sec_equal_op){
                get_equal_num(root->right);
            }
            else{
                equal_top ++;
                equal_num[equal_top] = EvaluateTree(root->right);
            }
        }
    }
}

void get_local(node* root){
    /* printf("get local\n"); */
    if(root != NULL){
        get_local(root->left);
        local_vars.top ++;
        local_vars.data[local_vars.top].name = root->name;
        local_vars.data[local_vars.top].value = 0;
        printf("get local: %s\n", local_vars.data[local_vars.top].name);
    }
    /* local_vars.top ++;
    local_vars.data[local_vars.top].name = "_ebp";
    local_vars.data[local_vars.top].value = 0;
    printf("put local: _ebp\n"); */
    /* printf("local null\n"); */
}

void clear_local(){
    local_vars.top--;
    for(; local_vars.top >= 0 ; local_vars.top --){
        if(strcmp("_ebp", local_vars.data[local_vars.top].name) == 0){
            break;
        }
        else{
            printf("clear %s\n", local_vars.data[local_vars.top].name);
        }
    }
}

void set_param(node* root){
    if(root != NULL){
        /* printf("-%s-\n", root->name); */
        if(root->type == variable){
            // 要注意local變數和parameter的位置順序
            int index = search_local(root->name);
            printf("local index: %d\n", index);
            if(index > -1){
                printf("%s: ", root->name);
                /* root->type = local_vars.data[index].type; */

                // 不能改成num，要不然只會用一次
                /* root->type = num; */
                root->value = parameters[index];
                printf("set param: %d\n", root->value);
            }
        }
        set_param(root->left);
        set_param(root->right);
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
    param_top = -1;
    equal_top = -1;
    yyparse();
    return(0);
}