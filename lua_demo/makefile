.PHONY: test, all

TESTS = 'a|b' 'a*' 'ab' '(a|b)c' '(a|b)*c' '(ab)*|c'

DBEUG_STR = (a|b)*

test: 
	luajit init.lua -d

target:
	luajit init.lua -o README.md

test_all:
	rm README.md;\
	for i in $(TESTS); do \
		echo "# $$i" >> README.md; \
		luajit init.lua -s "$$i" -a -o README.md; \
	done


debug:
	luajit init.lua -s "$(DBEUG_STR)" -d
