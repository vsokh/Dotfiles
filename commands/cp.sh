co() { g++ -std=c++17 -O2 -o "${1%.*}" $1 -g -Wall -fsanitize=address; }
run() { co $1 && ./${1%.*} & fg; }
