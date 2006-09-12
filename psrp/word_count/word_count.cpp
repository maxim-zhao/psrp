//www.cs.utsa.edu/~wagner/CS1723/handouts/treealt.pdf
//
//Word Frequency Program (Non-Recursive Version), Fri Oct 30 1998

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
 
#define MAXWORD 500
#define MAXS 500
 
struct tnode {
	char *word;
	int count;
	struct tnode *left; 
	struct tnode *right;
};
 
struct tnode *addtree(struct tnode *, char *);
struct tnode *newnode(char *); 
void treeprint(struct tnode *);
struct tnode *talloc(void);
int getword(char *, int);
char *strdupl(char *);

/* custom additions */
struct tnode *largest(struct tnode *node);
void destroy(struct tnode *p);

/* stuff below is for a stack of pointers to nodes */
void push(struct tnode *);
struct tnode *pop(void);
int size();
struct tnode *s[MAXS];
int sp = 0;
 
/* word frequency count -- non-recursive version */

int main()
{
	struct tnode *root;
	int lcv;
	FILE *fp;
 
	char word[MAXWORD];
	root = NULL;
 
	while (getword(word, MAXWORD) != EOF) {
		if (isalpha(word[0]) || word[0] == '\'')
			root = addtree(root, word);
	}
	//treeprint(root);

	fp = fopen( "words.txt", "w" );

	printf( "Most common 256 words, weighted by lengths\n" );

	for( lcv = 0; lcv < 256; lcv++ ) {
		struct tnode *node;
		
		do {
			node = largest( root );
			if( strlen( node -> word ) > 1 ) break;
			node -> count = 0;
		} while( 1 );

		printf( "%4d %s\n", node -> count, node -> word );
		fprintf( fp, "%s\n", node -> word );
		node -> count = 0;

		if( lcv == 127 ) printf( "\n----------------------------\n\n" );
	}

	destroy( root );

	fclose( fp );
 
	return 0;
}
 
/* addtree: add a node, non-recursive */
struct tnode *addtree(struct tnode *p, char *w) 
{
	int cond;
 
	struct tnode *root = p;

	if (p == NULL) return newnode(w);
 
	for (;;) {
		if ((cond = strcmp(w, p -> word)) == 0) {
			(p -> count)++;
			return root;
		}
		
		if (cond < 0) {
			if ((p -> left) == NULL) {
				p -> left = newnode(w);
				return root;
			}
			else
				p = p -> left;
		}
		else if (cond > 0) {
			if ((p -> right) == NULL) {
				p -> right = newnode(w);
				return root;
			} else
				p = p -> right;
		}
	}
}
 
/* newnode: fix up a new node */

struct tnode *newnode(char *w) 
{
	struct tnode *p = talloc();
 
	p -> word = strdupl(w);
	p -> count = 1;
 
	p -> left = p -> right = NULL;
	return p;
}
 
/* treeprint: in-order print of tree p, non-recursive version */
 
void treeprint(struct tnode *p)
{ 
	for (;;) {
		while (p != NULL) {
			push(p);
			p = p -> left;
		}
		
		for (;;) {
			if (size() == 0) return;
			p = pop();

			printf("%4d %s\n", p -> count, p -> word);
			
			if ((p -> right) != NULL) {
				p = p -> right;
				break;
			}
		}
	}
}

/* talloc: make a tnode */

struct tnode *talloc(void) 
{
	return (struct tnode *) malloc(sizeof(struct tnode));
}

/* getword: get next word or charcter from input */
int getword(char *word, int lim) 
{
	int c;
 
	char *w = word;
	
	while (isspace(c = getchar())) ;
	if (c == '<') {
		while (c != '>') c = getchar();
		*w = '\0';
		return c;
	}
	if (c == '[') {
		while (c != ']') c = getchar();
		*w = '\0';
		return c;
	}
	if (c == '{') {
		while (c != '}') c = getchar();
		*w = '\0';
		return c;
	}
	if( c == ';' ) {
		while (c != '\n') c = getchar();
		*w = '\0';
		return c;
	}

	if (c != EOF) *w++ = c;
	if (!isalpha(c) && c != '\'') {
		*w = '\0';
		return c;
	}
	
	for ( ; --lim > 0; w++)
		if (!isalpha(*w = getchar())) {
			ungetc(*w, stdin);
			break;
		}
 
	*w = '\0';
	return word[0];
 }
 
/* strdupl: make a duplicate of s. (builtin) */
char *strdupl(char *s) 
{
	char *p;
 
	p = (char *) malloc(strlen(s)+1);
	if (p != NULL)
		strcpy(p, s);
	return p;
}
 
/* push, pop, size: stack routines */
void push(struct tnode *p) 
{
	s[sp++] = p;
}
 
struct tnode *pop(void)
{ 
	return s[--sp];
}
 
int size(void)
{
	return sp;
}

///////////////////////////////////////////

/* find largest node */
struct tnode *largest(struct tnode *p)
{ 
	struct tnode *node;
	unsigned int most = 0;

	for (;;) {
		while (p != NULL) {
			push(p);
			p = p -> left;
		}
		
		for (;;) {
			if (size() == 0) return node;
			p = pop();

			if( p -> count * ( strlen( p -> word ) - 1 ) > most ) {
				node = p;
				most = p -> count * ( strlen( p -> word ) - 1 );
			}
			
			if ((p -> right) != NULL) {
				p = p -> right;
				break;
			}
		}
	}

	return node;
}

/* erase allocated memory */
void destroy(struct tnode *p)
{ 
	for (;;) {
		while (p != NULL) {
			push(p);
			p = p -> left;
		}
		
		for (;;) {
			if (size() == 0) return;
			p = pop();
			if ((p -> right) != NULL) {
				p = p -> right;
				break;
			}

			// erase left and right here
			free( p -> word );
			if( p -> left ) free( p -> left );
			if( p -> right ) free( p -> right );
		}
	}
}