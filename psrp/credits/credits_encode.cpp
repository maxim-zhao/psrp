/*
Phantasy Star: Credits encoder
by Maxim
*/

#include <stdio.h>
#include <string.h>

const int base=0xbdbc;

int main( int argc, char **argv )
{
  FILE *in, *out;
  char s[1024],text[128]; // overflowable buffers :) string input
  char buffer[1024]; // output
  char *pointers=buffer; // writing pointer
  char *data,*p,*counter;
  int numscreens,x,y,offset,length,screensdone,linesthisscreen;

	// Assert proper usage
	if( argc != 3 ) {
		printf( "Usage: credits_encode <input file> <output file>\n" );
		return -1;
	}

	// Open files
	in=fopen(argv[1],"ra");
	if(!in) {
    printf("Error opening %s",argv[1]);
    return -1;
  }

  // count how many credits
  numscreens=0;
  while(!feof(in)) {
    fgets(s,1024,in);
    if(s[0]=='-') ++numscreens;
  }

  printf("%d screens\n",numscreens);

  fseek(in,0,0);

  data=buffer+numscreens*2; // data starts after pointers

  // encode them
  screensdone=0;
  linesthisscreen=0;
  counter=data++;
  while(!feof(in)) {
    fgets(s,1024,in);
    if(s[0]!='-') {
      // parse string
      if(sscanf(s,"%d,%d",&x,&y)==2) {
        offset=0xd000+64*y+2*x;
        // offset
        *data++=(offset>>0) & 0xff;
        *data++=(offset>>8) & 0xff;
        // get text
        for(p=s;*p!=' ';++p);
        ++p;
        // length
        length=strlen(p)-1;
        *data++=length;
        // text
        strncpy(data,p,length);
        data+=length;
        // line counter
        ++linesthisscreen;
      } else {
        printf("error: \"%s\"\n",s);
      }
    } else {
      // write pointer
      buffer[screensdone*2+0]=((counter-buffer+base)>>0) & 0xff;
      buffer[screensdone*2+1]=((counter-buffer+base)>>8) & 0xff;
      ++screensdone;
      // write the line count
      *counter=linesthisscreen;
      linesthisscreen=0;
      // make room for the next counter
      counter=data++;
    }
  }

  fclose(in);

	out=fopen(argv[2],"wb");
	if(!out) {
    printf("Error opening %s",argv[2]);
    return -1;
  }

  fwrite(buffer,1,data-buffer-1,out);

  fclose(out);

	return 0;
}
