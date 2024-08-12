#define YY_DEBUG 1
#include <stdio.h>
#include <stdlib.h>

// Include the generated parser file directly
#include "mysql-versionless.c"

// Assume the generated parser has a function named `parse`
// Modify this based on the actual function name in `example.c`
extern int yyparse(const char *input);

// Function to read the entire file into a string
char *read_file(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("fopen");
        return NULL;
    }

    fseek(file, 0, SEEK_END);
    long length = ftell(file);
    fseek(file, 0, SEEK_SET);

    char *buffer = malloc(length + 1);
    if (!buffer) {
        perror("malloc");
        fclose(file);
        return NULL;
    }

    fread(buffer, 1, length, file);
    buffer[length] = '\0';
    fclose(file);

    return buffer;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input-file>\n", argv[0]);
        return 1;
    }

    char *input = read_file(argv[1]);
    if (!input) {
        return 1;
    }

    // Assume the generated parser uses a function named `parse`
    // and it takes the input as a string
    int result = yyparse(input);

    free(input);
    exit(0);
}
