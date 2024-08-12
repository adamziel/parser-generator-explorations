import sys

def add_peg_parse_whitespace(file_path):
    with open(file_path, 'r+') as file:
        lines = file.readlines()
        file.seek(0)

        for line in lines:
            file.write(line)
            if line.strip().startswith('function peg$parse') \
                and not line.strip().startswith('function peg$parseWHITESPACE') \
                and not line.strip().startswith('function peg$parse('):
                file.write('peg$parseWHITESPACE();\n')

        file.truncate()

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Please provide the file path as a command-line argument.')
    else:
        file_path = sys.argv[1]
        add_peg_parse_whitespace(file_path)
